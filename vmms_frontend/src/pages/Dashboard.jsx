import React, { useEffect, useMemo, useState } from 'react'
import {
  Box,
  Button,
  Chip,
  Grid,
  InputAdornment,
  Paper,
  Stack,
  Card,
  CardContent,
  Table,
  TableBody,
  TableContainer,
  TableCell,
  TableHead,
  TableRow,
  TextField,
  Typography,
  Collapse,
  IconButton,
  Alert,
} from '@mui/material'
import RefreshIcon from '@mui/icons-material/Refresh'
import TimelapseIcon from '@mui/icons-material/Timelapse'
import SearchIcon from '@mui/icons-material/Search'
import PeopleIcon from '@mui/icons-material/People'
import EngineeringIcon from '@mui/icons-material/Engineering'
import PictureAsPdfIcon from '@mui/icons-material/PictureAsPdf'
import ExpandMoreIcon from '@mui/icons-material/ExpandMore'
import ExpandLessIcon from '@mui/icons-material/ExpandLess'
import TrendingUpIcon from '@mui/icons-material/TrendingUp'
import BuildIcon from '@mui/icons-material/Build'
import { useNavigate } from 'react-router-dom'
import useAuthStore from '../store/auth.store'
import api from '../api/axios'
import labourApi from '../api/labour.api'
import analyticsApi from '../api/analytics.api'

// Import Dashboard Components
import GateLoadChart from '../components/dashboard/GateLoadChart'

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
const defaultAnalyticsFromDate = () => {
  const d = new Date()
  d.setDate(d.getDate() - 7)
  return d.toISOString().split('T')[0]
}
const defaultAnalyticsToDate = () => new Date().toISOString().split('T')[0]

// Try to resolve project name from manifest/supervisor payloads
const resolveProjectName = (row = {}) => {
  const candidate =
    row.project_name ||
    row.projectName ||
    row.projectTitle ||
    (typeof row.project === 'string' ? row.project : null) ||
    row.project?.name ||
    row.project?.project_name ||
    row.project?.projectName ||
    row.project?.projectTitle ||
    row.project?.title ||
    row.project?.code ||
    row.project_title ||
    row.projectTitle ||
    row.project_code ||
    row.projectId ||
    row.project_id ||
    row.project_details?.name ||
    row.project_details?.project_name ||
    row.supervisor_project_name ||
    row.supervisor?.project_name ||
    row.supervisor?.projectName ||
    row.supervisor?.project ||
    row.supervisor_project?.name

  return candidate || '-'
}

// Resolve supervisor company across various payload shapes
const resolveSupervisorCompany = (row = {}) => {
  const candidate =
    row.supervisor_company ||
    row.supervisor_company_name ||
    row.company_name ||
    row.company ||
    row.supervisor?.company_name ||
    row.supervisor?.company

  return candidate || '-'
}

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
  const [labourManifests, setLabourManifests] = useState([])
  const [labourManifestError, setLabourManifestError] = useState(null)
  const [now, setNow] = useState(new Date())

  const [personTab, setPersonTab] = useState(0)
  const [visitorStatusTab, setVisitorStatusTab] = useState(0)
  const [labourStatusTab, setLabourStatusTab] = useState(0)

  const [searchQuery, setSearchQuery] = useState('')
  const [searchLoading, setSearchLoading] = useState(false)
  const [searchResults, setSearchResults] = useState([])

  // Collapsible sections
  const [openOverview, setOpenOverview] = useState(true)
  const [openProjects, setOpenProjects] = useState(true)
  const [openManifests, setOpenManifests] = useState(true)
  const [openAccess, setOpenAccess] = useState(true)
  const [openHistory, setOpenHistory] = useState(true)
  const [openGates, setOpenGates] = useState(true)
  const [openAnalytics, setOpenAnalytics] = useState(true)

  // Extended analytics (date range)
  const [fromDate, setFromDate] = useState(defaultAnalyticsFromDate())
  const [toDate, setToDate] = useState(defaultAnalyticsToDate())
  const [dailyStats, setDailyStats] = useState({})
  const [peakHours, setPeakHours] = useState([])
  const [gatePerformance, setGatePerformance] = useState([])
  const [visitorTrends, setVisitorTrends] = useState([])
  const [analyticsLoading, setAnalyticsLoading] = useState(false)
  const [analyticsError, setAnalyticsError] = useState('')

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
        api.get(`/public/andon/summary?date=${today}`),
        api.get(`/public/andon/transactions?date=${today}&limit=200`),
        api.get(`/analytics/muster?date=${today}`),
        api.get(`/analytics/project-stats?from_date=${fromDate}&to_date=${today}`),
        labourApi.getLabourAnalytics(today),
      ])

      const [summaryRes, txRes, musterRes, projectRes, labourAnalyticsRes] = results

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
      if (labourAnalyticsRes.status === 'fulfilled') {
        const manifests = (labourAnalyticsRes.value?.data?.manifests || []).map((m) => ({
          ...m,
          // Populate project_name so tables render even when backend omits it
          project_name: resolveProjectName(m),
        }))
        setLabourManifests(manifests)
        setLabourManifestError(null)
      } else {
        setLabourManifests([])
        setLabourManifestError('Unable to load today\'s labour manifests')
      }
      setLastRefresh(new Date())
    } catch (err) {
      console.error('Failed to fetch dashboard data:', err)
    } finally {
      setLoading(false)
    }
  }

  const fetchExtendedAnalytics = async () => {
    setAnalyticsLoading(true)
    setAnalyticsError('')
    try {
      const [daily, peaks, gates, trends] = await Promise.all([
        analyticsApi.getDailyStats(fromDate, toDate).catch(() => ({})),
        analyticsApi.getPeakHours(fromDate, toDate).catch(() => ({ data: { peakHours: [] } })),
        analyticsApi.getGatePerformance(fromDate, toDate).catch(() => ({ data: { gatePerformance: [] } })),
        analyticsApi.getVisitorTrends(fromDate, toDate).catch(() => ({ data: { trends: [] } })),
      ])

      setDailyStats(daily?.data?.stats || {})
      setPeakHours(peaks?.data?.peakHours || [])
      setGatePerformance(gates?.data?.gatePerformance || [])
      setVisitorTrends(trends?.data?.trends || [])
    } catch (err) {
      setAnalyticsError('Failed to load analytics data')
    } finally {
      setAnalyticsLoading(false)
    }
  }

  useEffect(() => {
    fetchExtendedAnalytics()
  }, [fromDate, toDate])

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
    () => visitorTx.filter((row) => row.direction === 'OUT'),
    [visitorTx]
  )
  const visitorInside = useMemo(
    () => muster.filter((row) => row.person_type === 'VISITOR' && row.current_status === 'IN'),
    [muster]
  )

  // Build per-visit rows (IN+OUT paired) so repeat visits create multiple rows
  const visitorVisitRows = useMemo(() => {
    if (!visitorTx.length) return []

    const visits = []
    const byVisitor = new Map()

    // Oldest first to pair IN before OUT
    const sorted = [...visitorTx].sort(
      (a, b) =>
        new Date(a.scan_time || a.last_scan_time || a.entry_time || 0) -
        new Date(b.scan_time || b.last_scan_time || b.entry_time || 0)
    )

    sorted.forEach((row) => {
      const id = row.person_id || row.visitor_id || row.id || row.aadhaar_last4 || row.primary_phone
      if (!id) return

      const state = byVisitor.get(id) || { open: null }
      const checkInTime = row.entry_time || row.scan_time || row.last_scan_time || null

      if (row.direction === 'IN') {
        // If a prior visit was still open, keep it as an unchecked-out row
        if (state.open) visits.push(state.open)

        state.open = {
          ...row,
          gate_in_name: row.gate_name,
          check_in_time: checkInTime,
          check_out_time: null,
          status: 'Checked In',
        }
      } else if (row.direction === 'OUT') {
        if (state.open) {
          visits.push({
            ...state.open,
            gate_out_name: row.gate_name,
            check_out_time: row.last_scan_time || row.scan_time || state.open.check_out_time || null,
            status: 'Checked Out',
          })
          state.open = null
        } else {
          // Unpaired OUT still surfaces as a single visit row
          visits.push({
            ...row,
            gate_in_name: row.gate_name,
            gate_out_name: row.gate_name,
            check_in_time: null,
            check_out_time: row.last_scan_time || row.scan_time || null,
            status: 'Checked Out',
          })
        }
      }

      byVisitor.set(id, state)
    })

    // Add any visitors still inside
    byVisitor.forEach(({ open }) => {
      if (open) visits.push(open)
    })

    return visits.sort(
      (a, b) =>
        new Date(b.check_in_time || b.check_out_time || 0) -
        new Date(a.check_in_time || a.check_out_time || 0)
    )
  }, [visitorTx])

  const labourCheckedIn = useMemo(
    () => labourTx.filter((row) => row.direction === 'IN'),
    [labourTx]
  )
  const labourCheckedOut = useMemo(
    () => labourTx.filter((row) => row.direction === 'OUT'),
    [labourTx]
  )
  const labourInside = useMemo(
    () => muster.filter((row) => row.person_type === 'LABOUR' && row.current_status === 'IN'),
    [muster]
  )

  const gateSummary = useMemo(() => {
    if (!gatePerformance.length) return { total: 0, failed: 0, successRate: 0, busiest: null }
    const total = gatePerformance.reduce((sum, g) => sum + Number(g.total_scans || 0), 0)
    const failed = gatePerformance.reduce((sum, g) => sum + Number(g.failed_scans || 0), 0)
    const success = gatePerformance.reduce((sum, g) => sum + Number(g.successful_scans || 0), 0)
    const successRate = total ? Math.round((success / total) * 100) : 0
    const busiest = [...gatePerformance].sort((a, b) => (b.total_scans || 0) - (a.total_scans || 0))[0]
    return { total, failed, successRate, busiest }
  }, [gatePerformance])

  const peakHighlight = useMemo(() => {
    if (!peakHours.length) return null
    return [...peakHours].sort((a, b) => (b.total_scans || 0) - (a.total_scans || 0))[0]
  }, [peakHours])

  // Build per-visit rows for labours (IN+OUT paired) so multiple visits show multiple rows
  const labourVisitRows = useMemo(() => {
    if (!labourTx.length) return []

    const visits = []
    const byLabour = new Map()

    const sorted = [...labourTx].sort(
      (a, b) =>
        new Date(a.scan_time || a.last_scan_time || a.entry_time || 0) -
        new Date(b.scan_time || b.last_scan_time || b.entry_time || 0)
    )

    sorted.forEach((row) => {
      const id = row.person_id || row.labour_id || row.id || row.token_uid
      if (!id) return

      const state = byLabour.get(id) || { open: null }
      const checkInTime = row.entry_time || row.scan_time || row.last_scan_time || null

      if (row.direction === 'IN') {
        if (state.open) visits.push(state.open)

        state.open = {
          ...row,
          gate_in_name: row.gate_name,
          check_in_time: checkInTime,
          check_out_time: null,
          status: 'Checked In',
        }
      } else if (row.direction === 'OUT') {
        if (state.open) {
          visits.push({
            ...state.open,
            gate_out_name: row.gate_name,
            check_out_time: row.last_scan_time || row.scan_time || state.open.check_out_time || null,
            status: 'Checked Out',
          })
          state.open = null
        } else {
          visits.push({
            ...row,
            gate_in_name: row.gate_name,
            gate_out_name: row.gate_name,
            check_in_time: null,
            check_out_time: row.last_scan_time || row.scan_time || null,
            status: 'Checked Out',
          })
        }
      }

      byLabour.set(id, state)
    })

    byLabour.forEach(({ open }) => {
      if (open) visits.push(open)
    })

    return visits.sort(
      (a, b) =>
        new Date(b.check_in_time || b.check_out_time || 0) -
        new Date(a.check_in_time || a.check_out_time || 0)
    )
  }, [labourTx])

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
  const labourManifestColumns = useMemo(
    () => [
      { key: 'manifest_number', label: 'Manifest #' },
      { key: 'supervisor_name', label: 'Supervisor' },
      { key: 'company_name', label: 'Company' },
      {
        key: 'project_name',
        label: 'Project',
        render: (row) => {
          return resolveProjectName(row)
        },
      },
      { key: 'total_labours', label: 'Registered' },
      { key: 'checked_in', label: 'Checked In' },
      { key: 'checked_out', label: 'Checked Out' },
      { key: 'returned_tokens', label: 'Tokens Returned' },
      {
        key: 'preview',
        label: 'Preview PDF',
        render: (row) => (
          <Button
            size="small"
            startIcon={<PictureAsPdfIcon fontSize="small" />}
            onClick={async (e) => {
              e.stopPropagation()
              try {
                const res = await labourApi.getManifestPdf(row.id)
                const blob = new Blob([res.data], { type: 'application/pdf' })
                const url = window.URL.createObjectURL(blob)
                window.open(url, '_blank', 'noopener,noreferrer')
              } catch (err) {
                console.error('Failed to preview PDF:', err)
                alert('Could not open manifest PDF')
              }
            }}
          >
            Open
          </Button>
        ),
      },
    ],
    []
  )

  return (
    <Box sx={{ width: "100%", px: 1, py: 1 }}>

      {/* Header */}




      {/* Overview + KPIs */}
      <Section
        title="Overview"
        expanded={openOverview}
        onToggle={() => setOpenOverview((v) => !v)}
      >
        <Grid container spacing={2}>
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
      </Section>

      {/* Live Project Load */}
      <Section
        title="Live Numbers by Project (Inside Now)"
        expanded={openProjects}
        onToggle={() => setOpenProjects((v) => !v)}

      >
        {liveProjectCounts.length === 0 ? (
          <Typography color="text.secondary">
            No live project activity.
          </Typography>
        ) : (
          <TableContainer>
            <Table size="small">

              {/* Table Header */}
              <TableHead>
                <TableRow
                  sx={{
                    background: "rgba(15,23,42,0.04)"
                  }}
                >
                  <TableCell sx={{ fontWeight: 600 }}>Project</TableCell>
                  <TableCell align="center" sx={{ fontWeight: 600 }}>
                    Visitors
                  </TableCell>
                  <TableCell align="center" sx={{ fontWeight: 600 }}>
                    Labourers
                  </TableCell>
                  <TableCell align="center" sx={{ fontWeight: 600 }}>
                    Total Inside
                  </TableCell>
                </TableRow>
              </TableHead>

              {/* Table Body */}
              <TableBody>
                {liveProjectCounts.map((p) => {
                  const total = p.visitors + p.labours

                  return (
                    <TableRow key={p.project_name} hover>

                      <TableCell>
                        <Typography fontWeight={600}>
                          {p.project_name}
                        </Typography>
                      </TableCell>

                      <TableCell align="center">
                        <Chip
                          label={p.visitors}
                          size="small"
                          color="primary"
                          variant="outlined"
                        />
                      </TableCell>

                      <TableCell align="center">
                        <Chip
                          label={p.labours}
                          size="small"
                          color="secondary"
                          variant="outlined"
                        />
                      </TableCell>

                      <TableCell align="center">
                        <Typography fontWeight={700}>
                          {total}
                        </Typography>
                      </TableCell>

                    </TableRow>
                  )
                })}
              </TableBody>

            </Table>
          </TableContainer>
        )}
      </Section>



      {/* Labour Manifests (Today) */}
      <Section
        title="Labour Manifests (Today)"
        expanded={openManifests}
        onToggle={() => setOpenManifests((v) => !v)}

      >
        {labourManifestError ? (
          <Typography color="error">{labourManifestError}</Typography>
        ) : (
          <DataTable
            rows={labourManifests}
            columns={labourManifestColumns}
            emptyText="No labour manifests created today."
            onRowClick={(row) => row?.id && navigate(`/labour/manifest/${row.id}`)}
          />
        )}
      </Section>

      {/* Activity Tabs */}
      <Section
        title="Live Access Overview"
        expanded={openAccess}
        onToggle={() => setOpenAccess((v) => !v)}
      >
        {/* ================= VISITORS ================= */}
        <Typography variant="subtitle1" fontWeight={600} sx={{ mb: 1 }}>
          Visitors
        </Typography>

        <DataTable
          rows={visitorVisitRows}
          emptyText="No visitor activity available."
          columns={[
            {
              key: 'full_name',
              label: 'Visitor Name',
            },
            {
              key: 'company_name',
              label: 'Company',
            },
            {
              key: 'project_name',
              label: 'Project',
            },
            {
              key: 'gate_in_name',
              label: 'Check-in Gate',
              render: (row) => row.gate_in_name || row.gate_name || '-',
            },
            {
              key: 'gate_out_name',
              label: 'Check-out Gate',
              render: (row) => row.gate_out_name || '-',
            },
            {
              key: 'entry_time',
              label: 'Check-in Time',
              render: (row) =>
                formatDateTime(row.check_in_time || row.entry_time || row.scan_time),
            },
            {
              key: 'checkout_time',
              label: 'Check-out Time',
              render: (row) =>
                row.check_out_time
                  ? formatDateTime(row.check_out_time)
                  : '-',
            },
            {
              key: 'duration',
              label: 'Time Inside',
              render: (row) => {
                const checkInRaw = row.check_in_time || row.entry_time || row.scan_time
                const checkOutRaw = row.check_out_time || null

                if (!checkInRaw) return '-'

                const checkIn = new Date(checkInRaw)
                const checkOut = checkOutRaw ? new Date(checkOutRaw) : now

                if (Number.isNaN(checkIn.getTime()) || Number.isNaN(checkOut.getTime())) return '-'

                return formatDuration(checkOut - checkIn)
              },
            },
            {
              key: 'status',
              label: 'Status',
              render: (row) => (row.check_out_time ? 'Checked Out' : 'Checked In'),
            },
          ]}
          onRowClick={handleVisitorRowClick}
        />

        {/* ================= LABOURS ================= */}
        <Typography
          variant="subtitle1"
          fontWeight={600}
          sx={{ mt: 3, mb: 1 }}
        >
          Labours
        </Typography>

        <DataTable
          rows={labourVisitRows}
          emptyText="No labour activity available."
          columns={[
            { key: 'full_name', label: 'Labour Name' },
            { key: 'supervisor_name', label: 'Supervisor' },
            { key: 'supervisor_company', label: 'Company', render: resolveSupervisorCompany,},
            {
              key: 'project_name',
              label: 'Project',
              render: resolveProjectName,
            },

            {
              key: 'gate_in_name',
              label: 'Check-in Gate',
              render: (row) => row.gate_in_name || row.gate_name || '-',
            },
            {
              key: 'gate_out_name',
              label: 'Check-out Gate',
              render: (row) => row.gate_out_name || '-',
            },
            {
              key: 'entry_time',
              label: 'Check-in Time',
              render: (row) => formatDateTime(row.check_in_time || row.entry_time || row.scan_time),
            },
            {
              key: 'checkout_time',
              label: 'Check-out Time',
              render: (row) =>
                row.check_out_time
                  ? formatDateTime(row.check_out_time)
                  : '-',
            },
            {
              key: 'duration',
              label: 'Time Inside',
              render: (row) => {
                const checkInRaw = row.check_in_time || row.entry_time || row.scan_time
                const checkOutRaw = row.check_out_time || null

                if (!checkInRaw) return '-'

                const checkIn = new Date(checkInRaw)
                const checkOut = checkOutRaw ? new Date(checkOutRaw) : now
                if (Number.isNaN(checkIn.getTime()) || Number.isNaN(checkOut.getTime())) return '-'

                return formatDuration(checkOut - checkIn)
              },
            },
            {
              key: 'status',
              label: 'Status',
              render: (row) =>
                row.check_out_time
                  ? 'Checked Out'
                  : 'Checked In',
            },
          ]}
        />
      </Section>
      
            {/* Extended Analytics (from former Analytics page) */}
      <Section
        title="Analytics"
        expanded={openAnalytics}
        onToggle={() => setOpenAnalytics((v) => !v)}
        actions={(
          <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap', alignItems: 'center' }}>
            <TextField
              type="date"
              size="small"
              value={fromDate}
              onChange={(e) => setFromDate(e.target.value)}
              inputProps={{ max: toDate }}
            />
            <TextField
              type="date"
              size="small"
              value={toDate}
              onChange={(e) => setToDate(e.target.value)}
              inputProps={{ min: fromDate }}
            />
            <Button variant="contained" size="small" onClick={fetchExtendedAnalytics} disabled={analyticsLoading}>
              {analyticsLoading ? 'Refreshing...' : 'Refresh'}
            </Button>
          </Box>
        )}
      >
        {analyticsError && <Alert severity="error" sx={{ mb: 2 }}>{analyticsError}</Alert>}

        <Grid container spacing={2} sx={{ mb: 3 }}>
          <Grid size={{ xs: 12, md: 4 }}>
            <AnalyticsHighlightCard
              title="Access Success Rate"
              value={`${gateSummary.successRate || 0}%`}
              helper={`${gateSummary.total.toLocaleString()} scans`}
              tone="success"
            />
          </Grid>
          <Grid size={{ xs: 12, md: 4 }}>
            <AnalyticsHighlightCard
              title="Busiest Gate"
              value={gateSummary.busiest?.gate_name || '—'}
              helper={gateSummary.busiest ? `${gateSummary.busiest.total_scans} scans` : 'No traffic'}
              tone="info"
            />
          </Grid>
          <Grid size={{ xs: 12, md: 4 }}>
            <AnalyticsHighlightCard
              title="Peak Hour"
              value={peakHighlight ? `${String(peakHighlight.hour).padStart(2, '0')}:00` : '—'}
              helper={peakHighlight ? `${peakHighlight.total_scans} scans` : 'No data'}
              tone="warning"
            />
          </Grid>
        </Grid>

        <Grid container spacing={2} sx={{ mb: 3 }}>
          <Grid size={{ xs: 12, md: 3 }}>
            <AnalyticsKpiCard label="Entry Scans" value={dailyStats?.total_entry_scans || 0} icon={<TrendingUpIcon />} color="#2196F3" />
          </Grid>
          <Grid size={{ xs: 12, md: 3 }}>
            <AnalyticsKpiCard label="Exit Scans" value={dailyStats?.total_exit_scans || 0} icon={<TrendingUpIcon />} color="#4CAF50" />
          </Grid>
          <Grid size={{ xs: 12, md: 3 }}>
            <AnalyticsKpiCard label="Labour Entries" value={dailyStats?.labour_entry_scans || 0} icon={<BuildIcon />} color="#FF9800" />
          </Grid>
          <Grid size={{ xs: 12, md: 3 }}>
            <AnalyticsKpiCard label="Visitor Entries" value={dailyStats?.visitor_entry_scans || 0} icon={<TrendingUpIcon />} color="#9C27B0" />
          </Grid>
        </Grid>

        <Grid container spacing={2}>
          <Grid size={{ xs: 12, md: 6 }}>
            <Paper sx={{ p: 2 }}>
              <Typography variant="h6" fontWeight={600} mb={2}>
                Peak Hours Distribution
              </Typography>
              <TableContainer>
                <Table size="small">
                  <TableHead>
                    <TableRow sx={{ backgroundColor: '#f5f5f5' }}>
                      <TableCell>Hour</TableCell>
                      <TableCell align="right">Total Scans</TableCell>
                      <TableCell align="right">Entries</TableCell>
                      <TableCell align="right">Exits</TableCell>
                      <TableCell align="right">Failed</TableCell>
                      <TableCell align="right">Failure Rate</TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {peakHours.length === 0 ? (
                      <TableRow><TableCell colSpan={6} align="center">No data</TableCell></TableRow>
                    ) : (
                      peakHours.map((row) => (
                        <TableRow key={row.hour}>
                          <TableCell>{String(row.hour).padStart(2, '0')}:00</TableCell>
                          <TableCell align="right">{row.total_scans}</TableCell>
                          <TableCell align="right">{row.entries}</TableCell>
                          <TableCell align="right">{row.exits}</TableCell>
                          <TableCell align="right">{row.failed_scans}</TableCell>
                          <TableCell align="right">
                            <Chip
                              label={`${row.failure_rate || 0}%`}
                              size="small"
                              color={row.failure_rate > 5 ? 'error' : 'success'}
                              variant="outlined"
                            />
                          </TableCell>
                        </TableRow>
                      ))
                    )}
                  </TableBody>
                </Table>
              </TableContainer>
            </Paper>
          </Grid>

          <Grid size={{ xs: 12, md: 6 }}>
            <Paper sx={{ p: 2 }}>
              <Typography variant="h6" fontWeight={600} mb={2}>
                7-Day Visitor Trends
              </Typography>
              <TableContainer>
                <Table size="small">
                  <TableHead>
                    <TableRow sx={{ backgroundColor: '#f5f5f5' }}>
                      <TableCell>Date</TableCell>
                      <TableCell align="right">Unique Entries</TableCell>
                      <TableCell align="right">Unique Exits</TableCell>
                      <TableCell align="right">Entry Scans</TableCell>
                      <TableCell align="right">Exit Scans</TableCell>
                      <TableCell align="right">Failed</TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {visitorTrends.length === 0 ? (
                      <TableRow><TableCell colSpan={6} align="center">No data</TableCell></TableRow>
                    ) : (
                      visitorTrends.map((row) => (
                        <TableRow key={row.date}>
                          <TableCell>{new Date(row.date).toLocaleDateString()}</TableCell>
                          <TableCell align="right">{row.unique_entries}</TableCell>
                          <TableCell align="right">{row.unique_exits}</TableCell>
                          <TableCell align="right">{row.total_entry_scans}</TableCell>
                          <TableCell align="right">{row.total_exit_scans}</TableCell>
                          <TableCell align="right">
                            <Chip label={row.failed_attempts} size="small" variant="outlined" />
                          </TableCell>
                        </TableRow>
                      ))
                    )}
                  </TableBody>
                </Table>
              </TableContainer>
            </Paper>
          </Grid>
        </Grid>
      </Section>



      {/* Visitor History Search */}
      <Section
        title="Visitor History Search"
        expanded={openHistory}
        onToggle={() => setOpenHistory((v) => !v)}
      >
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
      </Section>

      <Section
        title="Gate Load"
        expanded={openGates}
        onToggle={() => setOpenGates((v) => !v)}
      >
        <Grid container spacing={2}>
          <Grid item xs={12} md={12}>
            <GateLoadChart />
          </Grid>
        </Grid>
      </Section>
    </Box>
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

const AnalyticsKpiCard = ({ label, value, icon, color }) => (
  <Card sx={{ height: '100%' }}>
    <CardContent>
      <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <Box>
          <Typography color="textSecondary" gutterBottom>
            {label}
          </Typography>
          <Typography variant="h4" fontWeight={700} sx={{ color }}>
            {value}
          </Typography>
        </Box>
        <Box sx={{ color, opacity: 0.3, fontSize: 50 }}>{icon}</Box>
      </Box>
    </CardContent>
  </Card>
)

const AnalyticsHighlightCard = ({ title, value, helper, tone = 'info' }) => {
  const palette = {
    success: '#22c55e',
    info: '#3b82f6',
    warning: '#f59e0b',
    error: '#ef4444'
  }
  const color = palette[tone] || palette.info
  return (
    <Paper
      elevation={0}
      sx={{
        p: 2,
        borderRadius: 2,
        border: '1px solid rgba(15,23,42,0.08)',
        height: '100%',
        background: 'linear-gradient(180deg, #0b1224 0%, #0f172a 40%, #0b1224 100%)',
        color: '#e2e8f0'
      }}
    >
      <Typography variant="caption" sx={{ opacity: 0.75, letterSpacing: 1 }}>
        {title.toUpperCase()}
      </Typography>
      <Typography variant="h5" fontWeight={800} sx={{ color, mt: 0.5 }}>
        {value}
      </Typography>
      <Typography variant="body2" sx={{ opacity: 0.8 }}>
        {helper}
      </Typography>
    </Paper>
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

function Section({ title, expanded, onToggle, actions, children }) {
  return (
    <Paper
      elevation={0}
      sx={{
        p: 2.5,
        mb: 3,
        borderRadius: 2,
        border: '1px solid rgba(15,23,42,0.08)',
      }}
    >
      <Box
        sx={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          mb: 1,
          gap: 1.5,
        }}
      >
        <Typography variant="h6" fontWeight={700}>
          {title}
        </Typography>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          {actions}
          <IconButton size="small" onClick={onToggle}>
            {expanded ? <ExpandLessIcon /> : <ExpandMoreIcon />}
          </IconButton>
        </Box>
      </Box>

      <Collapse in={expanded} timeout="auto" unmountOnExit>
        <Box sx={{ mt: 1 }}>{children}</Box>
      </Collapse>
    </Paper>
  )
}
