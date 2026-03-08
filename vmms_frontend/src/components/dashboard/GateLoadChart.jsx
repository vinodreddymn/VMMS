import React, { useEffect, useState } from 'react'
import {
  Card,
  CardContent,
  CardHeader,
  Box,
  CircularProgress,
  Alert,
  Typography,
  Grid,
  Paper,
  Chip
} from '@mui/material'
import api from '../../api/axios'

export default function GateLoadChart() {
  const [gateStats, setGateStats] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  useEffect(() => {
    fetchGateLoad()
  }, [])

  const fetchGateLoad = async () => {
    setLoading(true)
    try {
      const today = new Date().toISOString().split('T')[0]
      const res = await api.get(`/analytics/gate-stats?from_date=${today}&to_date=${today}`)
      if (res?.data?.gateStats) {
        setGateStats(res.data.gateStats)
      }
      setError('')
    } catch (err) {
      setError(err?.response?.data?.error || 'Failed to fetch gate load')
    } finally {
      setLoading(false)
    }
  }

  const getLoadStatus = (totalScans) => {
    if (totalScans > 200) return { label: 'HIGH', color: 'error' }
    if (totalScans > 100) return { label: 'MEDIUM', color: 'warning' }
    return { label: 'LOW', color: 'success' }
  }

  return (
    <Card>
      <CardHeader
        title="Gate Load Distribution"
        titleTypographyProps={{ variant: 'h6', fontWeight: 600 }}
        action={
          <Typography variant="caption" color="text.secondary">
            Today
          </Typography>
        }
        sx={{ borderBottom: '1px solid #eee' }}
      />
      <CardContent>
        {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}

        {loading ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', p: 3 }}>
            <CircularProgress size={30} />
          </Box>
        ) : gateStats.length === 0 ? (
          <Alert severity="info">No gate data available</Alert>
        ) : (
          <Grid container spacing={2}>
            {gateStats.map((gate) => {
              const status = getLoadStatus(gate.total_scans)
              const failureRate = ((gate.failed_scans / gate.total_scans) * 100).toFixed(1)

              return (
                <Grid size={{ xs: 12, md: 6 }} key={gate.id}>
                  <Paper
                    elevation={0}
                    sx={{
                      p: 2,
                      border: '1px solid #eee',
                      borderLeft: `4px solid ${
                        status.color === 'error'
                          ? '#d32f2f'
                          : status.color === 'warning'
                          ? '#f57c00'
                          : '#388e3c'
                      }`
                    }}
                  >
                    <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}>
                      <Typography variant="subtitle2" fontWeight={600}>
                        {gate.gate_name}
                      </Typography>
                      <Chip label={status.label} size="small" color={status.color} />
                    </Box>

                    <Typography variant="caption" color="text.secondary" display="block" sx={{ mb: 1 }}>
                      {gate.entrance_name || 'No Entrance Assigned'}
                    </Typography>

                    <Box sx={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 1 }}>
                      <Box>
                        <Typography variant="caption" color="text.secondary">
                          Total Scans
                        </Typography>
                        <Typography variant="h6" fontWeight={700}>
                          {gate.total_scans}
                        </Typography>
                      </Box>

                      <Box>
                        <Typography variant="caption" color="text.secondary">
                          Entries
                        </Typography>
                        <Typography variant="h6" fontWeight={700} sx={{ color: '#4caf50' }}>
                          {gate.entries}
                        </Typography>
                      </Box>

                      <Box>
                        <Typography variant="caption" color="text.secondary">
                          Exits
                        </Typography>
                        <Typography variant="h6" fontWeight={700} sx={{ color: '#2196f3' }}>
                          {gate.exits}
                        </Typography>
                      </Box>

                      <Box>
                        <Typography variant="caption" color="text.secondary">
                          Failed
                        </Typography>
                        <Typography variant="h6" fontWeight={700} sx={{ color: '#f44336' }}>
                          {gate.failed_scans} ({failureRate}%)
                        </Typography>
                      </Box>
                    </Box>

                    {/* Progress bar */}
                    <Box sx={{ mt: 1.5, mb: 1 }}>
                      <Box
                        sx={{
                          width: '100%',
                          height: 8,
                          backgroundColor: '#f0f0f0',
                          borderRadius: 1,
                          overflow: 'hidden'
                        }}
                      >
                        <Box
                          sx={{
                            width: `${Math.min((gate.total_scans / 300) * 100, 100)}%`,
                            height: '100%',
                            backgroundColor: status.color === 'error' ? '#d32f2f' : status.color === 'warning' ? '#f57c00' : '#388e3c',
                            transition: 'width 0.3s ease'
                          }}
                        />
                      </Box>
                    </Box>

                    <Typography variant="caption" color="text.secondary">
                      Capacity: {Math.min((gate.total_scans / 300) * 100, 100).toFixed(0)}%
                    </Typography>
                  </Paper>
                </Grid>
              )
            })}
          </Grid>
        )}
      </CardContent>
    </Card>
  )
}
