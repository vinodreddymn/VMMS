import React, { useEffect, useMemo, useState } from 'react'
import {
  Box,
  Button,
  Chip,
  Container,
  Divider,
  Grid,
  InputAdornment,
  Paper,
  Stack,
  Tab,
  Tabs,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  TextField,
  Typography,
} from '@mui/material'
import RefreshIcon from '@mui/icons-material/Refresh'
import TimelapseIcon from '@mui/icons-material/Timelapse'
import SearchIcon from '@mui/icons-material/Search'
import PeopleIcon from '@mui/icons-material/People'
import EngineeringIcon from '@mui/icons-material/Engineering'
import { useNavigate } from 'react-router-dom'
import useAuthStore from '../store/auth.store'
import api from '../api/axios'

// Import Dashboard Components
import LiveMusterCard from '../components/dashboard/LiveMusterCard'
import EntryFeed from '../components/dashboard/EntryFeed'
import GateLoadChart from '../components/dashboard/GateLoadChart'
import RiskPanel from '../components/dashboard/RiskPanel'

const REFRESH_MS = 30000

const formatDateTime = (value) => {
  if (!value) return '-'
  const d = new Date(value)
  if (Number.isNaN(d.getTime())) return '-'
  return d.toLocaleString()
}

const formatTimeOnly = (value) => {
  if (!value) return '-'
  const d = new Date(value)
  if (Number.isNaN(d.getTime())) return '-'
  return d.toLocaleTimeString()
}

const formatDuration = (ms) => {
  if (!Number.isFinite(ms) || ms < 0) return '-'
  const totalMinutes = Math.floor(ms / 60000)
  const hours = Math.floor(totalMinutes / 60)
  const minutes = totalMinutes % 60
  if (hours <= 0) return `${minutes}m`
  return `${hours}h ${minutes}m`
}

const todayISO = () => new Date().toISOString().split('T')[0]

export default function Dashboard() {
  const user = useAuthStore((s) => s.user)
  const logout = useAuthStore((s) => s.logout)
  const navigate = useNavigate()

  const [loading, setLoading] = useState(false)
  const [lastRefresh, setLastRefresh] = useState(new Date())
  const [summary, setSummary] = useState(null)
  const [projectStats, setProjectStats] = useState([])
  const [muster, setMuster] = useState([])
  const [visitorTx, setVisitorTx] = useState([])
  const [labourTx, setLabourTx] = useState([])
  const [now, setNow] = useState(new Date())

  const [personTab, setPersonTab] = useState(0)
  const [visitorStatusTab, setVisitorStatusTab] = useState(0)
  const [labourStatusTab, setLabourStatusTab] = useState(0)

  const [searchQuery, setSearchQuery] = useState('')
  const [searchLoading, setSearchLoading] = useState(false)
  const [searchResults, setSearchResults] = useState([])

  useEffect(() => {
    fetchDashboardData()
    const interval = setInterval(fetchDashboardData, REFRESH_MS)
    return () => clearInterval(interval)
  }, [])

  useEffect(() => {
    const timer = setInterval(() => setNow(new Date()), 30000)
    return () => clearInterval(timer)
  }, [])

  const fetchDashboardData = async () => {
    setLoading(true)
    const today = todayISO()
    const fromDate = '1970-01-01'
    try {
      const results = await Promise.allSettled([
        api.get('/public/andon/summary'),
        api.get('/public/andon/transactions?limit=200'),
        api.get('/analytics/muster'),
        api.get(`/analytics/project-stats?from_date=${fromDate}&to_date=${today}`),
      ])

      const [summaryRes, txRes, musterRes, projectRes] = results

      if (summaryRes.status === 'fulfilled') {
        setSummary(summaryRes.value?.data || null)
      }
      if (txRes.status === 'fulfilled') {
        setVisitorTx(txRes.value?.data?.visitors || [])
        setLabourTx(txRes.value?.data?.labours || [])
      }
      if (musterRes.status === 'fulfilled') {
        setMuster(musterRes.value?.data?.data || [])
      }
      if (projectRes.status === 'fulfilled') {
        setProjectStats(projectRes.value?.data?.projectStats || [])
      }
      setLastRefresh(new Date())
    } catch (err) {
      console.error('Failed to fetch dashboard data:', err)
    } finally {
      setLoading(false)
    }
  }

  const totalVisitorsRegistered = useMemo(() => {
    return projectStats.reduce((sum, row) => sum + Number(row.total_visitors_registered || 0), 0)
  }, [projectStats])

  const liveProjectCounts = useMemo(() => {
    const map = new Map()
    muster.forEach((row) => {
      if (row.current_status !== 'IN') return
      const name = row.project_name || 'Unassigned'
      if (!map.has(name)) {
        map.set(name, { project_name: name, visitors: 0, labours: 0 })
      }
      const entry = map.get(name)
      if (row.person_type === 'VISITOR') entry.visitors += 1
      if (row.person_type === 'LABOUR') entry.labours += 1
    })
    return Array.from(map.values()).sort(
      (a, b) => (b.visitors + b.labours) - (a.visitors + a.labours)
    )
  }, [muster])

  const visitorCheckedIn = useMemo(
    () => visitorTx.filter((row) => row.direction === 'IN'),
    [visitorTx]
  )
  const visitorCheckedOut = useMemo(
    () => muster.filter((row) => row.person_type === 'VISITOR' && row.current_status === 'OUT'),
    [muster]
  )
  const visitorInside = useMemo(
    () => muster.filter((row) => row.person_type === 'VISITOR' && row.current_status === 'IN'),
    [muster]
  )

  const labourCheckedIn = useMemo(
    () => labourTx.filter((row) => row.direction === 'IN'),
    [labourTx]
  )
  const labourCheckedOut = useMemo(
    () => muster.filter((row) => row.person_type === 'LABOUR' && row.current_status === 'OUT'),
    [muster]
  )
  const labourInside = useMemo(
    () => muster.filter((row) => row.person_type === 'LABOUR' && row.current_status === 'IN'),
    [muster]
  )

  const handleVisitorRowClick = (row) => {
    const id = row.visitor_id || row.person_id || row.id
    if (id) navigate(`/visitors/${id}`)
  }

  const handleSearch = async (e) => {
    e.preventDefault()
    const q = searchQuery.trim()
    if (!q) {
      setSearchResults([])
      return
    }
    setSearchLoading(true)
    try {
      const params = {}
      if (/^\d{4}$/.test(q)) {
        params.aadhaar_last4 = q
      } else if (/^\d{8,}$/.test(q)) {
        params.phone = q
      } else {
        params.name = q
      }
      const res = await api.get('/analytics/search', { params })
      setSearchResults(res?.data?.visitors || [])
    } catch (err) {
      console.error('Search failed:', err)
      setSearchResults([])
    } finally {
      setSearchLoading(false)
    }
  }

  const visitors = summary?.visitors || {}
  const labours = summary?.labours || {}

  return (
    <Container maxWidth="xl" sx={{ py: 3 }}>
      {/* Header */}




      {/* Overview + KPIs */}
      <Grid container spacing={2} sx={{ mb: 3 }}>
        <Grid size={{ xs: 12, md: 4 }}>
          <Paper
            elevation={0}
            sx={{
              p: 2.5,
              background: 'linear-gradient(135deg, #0f172a 0%, #1e293b 100%)',
              color: 'white',
              borderRadius: 2,
              height: '100%',
            }}
          >
            <Typography variant="caption" sx={{ opacity: 0.85, letterSpacing: 1 }}>
              TOTAL VISITORS REGISTERED
            </Typography>
            <Typography variant="h3" fontWeight={800} sx={{ mt: 1 }}>
              {totalVisitorsRegistered}
            </Typography>
            <Typography variant="caption" sx={{ opacity: 0.7 }}>
              All-time registrations in the system
            </Typography>
          </Paper>
        </Grid>

        <Grid size={{ xs: 12, md: 4 }}>
          <Paper
            elevation={0}
            sx={{
              p: 2.5,
              background: 'linear-gradient(135deg, #1d4ed8 0%, #2563eb 100%)',
              color: 'white',
              borderRadius: 2,
              height: '100%',
            }}
          >
            <Stack direction="row" spacing={1} alignItems="center">
              <PeopleIcon />
              <Typography variant="subtitle1" fontWeight={700}>
                Visitors (Today)
              </Typography>
            </Stack>
            <Grid container spacing={1.2} sx={{ mt: 1 }}>
              <Grid size={{ xs: 6 }}>
                <Kpi label="Total Entries" value={visitors.total_visitors || 0} />
              </Grid>
              <Grid size={{ xs: 6 }}>
                <Kpi label="Unique" value={visitors.unique_visitors || 0} />
              </Grid>
              <Grid size={{ xs: 6 }}>
                <Kpi label="Inside" value={visitors.visitors_inside || 0} />
              </Grid>
              <Grid size={{ xs: 6 }}>
                <Kpi label="Exited" value={visitors.visitors_exited || 0} />
              </Grid>
            </Grid>
          </Paper>
        </Grid>

        <Grid size={{ xs: 12, md: 4 }}>
          <Paper
            elevation={0}
            sx={{
              p: 2.5,
              background: 'linear-gradient(135deg, #f59e0b 0%, #f97316 100%)',
              color: '#1f2937',
              borderRadius: 2,
              height: '100%',
            }}
          >
            <Stack direction="row" spacing={1} alignItems="center">
              <EngineeringIcon />
              <Typography variant="subtitle1" fontWeight={700}>
                Labours (Today)
              </Typography>
            </Stack>
            <Grid container spacing={1.2} sx={{ mt: 1 }}>
              <Grid size={{ xs: 6 }}>
                <Kpi label="Registered" value={labours.registered || 0} dark />
              </Grid>
              <Grid size={{ xs: 6 }}>
                <Kpi label="Checked In" value={labours.checked_in || 0} dark />
              </Grid>
              <Grid size={{ xs: 6 }}>
                <Kpi label="Checked Out" value={labours.checked_out || 0} dark />
              </Grid>
              <Grid size={{ xs: 6 }}>
                <Kpi label="Inside" value={labours.labours_inside || 0} dark />
              </Grid>
            </Grid>
          </Paper>
        </Grid>
      </Grid>

      {/* Live Project Load */}
      <Paper elevation={0} sx={{ p: 2.5, mb: 3, borderRadius: 2, border: '1px solid rgba(15,23,42,0.08)' }}>
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 2, mb: 2 }}>
          <Typography variant="h6" fontWeight={700}>
            Live Numbers by Project (Inside Now)
          </Typography>
          <Chip label={`Updated ${formatTimeOnly(lastRefresh)}`} size="small" />
        </Box>
        {liveProjectCounts.length === 0 ? (
          <Typography color="text.secondary">No live project activity.</Typography>
        ) : (
          <Stack direction="row" spacing={1} flexWrap="wrap">
            {liveProjectCounts.map((p) => (
              <Chip
                key={p.project_name}
                label={`${p.project_name}: ${p.visitors + p.labours} (Visitors: ${p.visitors} / Labourers: ${p.labours})`}
                color="info"
                variant="outlined"
                sx={{ mb: 1 }}
              />
            ))}
          </Stack>
        )}
      </Paper>

      {/* Activity Tabs */}
      <Paper elevation={0} sx={{ p: 2.5, mb: 3, borderRadius: 2, border: '1px solid rgba(15,23,42,0.08)' }}>
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 2 }}>
          <Typography variant="h6" fontWeight={700}>
            Live Access Overview
          </Typography>
          <Tabs value={personTab} onChange={(_, v) => setPersonTab(v)}>
            <Tab label="Visitors" />
            <Tab label="Labours" />
          </Tabs>
        </Box>

        {personTab === 0 && (
          <>
            <Tabs value={visitorStatusTab} onChange={(_, v) => setVisitorStatusTab(v)} sx={{ mb: 2 }}>
              <Tab label="Checked In (Today)" />
              <Tab label="Checked Out" />
              <Tab label="Still Inside" />
            </Tabs>

            {visitorStatusTab === 0 && (
              <DataTable
                rows={visitorCheckedIn}
                emptyText="No visitor check-ins yet."
                columns={[
                  { key: 'full_name', label: 'Visitor' },
                  { key: 'project_name', label: 'Project' },
                  { key: 'scan_time', label: 'Check-in Time', render: (v) => formatDateTime(v.scan_time) },
                  { key: 'elapsed', label: 'Elapsed', render: (v) => formatDuration(now - new Date(v.scan_time)) },
                  { key: 'gate_name', label: 'Gate' },
                ]}
                onRowClick={handleVisitorRowClick}
              />
            )}

            {visitorStatusTab === 1 && (
              <DataTable
                rows={visitorCheckedOut}
                emptyText="No visitor check-outs."
                columns={[
                  { key: 'full_name', label: 'Visitor' },
                  { key: 'project_name', label: 'Project' },
                  { key: 'entry_time', label: 'Check-in', render: (v) => formatDateTime(v.entry_time) },
                  { key: 'last_scan_time', label: 'Check-out', render: (v) => formatDateTime(v.last_scan_time) },
                  {
                    key: 'duration',
                    label: 'Time Inside',
                    render: (v) => formatDuration(new Date(v.last_scan_time) - new Date(v.entry_time)),
                  },
                ]}
                onRowClick={handleVisitorRowClick}
              />
            )}

            {visitorStatusTab === 2 && (
              <DataTable
                rows={visitorInside}
                emptyText="No visitors currently inside."
                columns={[
                  { key: 'full_name', label: 'Visitor' },
                  { key: 'project_name', label: 'Project' },
                  { key: 'entry_time', label: 'Check-in', render: (v) => formatDateTime(v.entry_time) },
                  {
                    key: 'elapsed',
                    label: 'Elapsed',
                    render: (v) => formatDuration(now - new Date(v.entry_time)),
                  },
                  { key: 'gate_name', label: 'Gate' },
                ]}
                onRowClick={handleVisitorRowClick}
              />
            )}
          </>
        )}

        {personTab === 1 && (
          <>
            <Tabs value={labourStatusTab} onChange={(_, v) => setLabourStatusTab(v)} sx={{ mb: 2 }}>
              <Tab label="Checked In (Today)" />
              <Tab label="Checked Out" />
              <Tab label="Still Inside" />
            </Tabs>

            {labourStatusTab === 0 && (
              <DataTable
                rows={labourCheckedIn}
                emptyText="No labour check-ins yet."
                columns={[
                  { key: 'full_name', label: 'Labour' },
                  { key: 'supervisor_name', label: 'Supervisor' },
                  { key: 'project_name', label: 'Project' },
                  { key: 'scan_time', label: 'Check-in Time', render: (v) => formatDateTime(v.scan_time) },
                  { key: 'elapsed', label: 'Elapsed', render: (v) => formatDuration(now - new Date(v.scan_time)) },
                ]}
              />
            )}

            {labourStatusTab === 1 && (
              <DataTable
                rows={labourCheckedOut}
                emptyText="No labour check-outs."
                columns={[
                  { key: 'full_name', label: 'Labour' },
                  { key: 'supervisor_name', label: 'Supervisor' },
                  { key: 'project_name', label: 'Project' },
                  { key: 'entry_time', label: 'Check-in', render: (v) => formatDateTime(v.entry_time) },
                  { key: 'last_scan_time', label: 'Check-out', render: (v) => formatDateTime(v.last_scan_time) },
                  {
                    key: 'duration',
                    label: 'Time Inside',
                    render: (v) => formatDuration(new Date(v.last_scan_time) - new Date(v.entry_time)),
                  },
                ]}
              />
            )}

            {labourStatusTab === 2 && (
              <DataTable
                rows={labourInside}
                emptyText="No labours currently inside."
                columns={[
                  { key: 'full_name', label: 'Labour' },
                  { key: 'supervisor_name', label: 'Supervisor' },
                  { key: 'project_name', label: 'Project' },
                  { key: 'entry_time', label: 'Check-in', render: (v) => formatDateTime(v.entry_time) },
                  { key: 'elapsed', label: 'Elapsed', render: (v) => formatDuration(now - new Date(v.entry_time)) },
                ]}
              />
            )}
          </>
        )}
      </Paper>

      {/* Visitor History Search */}
      <Paper elevation={0} sx={{ p: 2.5, mb: 3, borderRadius: 2, border: '1px solid rgba(15,23,42,0.08)' }}>
        <Typography variant="h6" fontWeight={700} sx={{ mb: 1 }}>
          Visitor History Search
        </Typography>
        <Box component="form" onSubmit={handleSearch} sx={{ display: 'flex', gap: 1, flexWrap: 'wrap', mb: 2 }}>
          <TextField
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search by name, phone, or Aadhaar last 4"
            size="small"
            sx={{ minWidth: 320, flex: 1 }}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <SearchIcon fontSize="small" />
                </InputAdornment>
              ),
            }}
          />
          <Button type="submit" variant="contained" disabled={searchLoading}>
            {searchLoading ? 'Searching...' : 'Search'}
          </Button>
        </Box>

        <DataTable
          rows={searchResults}
          emptyText="Search for a visitor to view history."
          columns={[
            { key: 'full_name', label: 'Visitor' },
            { key: 'project_name', label: 'Project' },
            { key: 'primary_phone', label: 'Phone' },
            { key: 'aadhaar_last4', label: 'Aadhaar (Last 4)' },
            { key: 'status', label: 'Status' },
          ]}
          onRowClick={handleVisitorRowClick}
        />
      </Paper>

      {/* Existing Features (Moved Down) */}
      <Typography variant="h6" fontWeight={700} sx={{ mb: 2 }}>
        More Insights
      </Typography>
      <Grid container spacing={3}>
        <Grid size={{ xs: 12, md: 6 }}>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
            <LiveMusterCard />
            <EntryFeed />
          </Box>
        </Grid>
        <Grid size={{ xs: 12, md: 6 }}>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
            <RiskPanel />
            <GateLoadChart />
          </Box>
        </Grid>
      </Grid>
    </Container>
  )
}

function Kpi({ label, value, dark }) {
  return (
    <Box sx={{ p: 1, borderRadius: 1.5, background: 'rgba(255,255,255,0.15)' }}>
      <Typography variant="caption" sx={{ opacity: dark ? 0.8 : 0.9 }}>
        {label}
      </Typography>
      <Typography variant="h6" fontWeight={800}>
        {value}
      </Typography>
    </Box>
  )
}

function DataTable({ rows, columns, emptyText, onRowClick }) {
  return (
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
              <TableCell colSpan={columns.length} sx={{ textAlign: 'center', py: 4, color: 'text.secondary' }}>
                {emptyText}
              </TableCell>
            </TableRow>
          )}
          {rows.map((row, idx) => (
            <TableRow
              key={row.id || row.access_log_id || idx}
              hover={Boolean(onRowClick)}
              onClick={() => onRowClick && onRowClick(row)}
              sx={{ cursor: onRowClick ? 'pointer' : 'default' }}
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
    </Paper>
  )
}
