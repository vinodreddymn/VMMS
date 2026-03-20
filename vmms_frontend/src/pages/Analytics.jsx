import React, { useEffect, useState, useMemo } from 'react'
import {
  Box,
  Button,
  Card,
  CardContent,
  Chip,
  Container,
  Grid,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  TextField,
  Typography,
  Alert,
  CircularProgress,
  Tabs,
  Tab,
  IconButton,
  Tooltip
} from '@mui/material'
import DownloadIcon from '@mui/icons-material/Download'
import TrendingUpIcon from '@mui/icons-material/TrendingUp'
import SecurityIcon from '@mui/icons-material/Security'
import WarningIcon from '@mui/icons-material/Warning'
import LocalShippingIcon from '@mui/icons-material/LocalShipping'
import BuildIcon from '@mui/icons-material/Build'
import analyticsApi from '../api/analytics.api'
import Loader from '../components/common/Loader'

export default function Analytics() {
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [tabValue, setTabValue] = useState(0)
  const [fromDate, setFromDate] = useState(getDefaultFromDate())
  const [toDate, setToDate] = useState(getDefaultToDate())

  const [dailyStats, setDailyStats] = useState(null)
  const [peakHours, setPeakHours] = useState([])
  const [gatePerformance, setGatePerformance] = useState([])
  const [riskScores, setRiskScores] = useState([])
  const [visitorTrends, setVisitorTrends] = useState([])
  const [materialAnalytics, setMaterialAnalytics] = useState([])
  const [labourAnalytics, setLabourAnalytics] = useState([])
  const [riskSearch, setRiskSearch] = useState('')

  function getDefaultFromDate() {
    const d = new Date()
    d.setDate(d.getDate() - 7)
    return d.toISOString().split('T')[0]
  }

  function getDefaultToDate() {
    return new Date().toISOString().split('T')[0]
  }

  const fetchAnalytics = async () => {
    setLoading(true)
    setError('')
    try {
      const [daily, peaks, gates, risks, trends, materials, labours] = await Promise.all([
        analyticsApi.getDailyStats(fromDate, toDate).catch(() => ({})),
        analyticsApi.getPeakHours(fromDate, toDate).catch(() => ({ data: { peakHours: [] } })),
        analyticsApi.getGatePerformance(fromDate, toDate).catch(() => ({ data: { gatePerformance: [] } })),
        analyticsApi.getRiskScores(50, fromDate, toDate).catch(() => ({ data: { riskScores: [] } })),
        analyticsApi.getVisitorTrends(fromDate, toDate).catch(() => ({ data: { trends: [] } })),
        analyticsApi.getMaterialAnalytics(fromDate, toDate).catch(() => ({ data: { materialAnalytics: [] } })),
        analyticsApi.getLabourAnalytics(fromDate, toDate).catch(() => ({ data: { labourAnalytics: [] } }))
      ])

      setDailyStats(daily?.data?.stats || {})
      setPeakHours(peaks?.data?.peakHours || [])
      setGatePerformance(gates?.data?.gatePerformance || [])
      setRiskScores(risks?.data?.riskScores || [])
      setVisitorTrends(trends?.data?.trends || [])
      setMaterialAnalytics(materials?.data?.materialAnalytics || [])
      setLabourAnalytics(labours?.data?.labourAnalytics || [])
    } catch (err) {
      setError('Failed to load analytics data')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchAnalytics()
  }, [fromDate, toDate])

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

  const criticalRiskCount = useMemo(
    () => riskScores.filter((r) => ['HIGH', 'CRITICAL'].includes((r.risk_level || '').toUpperCase())).length,
    [riskScores]
  )

  const materialAlerts = useMemo(
    () => materialAnalytics.filter((m) => ['CRITICAL', 'LOW'].includes((m.stock_status || '').toUpperCase())),
    [materialAnalytics]
  )

  const filteredRiskScores = useMemo(() => {
    if (!riskSearch.trim()) return riskScores
    const q = riskSearch.toLowerCase()
    return riskScores.filter(
      (r) =>
        (r.full_name || '').toLowerCase().includes(q) ||
        (r.primary_phone || '').toLowerCase().includes(q) ||
        (r.project_name || '').toLowerCase().includes(q)
    )
  }, [riskScores, riskSearch])

  if (loading && !dailyStats) return <Loader />

  return (
    <Container maxWidth="xxl" sx={{ py: 3 }}>
      {/* Header */}
      <Box sx={{ mb: 3, display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 2 }}>
        <Typography variant="h4" fontWeight={700}>
          Analytics Dashboard
        </Typography>
        <Box sx={{ display: 'flex', gap: 1 }}>
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
          <Button variant="contained" onClick={fetchAnalytics} disabled={loading}>
            Refresh
          </Button>
        </Box>
      </Box>

      {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}

      {/* Security Highlights */}
      <Grid container spacing={2} sx={{ mb: 3 }}>
        <Grid size={{ xs: 12, md: 4 }}>
          <HighlightCard
            title="Access Success Rate"
            value={`${gateSummary.successRate || 0}%`}
            helper={`${gateSummary.total.toLocaleString()} scans`}
            tone="success"
          />
        </Grid>
        <Grid size={{ xs: 12, md: 4 }}>
          <HighlightCard
            title="Busiest Gate"
            value={gateSummary.busiest?.gate_name || '—'}
            helper={gateSummary.busiest ? `${gateSummary.busiest.total_scans} scans` : 'No traffic'}
            tone="info"
          />
        </Grid>
        <Grid size={{ xs: 12, md: 4 }}>
          <HighlightCard
            title="Peak Hour"
            value={peakHighlight ? `${String(peakHighlight.hour).padStart(2, '0')}:00` : '—'}
            helper={peakHighlight ? `${peakHighlight.total_scans} scans` : 'No data'}
            tone="warning"
          />
        </Grid>

      </Grid>

      {/* KPI Cards */}
      <Grid container spacing={2} sx={{ mb: 3 }}>
        <Grid size={{ xs: 12, md: 3 }}>
          <KpiCard label="Entry Scans" value={dailyStats?.total_entry_scans || 0} icon={<TrendingUpIcon />} color="#2196F3" />
        </Grid>
        <Grid size={{ xs: 12, md: 3 }}>
          <KpiCard label="Exit Scans" value={dailyStats?.total_exit_scans || 0} icon={<TrendingUpIcon />} color="#4CAF50" />
        </Grid>
        <Grid size={{ xs: 12, md: 3 }}>
          <KpiCard label="Labour Entries" value={dailyStats?.labour_entry_scans || 0} icon={<BuildIcon />} color="#FF9800" />
        </Grid>
        <Grid size={{ xs: 12, md: 3 }}>
          <KpiCard label="Visitor Entries" value={dailyStats?.visitor_entry_scans || 0} icon={<TrendingUpIcon />} color="#9C27B0" />
        </Grid>
      </Grid>

      {/* Tabs for different analytics sections */}
      <Paper sx={{ mb: 2 }}>
        <Tabs value={tabValue} onChange={(_, v) => setTabValue(v)}>
          <Tab label="Visitor Analytics" />


        </Tabs>
      </Paper>

      {/* Visitor Analytics Tab */}
      {tabValue === 0 && (
        <Grid container spacing={2}>
          {/* Peak Hours */}
          <Grid size={{ xs: 12 }}>
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

          {/* Visitor Trends */}
          <Grid size={{ xs: 12 }}>
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
      )}







    </Container>
  )
}

const KpiCard = ({ label, value, icon, color }) => (
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

const HighlightCard = ({ title, value, helper, tone = 'info' }) => {
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

const exportCsv = (rows, columns, filename) => {
  if (!rows || !rows.length) return
  const header = columns.map((c) => c.label || c.key).join(',')
  const escape = (v) => {
    if (v === null || v === undefined) return ''
    const s = String(v)
    if (/[",\n]/.test(s)) return `"${s.replace(/"/g, '""')}"`
    return s
  }
  const lines = rows.map((row) => columns.map((c) => escape(row[c.key])).join(','))
  const blob = new Blob([header + '\n' + lines.join('\n')], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  link.href = URL.createObjectURL(blob)
  link.download = filename
  link.click()
}
