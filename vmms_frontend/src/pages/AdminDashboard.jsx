import React, { useState, useEffect } from 'react'
import {
  Box,
  Button,
  Card,
  CardContent,
  CardHeader,
  Chip,
  Container,
  Divider,
  Grid,
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
  Typography,
  Alert,
} from '@mui/material'
import RefreshIcon from '@mui/icons-material/Refresh'
import BuildIcon from '@mui/icons-material/Build'
import TrendingUpIcon from '@mui/icons-material/TrendingUp'
import SecurityIcon from '@mui/icons-material/Security'
import analytics from '../api/analytics.api'
import Loader from '../components/common/Loader'

export default function AdminDashboard() {
  const [selectedDate, setSelectedDate] = useState(new Date().toISOString().split('T')[0])
  const [tabValue, setTabValue] = useState(0)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  // Daily stats
  const [dailyStats, setDailyStats] = useState(null)
  // Live muster
  const [liveMuster, setLiveMuster] = useState([])
  // Analytics tabs data
  const [peakHours, setPeakHours] = useState([])
  const [gatePerformance, setGatePerformance] = useState([])
  const [riskScores, setRiskScores] = useState([])
  const [visitorTrends, setVisitorTrends] = useState([])
  const [materialAnalytics, setMaterialAnalytics] = useState([])
  const [labourAnalytics, setLabourAnalytics] = useState([])

  const fetchDashboardData = async () => {
    setLoading(true)
    setError('')
    try {
      const [
        dailyRes,
        liveMusterRes,
        peaksRes,
        gatesRes,
        risksRes,
        trendsRes,
        matsRes,
        labourRes,
      ] = await Promise.all([
        analytics.getDailyStats(selectedDate).catch(() => ({ data: {} })),
        analytics.getLiveMuster().catch(() => ({ data: { data: [] } })),
        analytics.getPeakHours(selectedDate, selectedDate).catch(() => ({ data: { peakHours: [] } })),
        analytics.getGatePerformance(selectedDate, selectedDate).catch(() => ({ data: { gatePerformance: [] } })),
        analytics.getRiskScores(50).catch(() => ({ data: { riskScores: [] } })),
        analytics.getVisitorTrends(selectedDate, selectedDate).catch(() => ({ data: { trends: [] } })),
        analytics.getMaterialAnalytics(selectedDate, selectedDate).catch(() => ({ data: { materialAnalytics: [] } })),
        analytics.getLabourAnalytics(selectedDate, selectedDate).catch(() => ({ data: { labourAnalytics: [] } })),
      ])

      setDailyStats(dailyRes?.data?.stats || {})
      setLiveMuster(liveMusterRes?.data?.data || [])
      setPeakHours(peaksRes?.data?.peakHours || [])
      setGatePerformance(gatesRes?.data?.gatePerformance || [])
      setRiskScores(risksRes?.data?.riskScores || [])
      setVisitorTrends(trendsRes?.data?.trends || [])
      setMaterialAnalytics(matsRes?.data?.materialAnalytics || [])
      setLabourAnalytics(labourRes?.data?.labourAnalytics || [])
    } catch (err) {
      setError('Failed to fetch dashboard data')
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchDashboardData()
  }, [selectedDate])

  if (loading && !dailyStats) return <Loader />

  // Filter live muster for current day only
  const todayMuster = liveMuster.filter((m) => {
    const scanDate = new Date(m.last_scan_time).toISOString().split('T')[0]
    return scanDate === selectedDate
  }).sort((a, b) => new Date(b.last_scan_time) - new Date(a.last_scan_time))

  return (
    <Container maxWidth="xl" sx={{ py: 3 }}>
      {/* Header */}
      <Box sx={{ mb: 4 }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 2, mb: 2 }}>
          <Typography variant="h4" fontWeight={700}>
            Admin Analytics Dashboard
          </Typography>
          <Button
            variant="outlined"
            startIcon={<RefreshIcon />}
            onClick={fetchDashboardData}
            disabled={loading}
          >
            Refresh
          </Button>
        </Box>

        <Box sx={{ display: 'flex', gap: 2, alignItems: 'center', flexWrap: 'wrap' }}>
          <TextField
            type="date"
            value={selectedDate}
            onChange={(e) => setSelectedDate(e.target.value)}
            size="small"
            inputProps={{ max: new Date().toISOString().split('T')[0] }}
          />
          <Typography variant="caption" color="text.secondary">
            Select date to view metrics
          </Typography>
        </Box>
      </Box>

      {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}

      <Divider sx={{ mb: 3 }} />

      {/* Metrics Cards */}
      <Grid container spacing={2} sx={{ mb: 3 }}>
        {/* Visitor Metrics */}
        <Grid size={{ xs: 12, sm: 6, md: 4, lg: 2.4 }}>
          <MetricCard
            label="Visitors Checked In"
            value={dailyStats?.visitor_entries || 0}
            icon={<TrendingUpIcon />}
            color="#2196F3"
          />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 4, lg: 2.4 }}>
          <MetricCard
            label="Visitors Checked Out"
            value={dailyStats?.total_exits || 0}
            icon={<TrendingUpIcon />}
            color="#4CAF50"
          />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 4, lg: 2.4 }}>
          <MetricCard
            label="Visitors Inside Now"
            value={(dailyStats?.visitor_entries || 0) - (dailyStats?.total_exits || 0)}
            icon={<TrendingUpIcon />}
            color="#FF9800"
          />
        </Grid>

        {/* Labour Metrics */}
        <Grid size={{ xs: 12, sm: 6, md: 4, lg: 2.4 }}>
          <MetricCard
            label="Labours Registered"
            value={dailyStats?.labour_entries || 0}
            icon={<BuildIcon />}
            color="#9C27B0"
          />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 4, lg: 2.4 }}>
          <MetricCard
            label="Labours Checked In"
            value={
              liveMuster.filter(
                (m) => m.person_type === 'LABOUR' && m.current_status === 'IN'
              ).length
            }
            icon={<BuildIcon />}
            color="#FF5722"
          />
        </Grid>

        <Grid size={{ xs: 12, sm: 6, md: 4, lg: 2.4 }}>
          <MetricCard
            label="Labours Checked Out"
            value={
              liveMuster.filter(
                (m) => m.person_type === 'LABOUR' && m.current_status === 'OUT'
              ).length
            }
            icon={<BuildIcon />}
            color="#795548"
          />
        </Grid>

        <Grid size={{ xs: 12, sm: 6, md: 4, lg: 2.4 }}>
          <MetricCard
            label="Labours Inside"
            value={
              liveMuster.filter(
                (m) => m.person_type === 'LABOUR' && m.current_status === 'IN'
              ).length
            }
            icon={<BuildIcon />}
            color="#009688"
          />
        </Grid>

        <Grid size={{ xs: 12, sm: 6, md: 4, lg: 2.4 }}>
          <MetricCard
            label="Tokens Returned"
            value={labourAnalytics?.length || 0}
            icon={<BuildIcon />}
            color="#607D8B"
          />
        </Grid>
      </Grid>

      <Divider sx={{ mb: 3 }} />

      {/* Live Muster Table for Current Day */}
      <Paper sx={{ mb: 3 }}>
        <Box sx={{ p: 2, borderBottom: '1px solid #eee' }}>
          <Typography variant="h6" fontWeight={600}>
            Live Muster - {new Date(selectedDate).toLocaleDateString()} (Recent First)
          </Typography>
        </Box>

        <TableContainer sx={{ maxHeight: 500 }}>
          <Table stickyHeader size="small">
            <TableHead>
              <TableRow sx={{ backgroundColor: '#f5f5f5' }}>
                <TableCell>Name</TableCell>
                <TableCell>Type</TableCell>
                <TableCell>Supervisor</TableCell>
                <TableCell>Project</TableCell>
                <TableCell>Status</TableCell>
                <TableCell>Gate</TableCell>
                <TableCell>Last Scan</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {todayMuster.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} align="center">
                    No records for this date
                  </TableCell>
                </TableRow>
              ) : (
                todayMuster.map((m, idx) => (
                  <TableRow key={`${m.person_id}-${idx}`} hover>
                    <TableCell fontWeight={600}>{m.full_name || '-'}</TableCell>
                    <TableCell>
                      <Chip
                        size="small"
                        label={m.person_type || '-'}
                        color={m.person_type === 'LABOUR' ? 'warning' : 'primary'}
                        variant="outlined"
                      />
                    </TableCell>
                    <TableCell>{m.supervisor_name || '-'}</TableCell>
                    <TableCell>{m.project_name || '-'}</TableCell>
                    <TableCell>
                      <Chip
                        size="small"
                        label={m.current_status || '-'}
                        color={m.current_status === 'IN' ? 'success' : 'default'}
                      />
                    </TableCell>
                    <TableCell>{m.gate_name || '-'}</TableCell>
                    <TableCell>
                      {m.last_scan_time
                        ? new Date(m.last_scan_time).toLocaleString()
                        : '-'}
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </TableContainer>
      </Paper>

      {/* Advanced Analytics Tabs */}
      <Paper>
        <Tabs value={tabValue} onChange={(_, v) => setTabValue(v)}>
          <Tab label="Peak Hours" />
          <Tab label="Gate Performance" />
          <Tab label="Risk & Security" />
          <Tab label="Materials" />
          <Tab label="Labour Analytics" />
        </Tabs>

        {/* Peak Hours */}
        {tabValue === 0 && (
          <Box sx={{ p: 2 }}>
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
                    <TableRow>
                      <TableCell colSpan={6} align="center">
                        No data
                      </TableCell>
                    </TableRow>
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
          </Box>
        )}

        {/* Gate Performance */}
        {tabValue === 1 && (
          <Box sx={{ p: 2 }}>
            <TableContainer sx={{ maxHeight: 500 }}>
              <Table stickyHeader size="small">
                <TableHead>
                  <TableRow sx={{ backgroundColor: '#f5f5f5' }}>
                    <TableCell>Gate Name</TableCell>
                    <TableCell align="right">Total Scans</TableCell>
                    <TableCell align="right">Success</TableCell>
                    <TableCell align="right">Failed</TableCell>
                    <TableCell align="right">Success Rate</TableCell>
                    <TableCell>Last Activity</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {gatePerformance.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={6} align="center">
                        No data
                      </TableCell>
                    </TableRow>
                  ) : (
                    gatePerformance.map((row) => (
                      <TableRow key={row.id}>
                        <TableCell fontWeight={600}>{row.gate_name}</TableCell>
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
                            color={
                              row.success_rate >= 95
                                ? 'success'
                                : row.success_rate >= 90
                                  ? 'warning'
                                  : 'error'
                            }
                          />
                        </TableCell>
                        <TableCell>
                          {row.last_activity
                            ? new Date(row.last_activity).toLocaleString()
                            : '-'}
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </TableContainer>
          </Box>
        )}

        {/* Risk & Security */}
        {tabValue === 2 && (
          <Box sx={{ p: 2 }}>
            <TableContainer sx={{ maxHeight: 500 }}>
              <Table stickyHeader size="small">
                <TableHead>
                  <TableRow sx={{ backgroundColor: '#f5f5f5' }}>
                    <TableCell>Name</TableCell>
                    <TableCell>Phone</TableCell>
                    <TableCell align="right">Failed Attempts</TableCell>
                    <TableCell>Blacklisted</TableCell>
                    <TableCell align="right">Risk Score</TableCell>
                    <TableCell>Risk Level</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {riskScores.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={6} align="center">
                        No high-risk visitors
                      </TableCell>
                    </TableRow>
                  ) : (
                    riskScores.map((row) => (
                      <TableRow key={row.id}>
                        <TableCell fontWeight={600}>{row.full_name}</TableCell>
                        <TableCell>{row.primary_phone}</TableCell>
                        <TableCell align="right">{row.failed_attempts}</TableCell>
                        <TableCell>
                          {row.is_blacklisted ? (
                            <Chip label="YES" size="small" color="error" />
                          ) : (
                            <Chip label="NO" size="small" />
                          )}
                        </TableCell>
                        <TableCell align="right" fontWeight={600}>
                          {row.risk_score}
                        </TableCell>
                        <TableCell>
                          <Chip
                            label={row.risk_level}
                            size="small"
                            color={
                              row.risk_level === 'CRITICAL'
                                ? 'error'
                                : row.risk_level === 'HIGH'
                                  ? 'warning'
                                  : 'success'
                            }
                          />
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </TableContainer>
          </Box>
        )}

        {/* Materials */}
        {tabValue === 3 && (
          <Box sx={{ p: 2 }}>
            <TableContainer sx={{ maxHeight: 500 }}>
              <Table stickyHeader size="small">
                <TableHead>
                  <TableRow sx={{ backgroundColor: '#f5f5f5' }}>
                    <TableCell>Material</TableCell>
                    <TableCell>Category</TableCell>
                    <TableCell align="right">Current</TableCell>
                    <TableCell align="right">Min/Max</TableCell>
                    <TableCell>Status</TableCell>
                    <TableCell>Last Transaction</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {materialAnalytics.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={6} align="center">
                        No materials
                      </TableCell>
                    </TableRow>
                  ) : (
                    materialAnalytics.map((row) => (
                      <TableRow key={row.id}>
                        <TableCell fontWeight={600}>{row.material_name}</TableCell>
                        <TableCell>{row.category}</TableCell>
                        <TableCell align="right" fontWeight={600}>
                          {row.current_stock}
                        </TableCell>
                        <TableCell align="right">
                          {row.min_threshold}/{row.max_stock}
                        </TableCell>
                        <TableCell>
                          <Chip
                            label={row.stock_status}
                            size="small"
                            color={
                              row.stock_status === 'CRITICAL'
                                ? 'error'
                                : row.stock_status === 'LOW'
                                  ? 'warning'
                                  : row.stock_status === 'OVERSTOCK'
                                    ? 'info'
                                    : 'success'
                            }
                          />
                        </TableCell>
                        <TableCell>
                          {row.last_transaction
                            ? new Date(row.last_transaction).toLocaleString()
                            : '-'}
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </TableContainer>
          </Box>
        )}

        {/* Labour Analytics */}
        {tabValue === 4 && (
          <Box sx={{ p: 2 }}>
            <TableContainer sx={{ maxHeight: 500 }}>
              <Table stickyHeader size="small">
                <TableHead>
                  <TableRow sx={{ backgroundColor: '#f5f5f5' }}>
                    <TableCell>Name</TableCell>
                    <TableCell>Supervisor</TableCell>
                    <TableCell>Project</TableCell>
                    <TableCell align="right">Days Worked</TableCell>
                    <TableCell align="right">Entries</TableCell>
                    <TableCell align="right">Exits</TableCell>
                    <TableCell align="right">Failed</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {labourAnalytics.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={7} align="center">
                        No labour records
                      </TableCell>
                    </TableRow>
                  ) : (
                    labourAnalytics.map((row) => (
                      <TableRow key={row.id}>
                        <TableCell fontWeight={600}>{row.full_name}</TableCell>
                        <TableCell>{row.supervisor_name}</TableCell>
                        <TableCell>{row.project_name}</TableCell>
                        <TableCell align="right">{row.days_worked || 0}</TableCell>
                        <TableCell align="right">{row.total_entries || 0}</TableCell>
                        <TableCell align="right">{row.total_exits || 0}</TableCell>
                        <TableCell align="right">
                          {row.failed_attempts > 0 ? (
                            <Chip
                              label={row.failed_attempts}
                              size="small"
                              color="warning"
                              variant="outlined"
                            />
                          ) : (
                            <Chip label="0" size="small" />
                          )}
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </TableContainer>
          </Box>
        )}
      </Paper>
    </Container>
  )
}

// Metric Card Component
const MetricCard = ({ label, value, icon, color }) => (
  <Card elevation={0} sx={{ border: `2px solid ${color}`, height: '100%' }}>
    <CardContent>
      <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <Box>
          <Typography color="textSecondary" variant="caption" display="block">
            {label}
          </Typography>
          <Typography variant="h4" fontWeight={700} sx={{ color, mt: 1 }}>
            {value}
          </Typography>
        </Box>
        <Box sx={{ color, opacity: 0.2, fontSize: 40 }}>{icon}</Box>
      </Box>
    </CardContent>
  </Card>
)
