import React, { useEffect, useMemo, useState } from 'react'
import {
  Alert,
  Box,
  Button,
  Chip,
  Container,
  Grid,
  IconButton,
  InputAdornment,
  Paper,
  Tab,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Tabs,
  TextField,
  Tooltip,
  Typography,
} from '@mui/material'
import RefreshIcon from '@mui/icons-material/Refresh'
import SearchIcon from '@mui/icons-material/Search'
import PeopleIcon from '@mui/icons-material/People'
import LoginIcon from '@mui/icons-material/Login'
import LogoutIcon from '@mui/icons-material/Logout'
import EngineeringIcon from '@mui/icons-material/Engineering'
import PersonIcon from '@mui/icons-material/Person'
import api from '../api/axios'
import Loader from '../components/common/Loader'

const REFRESH_SECONDS = 10

const formatTime = (value) => {
  if (!value) return '-'
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return '-'
  return date.toLocaleString()
}

const durationMins = (entryTime, isInside) => {
  if (!isInside || !entryTime) return '-'
  const ms = Date.now() - new Date(entryTime).getTime()
  if (ms < 0) return '-'
  return `${Math.floor(ms / 60000)} min`
}

export default function LiveMuster() {
  const [rows, setRows] = useState([])
  const [filter, setFilter] = useState('all')
  const [search, setSearch] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [lastUpdated, setLastUpdated] = useState(null)
  const [autoRefresh, setAutoRefresh] = useState(true)
  const [countdown, setCountdown] = useState(REFRESH_SECONDS)

  const fetchMuster = async () => {
    setLoading(true)
    try {
      const res = await api.get('/reports/live-muster')
      setRows(res?.data?.data || [])
      setLastUpdated(new Date())
      setError('')
      setCountdown(REFRESH_SECONDS)
    } catch (err) {
      setError(err?.response?.data?.error || 'Failed to fetch live muster')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchMuster()
  }, [])

  useEffect(() => {
    if (!autoRefresh) return
    const timer = setInterval(() => {
      setCountdown((prev) => {
        if (prev <= 1) {
          fetchMuster()
          return REFRESH_SECONDS
        }
        return prev - 1
      })
    }, 1000)
    return () => clearInterval(timer)
  }, [autoRefresh])

  /* -------------------- KPIs -------------------- */
  const stats = useMemo(() => {
    const total = rows.length
    const inside = rows.filter((r) => r.current_status === 'IN').length
    const outside = rows.filter((r) => r.current_status === 'OUT').length
    const visitors = rows.filter((r) => r.person_type === 'VISITOR').length
    const labours = rows.filter((r) => r.person_type === 'LABOUR').length
    return { total, inside, outside, visitors, labours }
  }, [rows])

  /* -------------------- Filtering -------------------- */
  const filteredRows = useMemo(() => {
    let data = rows

    if (filter !== 'all') {
      data = data.filter(
        (r) => (r.current_status || '').toLowerCase() === filter
      )
    }

    if (search) {
      const s = search.toLowerCase()
      data = data.filter(
        (r) =>
          r.full_name?.toLowerCase().includes(s) ||
          r.supervisor_name?.toLowerCase().includes(s) ||
          r.project_name?.toLowerCase().includes(s) ||
          r.phone?.includes(s)
      )
    }

    return data
  }, [rows, filter, search])

  if (loading && !rows.length) return <Loader />

  return (
    <Container maxWidth="xl" sx={{ py: 3 }}>
      {/* ---------------- Header ---------------- */}
      <Box
        sx={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          mb: 2,
          flexWrap: 'wrap',
          gap: 1,
        }}
      >
        <Typography variant="h4" fontWeight={700}>
          Live Muster Dashboard
        </Typography>

        <Box sx={{ display: 'flex', gap: 1 }}>
          <Tooltip title="Manual Refresh">
            <IconButton onClick={fetchMuster} disabled={loading} color="primary">
              <RefreshIcon />
            </IconButton>
          </Tooltip>

          <Button
            size="small"
            variant={autoRefresh ? 'contained' : 'outlined'}
            onClick={() => setAutoRefresh((v) => !v)}
          >
            {autoRefresh ? `Auto ${countdown}s` : 'Auto Off'}
          </Button>
        </Box>
      </Box>

      {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}

      {/* ---------------- KPI Cards ---------------- */}
        <Grid container spacing={2} mb={2}>
        <Grid size={{ xs: 12, md: 2.4 }}>
          <KpiCard icon={<PeopleIcon />} label="Total Tracked" value={stats.total} />
        </Grid>
        <Grid size={{ xs: 12, md: 2.4 }}>
          <KpiCard icon={<LoginIcon />} label="Inside" value={stats.inside} color="success.main" />
        </Grid>
        <Grid size={{ xs: 12, md: 2.4 }}>
          <KpiCard icon={<LogoutIcon />} label="Outside" value={stats.outside} color="error.main" />
        </Grid>
        <Grid size={{ xs: 12, md: 2.4 }}>
          <KpiCard icon={<PersonIcon />} label="Visitors" value={stats.visitors} color="primary.main" />
        </Grid>
        <Grid size={{ xs: 12, md: 2.4 }}>
          <KpiCard icon={<EngineeringIcon />} label="Labours" value={stats.labours} color="warning.main" />
        </Grid>
      </Grid>

      {/* ---------------- Filters ---------------- */}
      <Paper sx={{ mb: 2 }}>
        <Tabs value={filter} onChange={(_, v) => setFilter(v)}>
          <Tab label={`All (${stats.total})`} value="all" />
          <Tab label={`Inside (${stats.inside})`} value="in" />
          <Tab label={`Outside (${stats.outside})`} value="out" />
        </Tabs>
      </Paper>

      <TextField
        fullWidth
        size="small"
        placeholder="Search by name, supervisor, project or phone..."
        value={search}
        onChange={(e) => setSearch(e.target.value)}
        sx={{ mb: 2 }}
        InputProps={{
          startAdornment: (
            <InputAdornment position="start">
              <SearchIcon />
            </InputAdornment>
          ),
        }}
      />

      {/* ---------------- Table ---------------- */}
      <TableContainer component={Paper} sx={{ maxHeight: 600 }}>
        <Table stickyHeader size="small">
          <TableHead>
            <TableRow>
              <TableCell>Name</TableCell>
              <TableCell>Type</TableCell>
              <TableCell>Supervisor</TableCell>
              <TableCell>Project</TableCell>
              <TableCell>Phone</TableCell>
              <TableCell>Status</TableCell>
              <TableCell>Gate</TableCell>
              <TableCell>Entry Time</TableCell>
              <TableCell>Last Scan</TableCell>
              
              <TableCell>On-Site Duration</TableCell>
            </TableRow>
          </TableHead>

          <TableBody>
            {!filteredRows.length ? (
              <TableRow>
                <TableCell colSpan={10} align="center">
                  No live records
                </TableCell>
              </TableRow>
            ) : (
              filteredRows.map((row, idx) => (
                <TableRow key={`${row.person_id}-${idx}`} hover>
                  <TableCell>{row.full_name || '-'}</TableCell>

                  <TableCell>
                    <Chip
                      size="small"
                      label={row.person_type || '-'}
                      color={row.person_type === 'LABOUR' ? 'warning' : 'primary'}
                      variant="outlined"
                    />
                  </TableCell>

                  <TableCell>{row.supervisor_name || '-'}</TableCell>
                  <TableCell>{row.project_name || '-'}</TableCell>
                  <TableCell>{row.phone || '-'}</TableCell>

                  <TableCell>
                    <Chip
                      size="small"
                      label={row.current_status || '-'}
                      color={row.current_status === 'IN' ? 'success' : 'default'}
                    />
                  </TableCell>

                  <TableCell>{row.gate_name || '-'}</TableCell>
                  <TableCell>{formatTime(row.last_scan_time)}</TableCell>
                  <TableCell>{formatTime(row.entry_time)}</TableCell>
                  <TableCell>
                    {durationMins(row.entry_time, row.current_status === 'IN')}
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </TableContainer>

      {/* ---------------- Footer ---------------- */}
      <Box sx={{ mt: 1.5, textAlign: 'right' }}>
        <Typography variant="caption" color="text.secondary">
          {lastUpdated
            ? `Last updated: ${lastUpdated.toLocaleTimeString()}`
            : 'Not updated yet'}
        </Typography>
      </Box>
    </Container>
  )
}

/* ---------------- KPI Card Component ---------------- */
const KpiCard = ({ icon, label, value, color }) => (
  <Paper
    sx={{
      p: 2,
      display: 'flex',
      alignItems: 'center',
      gap: 2,
      borderLeft: color ? `4px solid` : '4px solid transparent',
      borderColor: color || 'divider',
    }}
  >
    <Box sx={{ color: color || 'text.secondary' }}>{icon}</Box>
    <Box>
      <Typography variant="h5" fontWeight={700} color={color}>
        {value}
      </Typography>
      <Typography variant="caption">{label}</Typography>
    </Box>
  </Paper>
)
