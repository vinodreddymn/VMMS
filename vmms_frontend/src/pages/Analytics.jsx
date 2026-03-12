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
        <Grid size={{ xs: 12, md: 3 }}>
          <HighlightCard
            title="Access Success Rate"
            value={`${gateSummary.successRate || 0}%`}
            helper={`${gateSummary.total.toLocaleString()} scans`}
            tone="success"
          />
        </Grid>
        <Grid size={{ xs: 12, md: 3 }}>
          <HighlightCard
            title="Busiest Gate"
            value={gateSummary.busiest?.gate_name || '—'}
            helper={gateSummary.busiest ? `${gateSummary.busiest.total_scans} scans` : 'No traffic'}
            tone="info"
          />
        </Grid>
        <Grid size={{ xs: 12, md: 3 }}>
          <HighlightCard
            title="Peak Hour"
            value={peakHighlight ? `${String(peakHighlight.hour).padStart(2, '0')}:00` : '—'}
            helper={peakHighlight ? `${peakHighlight.total_scans} scans` : 'No data'}
            tone="warning"
          />
        </Grid>
        <Grid size={{ xs: 12, md: 3 }}>
          <HighlightCard
            title="Alerts & Risks"
            value={`${criticalRiskCount} high-risk / ${materialAlerts.length} stock alerts`}
            helper="Monitor immediately"
            tone="error"
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
          <Tab label="Gate Performance" />
          <Tab label="Risk & Security" />
          <Tab label="Materials" />
          <Tab label="Labour" />
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

      {/* Gate Performance Tab */}
      {tabValue === 1 && (
        <Paper sx={{ p: 2 }}>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2, flexWrap: 'wrap', gap: 1.5 }}>
            <Typography variant="h6" fontWeight={600}>
              Gate Performance & Health
            </Typography>
            <Button
              size="small"
              variant="outlined"
              startIcon={<DownloadIcon />}
              disabled={!gatePerformance.length}
              onClick={() =>
                exportCsv(gatePerformance, [
                  { key: 'gate_name', label: 'Gate' },
                  { key: 'entrance_name', label: 'Entrance' },
                  { key: 'total_scans', label: 'Total Scans' },
                  { key: 'successful_scans', label: 'Success' },
                  { key: 'failed_scans', label: 'Failed' },
                  { key: 'success_rate', label: 'Success Rate' },
                  { key: 'error_codes', label: 'Error Codes' },
                  { key: 'last_activity', label: 'Last Activity' },
                ], `gate_performance_${fromDate}_${toDate}.csv`)
              }
            >
              Export CSV
            </Button>
          </Box>
          <TableContainer>
            <Table size="small">
              <TableHead>
                <TableRow sx={{ backgroundColor: '#f5f5f5' }}>
                  <TableCell>Gate Name</TableCell>
                  <TableCell>Entrance</TableCell>
                  <TableCell align="right">Total Scans</TableCell>
                  <TableCell align="right">Success</TableCell>
                  <TableCell align="right">Failed</TableCell>
                  <TableCell align="right">Success Rate</TableCell>
                  <TableCell>Error Codes</TableCell>
                  <TableCell>Last Activity</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {gatePerformance.length === 0 ? (
                  <TableRow><TableCell colSpan={8} align="center">No data</TableCell></TableRow>
                ) : (
                  gatePerformance.map((row) => (
                    <TableRow key={row.id}>
                      <TableCell fontWeight={600}>{row.gate_name}</TableCell>
                      <TableCell>{row.entrance_name || '-'}</TableCell>
                      <TableCell align="right">{row.total_scans}</TableCell>
                      <TableCell align="right">{row.successful_scans}</TableCell>
                      <TableCell align="right">
                        <Chip
                          label={row.failed_scans}
                          size="small"
                          color={row.failed_scans > 0 ? 'error' : 'success'}
                          variant="outlined"
                        />
                      </TableCell>
                      <TableCell align="right">
                        <Chip
                          label={`${row.success_rate || 0}%`}
                          size="small"
                          color={row.success_rate >= 95 ? 'success' : row.success_rate >= 90 ? 'warning' : 'error'}
                        />
                      </TableCell>
                      <TableCell>{row.error_codes || '-'}</TableCell>
                      <TableCell>{row.last_activity ? new Date(row.last_activity).toLocaleString() : '-'}</TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </TableContainer>
        </Paper>
      )}

      {/* Risk & Security Tab */}
      {tabValue === 2 && (
        <Paper sx={{ p: 2 }}>
          <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 2, gap: 2, flexWrap: 'wrap' }}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <SecurityIcon sx={{ color: '#ef4444' }} />
              <Typography variant="h6" fontWeight={600}>
                High-Risk Visitors
              </Typography>
            </Box>
            <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap', alignItems: 'center' }}>
              <TextField
                size="small"
                placeholder="Filter by name, phone, project"
                value={riskSearch}
                onChange={(e) => setRiskSearch(e.target.value)}
              />
              <Tooltip title="Export CSV">
                <span>
                  <IconButton
                    color="primary"
                    onClick={() =>
                      exportCsv(filteredRiskScores, [
                        { key: 'full_name', label: 'Name' },
                        { key: 'primary_phone', label: 'Phone' },
                        { key: 'project_name', label: 'Project' },
                        { key: 'failed_attempts', label: 'Failed Attempts' },
                        { key: 'low_biometric_matches', label: 'Low Biometric' },
                        { key: 'risk_score', label: 'Risk Score' },
                        { key: 'risk_level', label: 'Risk Level' },
                        { key: 'last_access', label: 'Last Access' },
                      ], `high_risk_${toDate}.csv`)
                    }
                    disabled={!filteredRiskScores.length}
                  >
                    <DownloadIcon />
                  </IconButton>
                </span>
              </Tooltip>
            </Box>
          </Box>
          <TableContainer sx={{ maxHeight: 500 }}>
            <Table stickyHeader size="small">
              <TableHead>
                <TableRow sx={{ backgroundColor: '#f5f5f5' }}>
                  <TableCell>Name</TableCell>
                  <TableCell>Phone</TableCell>
                  <TableCell>Project</TableCell>
                  <TableCell align="right">Failed Attempts</TableCell>
                  <TableCell align="right">Low Biometric</TableCell>
                  <TableCell>Blacklisted</TableCell>
                  <TableCell align="right">Risk Score</TableCell>
                  <TableCell>Risk Level</TableCell>
                  <TableCell>Last Access</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {filteredRiskScores.length === 0 ? (
                  <TableRow><TableCell colSpan={9} align="center">No high-risk visitors</TableCell></TableRow>
                ) : (
                  filteredRiskScores.map((row) => (
                    <TableRow key={row.id}>
                      <TableCell fontWeight={600}>{row.full_name}</TableCell>
                      <TableCell>{row.primary_phone}</TableCell>
                      <TableCell>{row.project_name}</TableCell>
                      <TableCell align="right">{row.failed_attempts}</TableCell>
                      <TableCell align="right">{row.low_biometric_matches}</TableCell>
                      <TableCell>
                        {row.is_blacklisted ? (
                          <Chip label="YES" size="small" color="error" />
                        ) : (
                          <Chip label="NO" size="small" />
                        )}
                      </TableCell>
                      <TableCell align="right" fontWeight={600}>{row.risk_score}</TableCell>
                      <TableCell>
                        <Chip
                          label={row.risk_level}
                          size="small"
                          color={
                            row.risk_level === 'CRITICAL' ? 'error' :
                            row.risk_level === 'HIGH' ? 'warning' :
                            row.risk_level === 'MEDIUM' ? 'default' :
                            'success'
                          }
                        />
                      </TableCell>
                      <TableCell>{row.last_access ? new Date(row.last_access).toLocaleString() : '-'}</TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </TableContainer>
        </Paper>
      )}

      {/* Materials Tab */}
      {tabValue === 3 && (
        <Paper sx={{ p: 2 }}>
          <Typography variant="h6" fontWeight={600} mb={2}>
            <LocalShippingIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
            Material Stock Status
          </Typography>
          <TableContainer sx={{ maxHeight: 500 }}>
            <Table stickyHeader size="small">
              <TableHead>
                <TableRow sx={{ backgroundColor: '#f5f5f5' }}>
                  <TableCell>Material</TableCell>
                  <TableCell>Category</TableCell>
                  <TableCell align="right">Current</TableCell>
                  <TableCell align="right">Min</TableCell>
                  <TableCell align="right">Max</TableCell>
                  <TableCell align="right">Inbound</TableCell>
                  <TableCell align="right">Outbound</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell>Last Transaction</TableCell>
                </TableRow>
              </TableHead>
                  <TableBody>
                    {materialAnalytics.length === 0 ? (
                      <TableRow><TableCell colSpan={9} align="center">No materials</TableCell></TableRow>
                    ) : (
                      materialAnalytics.map((row) => (
                        <TableRow key={row.id}>
                          <TableCell fontWeight={600}>{row.material_label || row.category}</TableCell>
                          <TableCell>{row.category}</TableCell>
                          <TableCell align="right" fontWeight={600}>{row.current_stock}</TableCell>
                      <TableCell align="right">{row.min_threshold}</TableCell>
                      <TableCell align="right">{row.max_stock}</TableCell>
                      <TableCell align="right">{row.total_inbound || 0}</TableCell>
                      <TableCell align="right">{row.total_outbound || 0}</TableCell>
                      <TableCell>
                        <Chip
                          label={row.stock_status}
                          size="small"
                          color={
                            row.stock_status === 'CRITICAL' ? 'error' :
                            row.stock_status === 'LOW' ? 'warning' :
                            row.stock_status === 'OVERSTOCK' ? 'info' :
                            'success'
                          }
                        />
                      </TableCell>
                      <TableCell>{row.last_transaction ? new Date(row.last_transaction).toLocaleString() : '-'}</TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </TableContainer>
        </Paper>
      )}

      {/* Labour Tab */}
      {tabValue === 4 && (
        <Paper sx={{ p: 2 }}>
          <Typography variant="h6" fontWeight={600} mb={2}>
            <BuildIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
            Labour Attendance & Performance
          </Typography>
          <TableContainer sx={{ maxHeight: 500 }}>
            <Table stickyHeader size="small">
              <TableHead>
                <TableRow sx={{ backgroundColor: '#f5f5f5' }}>
                  <TableCell>Name</TableCell>
                  <TableCell>Phone</TableCell>
                  <TableCell>Supervisor</TableCell>
                  <TableCell>Project</TableCell>
                  <TableCell align="right">Days Worked</TableCell>
                  <TableCell align="right">Entries</TableCell>
                  <TableCell align="right">Exits</TableCell>
                  <TableCell align="right">Avg Duration</TableCell>
                  <TableCell align="right">Failed</TableCell>
                  <TableCell>Last Access</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {labourAnalytics.length === 0 ? (
                  <TableRow><TableCell colSpan={10} align="center">No labour records</TableCell></TableRow>
                ) : (
                  labourAnalytics.map((row) => (
                    <TableRow key={row.id}>
                      <TableCell fontWeight={600}>{row.full_name}</TableCell>
                      <TableCell>{row.phone}</TableCell>
                      <TableCell>{row.supervisor_name}</TableCell>
                      <TableCell>{row.project_name}</TableCell>
                      <TableCell align="right">{row.days_worked || 0}</TableCell>
                      <TableCell align="right">{row.total_entries || 0}</TableCell>
                      <TableCell align="right">{row.total_exits || 0}</TableCell>
                      <TableCell align="right">{row.avg_duration_hours || '-'} hrs</TableCell>
                      <TableCell align="right">
                        {row.failed_attempts > 0 ? (
                          <Chip label={row.failed_attempts} size="small" color="warning" variant="outlined" />
                        ) : (
                          <Chip label="0" size="small" />
                        )}
                      </TableCell>
                      <TableCell>{row.last_access ? new Date(row.last_access).toLocaleString() : '-'}</TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </TableContainer>
        </Paper>
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
