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
  const [total, setTotal] = useState(0)
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
      page: page + 1,
      limit: rowsPerPage,
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
      setTotal(res.data?.total || 0)
      setLastRefresh(new Date())
    } catch (err) {
      console.error('Failed to load transactions', err)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchData()
  }, [page, rowsPerPage, filters])

  useEffect(() => {
    const interval = setInterval(fetchData, REFRESH_MS)
    return () => clearInterval(interval)
  }, [page, rowsPerPage, filters])

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

  const columns = useMemo(() => {
    if (personType === 'LABOUR') {
      return [
        { key: 'scan_time', label: 'Scan Time', render: (r) => formatDateTime(r.scan_time) },
        { key: 'direction', label: 'Dir' },
        { key: 'status', label: 'Status' },
        { key: 'full_name', label: 'Labour' },
        { key: 'supervisor_name', label: 'Supervisor' },
        { key: 'project_name', label: 'Project' },
        { key: 'department_name', label: 'Department' },
        { key: 'gate_name', label: 'Gate' },
        {
          key: 'elapsed',
          label: 'Elapsed',
          render: (r) => {
            if (!r.entry_time || r.status === 'FAILED') return '-'
            if (r.direction === 'IN') return formatDuration(now - new Date(r.entry_time))
            return formatDuration(new Date(r.scan_time) - new Date(r.entry_time))
          },
        },
      ]
    }
    return [
      { key: 'scan_time', label: 'Scan Time', render: (r) => formatDateTime(r.scan_time) },
      { key: 'direction', label: 'Dir' },
      { key: 'status', label: 'Status' },
      { key: 'full_name', label: 'Visitor' },
      { key: 'pass_no', label: 'Pass No' },
      { key: 'primary_phone', label: 'Phone' },
      { key: 'project_name', label: 'Project' },
      { key: 'department_name', label: 'Department' },
      { key: 'gate_name', label: 'Gate' },
      {
        key: 'elapsed',
        label: 'Elapsed',
        render: (r) => {
          if (!r.entry_time || r.status === 'FAILED') return '-'
          if (r.direction === 'IN') return formatDuration(now - new Date(r.entry_time))
          return formatDuration(new Date(r.scan_time) - new Date(r.entry_time))
        },
      },
    ]
  }, [personType, now])

  const handleRowClick = (row) => {
    if (personType === 'LABOUR') {
      const id = row.labour_id || row.id
      if (id) navigate(`${detailPath}/${id}`)
    } else {
      const id = row.visitor_id || row.id
      if (id) navigate(`${detailPath}/${id}`)
    }
  }

  return (
    <Container maxWidth="xl" sx={{ py: 3 }}>
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

      <Paper elevation={0} sx={{ p: 2.5, mb: 3, borderRadius: 2, border: '1px solid rgba(15,23,42,0.08)' }}>
        <Grid container spacing={2}>
          <Grid size={{ xs: 12, md: 3 }}>
          <TextField
            label="Search"
            placeholder="Name / phone / pass / token"
            value={filters.q}
            onChange={handleFilterChange('q')}
            fullWidth
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <SearchIcon fontSize="small" />
                </InputAdornment>
              ),
            }}
          />
          </Grid>
          <Grid size={{ xs: 6, md: 2 }}>
            <TextField
              label="From"
              type="date"
              value={filters.from_date}
              onChange={handleFilterChange('from_date')}
              fullWidth
              InputLabelProps={{ shrink: true }}
            />
          </Grid>
          <Grid size={{ xs: 6, md: 2 }}>
            <TextField
              label="To"
              type="date"
              value={filters.to_date}
              onChange={handleFilterChange('to_date')}
              fullWidth
              InputLabelProps={{ shrink: true }}
            />
          </Grid>
          <Grid size={{ xs: 6, md: 2 }}>
            <FormControl fullWidth>
              <InputLabel>Status</InputLabel>
              <Select label="Status" value={filters.status} onChange={handleFilterChange('status')}>
                <MenuItem value="ALL">All</MenuItem>
                <MenuItem value="IN">IN</MenuItem>
                <MenuItem value="OUT">OUT</MenuItem>
                <MenuItem value="FAILED">FAILED</MenuItem>
              </Select>
            </FormControl>
          </Grid>
          <Grid size={{ xs: 6, md: 3 }}>
            <FormControl fullWidth>
              <InputLabel>Project</InputLabel>
              <Select label="Project" value={filters.project_id} onChange={handleFilterChange('project_id')}>
                <MenuItem value="">All</MenuItem>
                {projects.map((p) => (
                  <MenuItem key={p.id} value={p.id}>
                    {p.project_name}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
          </Grid>
          <Grid size={{ xs: 6, md: 3 }}>
            <FormControl fullWidth>
              <InputLabel>Department</InputLabel>
              <Select label="Department" value={filters.department_id} onChange={handleFilterChange('department_id')}>
                <MenuItem value="">All</MenuItem>
                {departments.map((d) => (
                  <MenuItem key={d.id} value={d.id}>
                    {d.department_name}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
          </Grid>
          <Grid size={{ xs: 6, md: 3 }}>
            <FormControl fullWidth>
              <InputLabel>Gate</InputLabel>
              <Select label="Gate" value={filters.gate_id} onChange={handleFilterChange('gate_id')}>
                <MenuItem value="">All</MenuItem>
                {gates.map((g) => (
                  <MenuItem key={g.id} value={g.id}>
                    {g.gate_name}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
          </Grid>
          <Grid size={{ xs: 12, md: 2 }}>
            <Box sx={{ display: 'flex', justifyContent: 'flex-end', alignItems: 'center', height: '100%' }}>
              <Chip label={`Updated ${lastRefresh.toLocaleTimeString()}`} size="small" />
            </Box>
          </Grid>
        </Grid>
      </Paper>

      <Paper variant="outlined" sx={{ borderRadius: 2, overflow: 'hidden' }}>
        <Table size="small">
          <TableHead>
            <TableRow>
              {columns.map((col) => (
                <TableCell key={col.key} sx={{ fontWeight: 700 }}>
                  {col.label}
                </TableCell>
              ))}
            </TableRow>
          </TableHead>
          <TableBody>
            {rows.length === 0 && (
              <TableRow>
                <TableCell colSpan={columns.length} sx={{ textAlign: 'center', py: 5, color: 'text.secondary' }}>
                  No records found.
                </TableCell>
              </TableRow>
            )}
            {rows.map((row) => (
              <TableRow
                key={row.access_log_id}
                hover
                sx={{ cursor: 'pointer' }}
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
        <TablePagination
          component="div"
          count={total}
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
