import React, { useEffect, useMemo, useState } from 'react'
import {
  Box,
  Button,
  Chip,
  Container,
  FormControl,
  Grid,
  InputAdornment,
  InputLabel,
  MenuItem,
  Paper,
  Select,
  Stack,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  TablePagination,
  TextField,
  Typography,
  TableContainer,
} from '@mui/material'
import RefreshIcon from '@mui/icons-material/Refresh'
import DownloadIcon from '@mui/icons-material/Download'
import SearchIcon from '@mui/icons-material/Search'
import { useNavigate } from 'react-router-dom'
import { getMasters } from '../../api/master.api'
import { getTransactions, exportTransactionsCsv, exportTransactionsPdf } from '../../api/analytics.api'

const REFRESH_MS = 30000

const formatDateTime = (value) => {
  if (!value) return '-'
  const d = new Date(value)
  if (Number.isNaN(d.getTime())) return '-'
  return d.toLocaleString()
}

const formatDuration = (ms) => {
  if (!Number.isFinite(ms) || ms < 0) return '-'
  const totalMinutes = Math.floor(ms / 60000)
  const hours = Math.floor(totalMinutes / 60)
  const minutes = totalMinutes % 60
  if (hours <= 0) return `${minutes}m`
  return `${hours}h ${minutes}m`
}

const getDefaultFromDate = () => {
  const d = new Date()
  d.setDate(d.getDate() - 7)
  return d.toISOString().split('T')[0]
}

const getToday = () => new Date().toISOString().split('T')[0]

const downloadBlob = (blob, filename) => {
  const url = window.URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = filename
  document.body.appendChild(link)
  link.click()
  link.remove()
  window.URL.revokeObjectURL(url)
}

export default function TransactionsPage({ personType, title, detailPath }) {
  const navigate = useNavigate()

  const [loading, setLoading] = useState(false)
  const [rows, setRows] = useState([])
  const [page, setPage] = useState(0)
  const [rowsPerPage, setRowsPerPage] = useState(25)
  const [lastRefresh, setLastRefresh] = useState(new Date())
  const [now, setNow] = useState(new Date())

  const [projects, setProjects] = useState([])
  const [departments, setDepartments] = useState([])
  const [gates, setGates] = useState([])

  const [filters, setFilters] = useState({
    from_date: getDefaultFromDate(),
    to_date: getToday(),
    status: 'ALL',
    project_id: '',
    department_id: '',
    gate_id: '',
    q: '',
  })

  useEffect(() => {
    const timer = setInterval(() => setNow(new Date()), 30000)
    return () => clearInterval(timer)
  }, [])

  useEffect(() => {
    const loadMasters = async () => {
      try {
        const res = await getMasters()
        setProjects(res.data?.data?.projects || [])
        setDepartments(res.data?.data?.departments || [])
        setGates(res.data?.data?.gates || [])
      } catch (err) {
        console.error('Failed to load masters', err)
      }
    }
    loadMasters()
  }, [])

  const buildParams = () => {
    const params = {
      person_type: personType,
      limit: 1000, // fetch a generous batch and paginate client-side
      from_date: filters.from_date || undefined,
      to_date: filters.to_date || undefined,
      project_id: filters.project_id || undefined,
      department_id: filters.department_id || undefined,
      gate_id: filters.gate_id || undefined,
      q: filters.q?.trim() || undefined,
    }

    if (filters.status === 'FAILED') {
      params.status = 'FAILED'
    } else if (filters.status === 'IN' || filters.status === 'OUT') {
      params.status = 'SUCCESS'
      params.direction = filters.status
    }

    return params
  }

  const fetchData = async () => {
    setLoading(true)
    try {
      const params = buildParams()
      const res = await getTransactions(params)
      setRows(res.data?.rows || [])
      setLastRefresh(new Date())
    } catch (err) {
      console.error('Failed to load transactions', err)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchData()
  }, [filters])

  useEffect(() => {
    const interval = setInterval(fetchData, REFRESH_MS)
    return () => clearInterval(interval)
  }, [filters])

  const handleFilterChange = (field) => (e) => {
    setFilters((prev) => ({ ...prev, [field]: e.target.value }))
    setPage(0)
  }

  const handleExportCsv = async () => {
    try {
      const params = buildParams()
      const res = await exportTransactionsCsv(params)
      downloadBlob(res.data, `${personType.toLowerCase()}_transactions.csv`)
    } catch (err) {
      console.error('CSV export failed', err)
    }
  }

  const handleExportPdf = async () => {
    try {
      const params = buildParams()
      const res = await exportTransactionsPdf(params)
      downloadBlob(res.data, `${personType.toLowerCase()}_transactions.pdf`)
    } catch (err) {
      console.error('PDF export failed', err)
    }
  }

  const sessions = useMemo(() => {
    const sorted = [...rows].sort((a, b) => new Date(a.scan_time || a.entry_time) - new Date(b.scan_time || b.entry_time))
    const open = new Map()
    const completed = []

    sorted.forEach((tx) => {
      if (tx.status === 'FAILED') return
      const personId = tx.visitor_id || tx.labour_id || tx.id || tx.person_id || tx.pass_no
      const key = `${personId}-${tx.pass_no || tx.rfid_token || ''}`
      const base = {
        person_id: personId,
        id: key,
        full_name: tx.full_name || tx.visitor_name || tx.labour_name || '-',
        pass_no: tx.pass_no || tx.visitor_pass_no || '-',
        primary_phone: tx.primary_phone || tx.phone || '-',
        company_name: tx.company_name || tx.company || tx.organization || tx.company_title || '-',
        project_name: tx.project_name || '-',
        department_name: tx.department_name || '-',
        gate_name: tx.gate_name || '-',
      }

      if (tx.direction === 'IN') {
        open.set(key, {
          ...base,
          check_in: tx.scan_time,
          check_out: null,
          gate_in: tx.gate_name || '-',
          gate_out: null,
        })
      } else if (tx.direction === 'OUT') {
        const session = open.get(key)
        if (session) {
          session.check_out = tx.scan_time
          session.gate_out = tx.gate_name || session.gate_in
          completed.push(session)
          open.delete(key)
        } else {
          completed.push({
            ...base,
            check_in: tx.entry_time || null,
            check_out: tx.scan_time,
            gate_in: tx.gate_name || '-',
            gate_out: tx.gate_name || '-',
          })
        }
      }
    })

    return [...completed, ...open.values()]
      .sort((a, b) => new Date(b.check_in || b.check_out) - new Date(a.check_in || a.check_out))
      .map((s, idx) => {
        const stayMs = s.check_in ? (s.check_out ? new Date(s.check_out) - new Date(s.check_in) : now - new Date(s.check_in)) : null
        return {
          ...s,
          time_stayed: stayMs ? formatDuration(stayMs) : '-',
          current_status: s.check_out ? 'Outside' : 'Inside',
          gate_in: s.gate_in,
          gate_out: s.gate_out,
          row_key: `${s.id || 'row'}-${s.check_in || s.check_out || 'open'}-${idx}`
        }
      })
  }, [rows, now])

  const columns = [
    { key: 'full_name', label: personType === 'LABOUR' ? 'Labour' : 'Visitor' },
    { key: 'pass_no', label: 'Pass No' },
    { key: 'primary_phone', label: 'Phone' },
    { key: 'company_name', label: 'Company' },
    { key: 'project_name', label: 'Project' },
    { key: 'department_name', label: 'Department' },
    {
      key: 'gate_name',
      label: 'Gate',
      render: (r) => (r.gate_in && r.gate_out ? `${r.gate_in} -> ${r.gate_out || r.gate_in}` : r.gate_in || r.gate_name || '-'),
    },
    { key: 'check_in', label: 'Check In', render: (r) => formatDateTime(r.check_in) },
    { key: 'check_out', label: 'Check Out', render: (r) => formatDateTime(r.check_out) },
    { key: 'time_stayed', label: 'Time Inside' },
    {
      key: 'current_status',
      label: 'Current Status',
      render: (r) => (
        <Chip
          label={r.current_status}
          color={r.current_status === 'Inside' ? 'success' : 'default'}
          size="small"
          sx={{ fontWeight: 700 }}
        />
      ),
    },
  ]

  const paginatedSessions = useMemo(
    () => sessions.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage),
    [sessions, page, rowsPerPage]
  )

  const handleRowClick = (row) => {
    const id = row.person_id || row.labour_id || row.visitor_id || row.id
    if (id) navigate(`${detailPath}/${id}`)
  }

  return (
    <Container maxWidth="xxl" sx={{ py: 3 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 2, mb: 3, flexWrap: 'wrap' }}>
        <Box>
          <Typography variant="h4" fontWeight={700}>
            {title}
          </Typography>
          <Typography variant="body2" color="text.secondary">
            Live access logs with filters, export, and pagination
          </Typography>
        </Box>
        <Stack direction="row" spacing={1} flexWrap="wrap">
          <Button variant="outlined" startIcon={<RefreshIcon />} onClick={fetchData} disabled={loading}>
            Refresh
          </Button>
          <Button variant="outlined" startIcon={<DownloadIcon />} onClick={handleExportCsv}>
            Export CSV
          </Button>
          <Button variant="contained" startIcon={<DownloadIcon />} onClick={handleExportPdf}>
            Export PDF
          </Button>
        </Stack>
      </Box>

      <Grid container spacing={2} sx={{ mb: 2 }}>

        {/* 🔹 ROW 1 - Core Filters */}
        <Grid size={{ xs: 12, md: 6 }}>
          <TextField
            label="Search"
            placeholder="Name / Phone / Pass / Token"
            value={filters.q}
            onChange={handleFilterChange('q')}
            fullWidth
            size="small"
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <SearchIcon fontSize="small" />
                </InputAdornment>
              ),
            }}
          />
        </Grid>

        <Grid size={{ xs: 6, md: 3 }}>
          <TextField
            label="From"
            type="date"
            value={filters.from_date}
            onChange={handleFilterChange('from_date')}
            fullWidth
            size="small"
            InputLabelProps={{ shrink: true }}
          />
        </Grid>

        <Grid size={{ xs: 6, md: 3 }}>
          <TextField
            label="To"
            type="date"
            value={filters.to_date}
            onChange={handleFilterChange('to_date')}
            fullWidth
            size="small"
            InputLabelProps={{ shrink: true }}
          />
        </Grid>

        {/* 🔹 ROW 2 - Advanced Filters */}
        <Grid size={{ xs: 12, sm: 4 }}>
          <FormControl fullWidth size="small">
            <InputLabel>Project</InputLabel>
            <Select
              label="Project"
              value={filters.project_id}
              onChange={handleFilterChange('project_id')}
            >
              <MenuItem value="">All</MenuItem>
              {projects.map((p) => (
                <MenuItem key={p.id} value={p.id}>
                  {p.project_name}
                </MenuItem>
              ))}
            </Select>
          </FormControl>
        </Grid>

        <Grid size={{ xs: 12, sm: 4 }}>
          <FormControl fullWidth size="small">
            <InputLabel>Department</InputLabel>
            <Select
              label="Department"
              value={filters.department_id}
              onChange={handleFilterChange('department_id')}
            >
              <MenuItem value="">All</MenuItem>
              {departments.map((d) => (
                <MenuItem key={d.id} value={d.id}>
                  {d.department_name}
                </MenuItem>
              ))}
            </Select>
          </FormControl>
        </Grid>

        <Grid size={{ xs: 12, sm: 4 }}>
          <FormControl fullWidth size="small">
            <InputLabel>Gate</InputLabel>
            <Select
              label="Gate"
              value={filters.gate_id}
              onChange={handleFilterChange('gate_id')}
            >
              <MenuItem value="">All</MenuItem>
              {gates.map((g) => (
                <MenuItem key={g.id} value={g.id}>
                  {g.gate_name}
                </MenuItem>
              ))}
            </Select>
          </FormControl>
        </Grid>

      </Grid>

      <Paper variant="outlined" sx={{ borderRadius: 2, overflow: 'hidden', boxShadow: '0 16px 40px rgba(15,23,42,0.08)' }}>
        <TableContainer sx={{ maxHeight: 620 }}>
          <Table size="small" stickyHeader>
            <TableHead>
              <TableRow sx={{ backgroundColor: '#f8fafc' }}>
                {columns.map((col) => (
                  <TableCell key={col.key} sx={{ fontWeight: 700, backgroundColor: '#f8fafc' }}>
                    {col.label}
                  </TableCell>
                ))}
              </TableRow>
            </TableHead>
            <TableBody>
              {sessions.length === 0 && (
                <TableRow>
                  <TableCell colSpan={columns.length} sx={{ textAlign: 'center', py: 5, color: 'text.secondary' }}>
                    No records found.
                  </TableCell>
                </TableRow>
              )}
            {paginatedSessions.map((row, idx) => (
              <TableRow
                key={row.row_key || `${row.id}-${idx}`}
                hover
                sx={{
                  cursor: 'pointer',
                  '&:nth-of-type(odd)': { backgroundColor: '#f9fafb' },
                }}
                  onClick={() => handleRowClick(row)}
                >
                  {columns.map((col) => (
                    <TableCell key={col.key}>
                      {col.render ? col.render(row) : row[col.key] || '-'}
                    </TableCell>
                  ))}
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
        <TablePagination
          component="div"
          count={sessions.length}
          page={page}
          onPageChange={(_, newPage) => setPage(newPage)}
          rowsPerPage={rowsPerPage}
          onRowsPerPageChange={(e) => {
            setRowsPerPage(Number(e.target.value))
            setPage(0)
          }}
          rowsPerPageOptions={[10, 25, 50, 100]}
        />
      </Paper>
    </Container>
  )
}
