import React, { useEffect, useState } from 'react'
import {
  Card,
  CardContent,
  CardHeader,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
  Box,
  CircularProgress,
  Alert,
  Paper
} from '@mui/material'
import api from '../../api/axios'

export default function EntryFeed() {
  const [entries, setEntries] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  useEffect(() => {
    fetchEntries()
    const interval = setInterval(fetchEntries, 10000) // Refresh every 10 seconds
    return () => clearInterval(interval)
  }, [])

  const fetchEntries = async () => {
    setLoading(true)
    try {
      const res = await api.get('/analytics/daily-stats?date=' + new Date().toISOString().split('T')[0])
      // Fetch live muster as entry feed
      const musterRes = await api.get('/analytics/muster')
      if (musterRes?.data?.data) {
        setEntries(musterRes.data.data.slice(0, 10))
      }
      setError('')
    } catch (err) {
      setError(err?.response?.data?.error || 'Failed to fetch entries')
    } finally {
      setLoading(false)
    }
  }

  return (
    <Card>
      <CardHeader
        title="Recent Access Events"
        titleTypographyProps={{ variant: 'h6', fontWeight: 600 }}
        sx={{ borderBottom: '1px solid #eee' }}
      />
      <CardContent sx={{ p: 0 }}>
        {error && <Alert severity="error" sx={{ m: 2 }}>{error}</Alert>}

        {loading && entries.length === 0 ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', p: 3 }}>
            <CircularProgress size={30} />
          </Box>
        ) : (
          <TableContainer component={Paper} elevation={0} sx={{ maxHeight: 400 }}>
            <Table size="small" stickyHeader>
              <TableHead>
                <TableRow sx={{ backgroundColor: '#f5f5f5' }}>
                  <TableCell>Name</TableCell>
                  <TableCell>Type</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell>Gate</TableCell>
                  <TableCell>Time</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {entries.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={5} align="center" sx={{ py: 3 }}>
                      No recent entries
                    </TableCell>
                  </TableRow>
                ) : (
                  entries.map((entry, idx) => (
                    <TableRow key={`${entry.person_id}-${idx}`} hover>
                      <TableCell sx={{ fontWeight: 500 }}>{entry.full_name || '-'}</TableCell>
                      <TableCell>
                        <Chip
                          label={entry.person_type || '-'}
                          size="small"
                          color={entry.person_type === 'LABOUR' ? 'warning' : 'primary'}
                          variant="outlined"
                        />
                      </TableCell>
                      <TableCell>
                        <Chip
                          label={entry.current_status || '-'}
                          size="small"
                          color={entry.current_status === 'IN' ? 'success' : 'default'}
                        />
                      </TableCell>
                      <TableCell>{entry.gate_name || '-'}</TableCell>
                      <TableCell sx={{ fontSize: '0.85rem' }}>
                        {entry.last_scan_time
                          ? new Date(entry.last_scan_time).toLocaleTimeString()
                          : '-'}
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </TableContainer>
        )}
      </CardContent>
    </Card>
  )
}
