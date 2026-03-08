import React, { useEffect, useState } from 'react'
import {
  Card,
  CardContent,
  CardHeader,
  Box,
  Grid,
  Typography,
  Chip,
  CircularProgress,
  Alert,
  Button
} from '@mui/material'
import RefreshIcon from '@mui/icons-material/Refresh'
import LoginIcon from '@mui/icons-material/Login'
import LogoutIcon from '@mui/icons-material/Logout'
import PeopleIcon from '@mui/icons-material/People'
import api from '../../api/axios'

export default function LiveMusterCard() {
  const [muster, setMuster] = useState([])
  const [stats, setStats] = useState({
    total: 0,
    inside: 0,
    outside: 0,
    visitors: 0,
    labours: 0
  })
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  useEffect(() => {
    fetchMuster()
    const interval = setInterval(fetchMuster, 15000) // Refresh every 15 seconds
    return () => clearInterval(interval)
  }, [])

  const fetchMuster = async () => {
    setLoading(true)
    try {
      const res = await api.get('/analytics/muster')
      if (res?.data?.data) {
        const data = res.data.data
        setMuster(data)

        // Calculate statistics
        const total = data.length
        const inside = data.filter((r) => r.current_status === 'IN').length
        const outside = data.filter((r) => r.current_status === 'OUT').length
        const visitors = data.filter((r) => r.person_type === 'VISITOR').length
        const labours = data.filter((r) => r.person_type === 'LABOUR').length

        setStats({ total, inside, outside, visitors, labours })
      }
      setError('')
    } catch (err) {
      setError(err?.response?.data?.error || 'Failed to fetch live muster')
    } finally {
      setLoading(false)
    }
  }

  return (
    <Card>
      <CardHeader
        title="Live Muster Dashboard"
        titleTypographyProps={{ variant: 'h6', fontWeight: 600 }}
        action={
          <Button
            size="small"
            startIcon={<RefreshIcon />}
            onClick={fetchMuster}
            disabled={loading}
          >
            Refresh
          </Button>
        }
        sx={{ borderBottom: '1px solid #eee' }}
      />
      <CardContent>
        {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}

        {loading && !muster.length ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', p: 3 }}>
            <CircularProgress size={30} />
          </Box>
        ) : (
          <>
            {/* KPI Statistics */}
            <Grid container spacing={1.5} sx={{ mb: 3 }}>
              <Grid size={{ xs: 6, md: 2.4 }}>
                <Box sx={{ textAlign: 'center', p: 1.5, backgroundColor: '#f5f5f5', borderRadius: 1 }}>
                  <PeopleIcon sx={{ color: '#2196f3', mb: 1 }} />
                  <Typography variant="h6" fontWeight={700} sx={{ color: '#2196f3' }}>
                    {stats.total}
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    Total Tracked
                  </Typography>
                </Box>
              </Grid>

              <Grid size={{ xs: 6, md: 2.4 }}>
                <Box sx={{ textAlign: 'center', p: 1.5, backgroundColor: '#e8f5e9', borderRadius: 1 }}>
                  <LoginIcon sx={{ color: '#4caf50', mb: 1 }} />
                  <Typography variant="h6" fontWeight={700} sx={{ color: '#4caf50' }}>
                    {stats.inside}
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    Inside
                  </Typography>
                </Box>
              </Grid>

              <Grid size={{ xs: 6, md: 2.4 }}>
                <Box sx={{ textAlign: 'center', p: 1.5, backgroundColor: '#ffebee', borderRadius: 1 }}>
                  <LogoutIcon sx={{ color: '#f44336', mb: 1 }} />
                  <Typography variant="h6" fontWeight={700} sx={{ color: '#f44336' }}>
                    {stats.outside}
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    Outside
                  </Typography>
                </Box>
              </Grid>

              <Grid size={{ xs: 6, md: 2.4 }}>
                <Box sx={{ textAlign: 'center', p: 1.5, backgroundColor: '#f3e5f5', borderRadius: 1 }}>
                  <Typography variant="h6" fontWeight={700} sx={{ color: '#9c27b0', mb: 0.5 }}>
                    {stats.visitors}
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    Visitors
                  </Typography>
                </Box>
              </Grid>

              <Grid size={{ xs: 6, md: 2.4 }}>
                <Box sx={{ textAlign: 'center', p: 1.5, backgroundColor: '#fff3e0', borderRadius: 1 }}>
                  <Typography variant="h6" fontWeight={700} sx={{ color: '#ff9800', mb: 0.5 }}>
                    {stats.labours}
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    Labours
                  </Typography>
                </Box>
              </Grid>
            </Grid>

            {/* Status Legend */}
            <Box sx={{ display: 'flex', gap: 1, justifyContent: 'center', flexWrap: 'wrap' }}>
              <Chip
                label={`Inside: ${stats.inside}`}
                color="success"
                size="small"
                icon={<LoginIcon />}
              />
              <Chip
                label={`Outside: ${stats.outside}`}
                size="small"
                icon={<LogoutIcon />}
              />
              <Chip
                label={`Visitors: ${stats.visitors}`}
                size="small"
                variant="outlined"
              />
              <Chip
                label={`Labours: ${stats.labours}`}
                size="small"
                variant="outlined"
              />
            </Box>

            {/* Last Updated */}
            <Typography
              variant="caption"
              color="text.secondary"
              sx={{ display: 'block', mt: 2, textAlign: 'center' }}
            >
              Last updated: {new Date().toLocaleTimeString()}
            </Typography>
          </>
        )}
      </CardContent>
    </Card>
  )
}
