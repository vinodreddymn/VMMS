import React, { useEffect, useState } from 'react'
import {
  Alert,
  Box,
  Container,
  Paper,
  Typography,
  Tooltip,
  IconButton,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
} from '@mui/material'
import RefreshIcon from '@mui/icons-material/Refresh'
import api from '../api/axios'
import Loader from '../components/common/Loader'

const REFRESH_SECONDS = 10

const statusChip = (status) => (
  <Chip
    size="small"
    label={status ? 'ONLINE' : 'OFFLINE'}
    color={status ? 'success' : 'error'}
  />
)

const deviceChip = (status) => (
  <Chip
    size="small"
    label={status ? 'OK' : 'FAULT'}
    color={status ? 'success' : 'error'}
    variant="outlined"
  />
)

const usageChip = (value = 0) => {
  let color = 'success'
  if (value >= 85) color = 'error'
  else if (value >= 60) color = 'warning'
  return <Chip size="small" label={`${value}%`} color={color} />
}

export default function GateIssues() {
  const [gates, setGates] = useState([])
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [lastUpdated, setLastUpdated] = useState(null)
  const [countdown, setCountdown] = useState(REFRESH_SECONDS)

  const fetchHealth = async () => {
    setLoading(true)
    try {
      const res = await api.get('/gate/health')
      setGates(res.data.data || [])
      setError('')
      setLastUpdated(new Date())
      setCountdown(REFRESH_SECONDS)
    } catch (err) {
      setError(err?.response?.data?.error || 'Failed to fetch gate health')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchHealth()
  }, [])

  useEffect(() => {
    const timer = setInterval(() => {
      setCountdown((prev) => {
        if (prev <= 1) {
          fetchHealth()
          return REFRESH_SECONDS
        }
        return prev - 1
      })
    }, 1000)
    return () => clearInterval(timer)
  }, [])

  if (loading && !gates.length) return <Loader />

  return (
    <Container maxWidth="xl" sx={{ py: 3 }}>
      {/* Header */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
        <Typography variant="h4" fontWeight={700}>
          Gate Health Monitoring
        </Typography>

        <Tooltip title="Manual Refresh">
          <IconButton onClick={fetchHealth} color="primary">
            <RefreshIcon />
          </IconButton>
        </Tooltip>
      </Box>

      {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}

      {/* Matrix Table */}
      <TableContainer component={Paper}>
        <Table size="small">
          <TableHead>
            <TableRow>
              <TableCell sx={{ fontWeight: 700 }}>Metric</TableCell>
              {gates.map((gate) => (
                <TableCell
                  key={gate.gate_id}
                  align="center"
                  sx={{ fontWeight: 700 }}
                >
                  <Box>
                    <Typography fontWeight={700}>{gate.gate_name}</Typography>
                    <Typography variant="caption" color="text.secondary">
                      {gate.ip_address}
                    </Typography>
                  </Box>
                </TableCell>
              ))}
            </TableRow>
          </TableHead>

          <TableBody>
            {/* Gate Status */}
            <TableRow>
              <TableCell>Gate Status</TableCell>
              {gates.map((g) => (
                <TableCell key={g.gate_id} align="center">
                  {g.health ? statusChip(g.health.is_online) : '—'}
                </TableCell>
              ))}
            </TableRow>

            {/* CPU */}
            <TableRow>
              <TableCell>CPU Usage</TableCell>
              {gates.map((g) => (
                <TableCell key={g.gate_id} align="center">
                  {g.health ? usageChip(g.health.cpu_usage) : '—'}
                </TableCell>
              ))}
            </TableRow>

            {/* Memory */}
            <TableRow>
              <TableCell>Memory Usage</TableCell>
              {gates.map((g) => (
                <TableCell key={g.gate_id} align="center">
                  {g.health ? usageChip(g.health.memory_usage) : '—'}
                </TableCell>
              ))}
            </TableRow>

            {/* Storage */}
            <TableRow>
              <TableCell>Storage Usage</TableCell>
              {gates.map((g) => (
                <TableCell key={g.gate_id} align="center">
                  {g.health ? usageChip(g.health.storage_usage) : '—'}
                </TableCell>
              ))}
            </TableRow>

            {/* Camera */}
            <TableRow>
              <TableCell>Camera Status</TableCell>
              {gates.map((g) => (
                <TableCell key={g.gate_id} align="center">
                  {g.health ? deviceChip(g.health.camera_status) : '—'}
                </TableCell>
              ))}
            </TableRow>

            {/* RFID */}
            <TableRow>
              <TableCell>RFID Reader</TableCell>
              {gates.map((g) => (
                <TableCell key={g.gate_id} align="center">
                  {g.health ? deviceChip(g.health.rfid_status) : '—'}
                </TableCell>
              ))}
            </TableRow>

            {/* Biometric */}
            <TableRow>
              <TableCell>Biometric Device</TableCell>
              {gates.map((g) => (
                <TableCell key={g.gate_id} align="center">
                  {g.health ? deviceChip(g.health.biometric_status) : '—'}
                </TableCell>
              ))}
            </TableRow>

            {/* Heartbeat */}
            <TableRow>
              <TableCell>Last Heartbeat</TableCell>
              {gates.map((g) => (
                <TableCell key={g.gate_id} align="center">
                  {g.health?.last_heartbeat
                    ? new Date(g.health.last_heartbeat).toLocaleTimeString()
                    : '—'}
                </TableCell>
              ))}
            </TableRow>
          </TableBody>
        </Table>
      </TableContainer>

      {/* Footer */}
      <Box sx={{ mt: 2, textAlign: 'right' }}>
        <Typography variant="caption" color="text.secondary">
          {lastUpdated
            ? `Last updated: ${lastUpdated.toLocaleTimeString()} | Next refresh in ${countdown}s`
            : 'Not updated yet'}
        </Typography>
      </Box>
    </Container>
  )
}