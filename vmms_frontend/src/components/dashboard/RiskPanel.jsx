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
  Paper,
  Typography,
  Button
} from '@mui/material'
import SecurityIcon from '@mui/icons-material/Security'
import WarningIcon from '@mui/icons-material/Warning'
import ErrorIcon from '@mui/icons-material/Error'
import RefreshIcon from '@mui/icons-material/Refresh'
import api from '../../api/axios'

export default function RiskPanel() {
  const [risks, setRisks] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [criticalCount, setCriticalCount] = useState(0)
  const [highCount, setHighCount] = useState(0)

  useEffect(() => {
    fetchRisks()
    const interval = setInterval(fetchRisks, 30000) // Refresh every 30 seconds
    return () => clearInterval(interval)
  }, [])

  const fetchRisks = async () => {
    setLoading(true)
    try {
      const res = await api.get('/analytics/risk-scoring?limit=20')
      if (res?.data?.riskScores) {
        const data = res.data.riskScores
        setRisks(data)

        // Count risk levels
        const critical = data.filter((r) => r.risk_level === 'CRITICAL').length
        const high = data.filter((r) => r.risk_level === 'HIGH').length

        setCriticalCount(critical)
        setHighCount(high)
      }
      setError('')
    } catch (err) {
      setError(err?.response?.data?.error || 'Failed to fetch risk data')
    } finally {
      setLoading(false)
    }
  }

  const getRiskIcon = (level) => {
    switch (level) {
      case 'CRITICAL':
        return <ErrorIcon sx={{ color: '#d32f2f' }} />
      case 'HIGH':
        return <WarningIcon sx={{ color: '#f57c00' }} />
      default:
        return <SecurityIcon sx={{ color: '#fbc02d' }} />
    }
  }

  const getRiskChipColor = (level) => {
    switch (level) {
      case 'CRITICAL':
        return 'error'
      case 'HIGH':
        return 'warning'
      case 'MEDIUM':
        return 'default'
      default:
        return 'success'
    }
  }

  return (
    <Card>
      <CardHeader
        title="Security & Risk Alerts"
        titleTypographyProps={{ variant: 'h6', fontWeight: 600 }}
        action={
          <Button
            size="small"
            startIcon={<RefreshIcon />}
            onClick={fetchRisks}
            disabled={loading}
          >
            Refresh
          </Button>
        }
        sx={{ borderBottom: '1px solid #eee' }}
      />
      <CardContent sx={{ p: 0 }}>
        {/* Alert Summary */}
        {(criticalCount > 0 || highCount > 0) && (
          <Box sx={{ p: 2, backgroundColor: '#fff3e0', borderBottom: '1px solid #ffe0b2' }}>
            <Box sx={{ display: 'flex', gap: 2, alignItems: 'center' }}>
              {criticalCount > 0 && (
                <Alert severity="error" sx={{ mb: 0, flex: 1 }}>
                  <strong>{criticalCount}</strong> Critical Risk Alert{criticalCount > 1 ? 's' : ''}
                </Alert>
              )}
              {highCount > 0 && (
                <Alert severity="warning" sx={{ mb: 0, flex: 1 }}>
                  <strong>{highCount}</strong> High Risk Alert{highCount > 1 ? 's' : ''}
                </Alert>
              )}
            </Box>
          </Box>
        )}

        {error && <Alert severity="error" sx={{ m: 2 }}>{error}</Alert>}

        {loading && risks.length === 0 ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', p: 3 }}>
            <CircularProgress size={30} />
          </Box>
        ) : risks.length === 0 ? (
          <Box sx={{ p: 3, textAlign: 'center' }}>
            <SecurityIcon sx={{ fontSize: 40, color: '#4caf50', mb: 1 }} />
            <Typography variant="subtitle2" color="text.secondary">
              No Security Risks Detected
            </Typography>
          </Box>
        ) : (
          <TableContainer component={Paper} elevation={0} sx={{ maxHeight: 450 }}>
            <Table stickyHeader size="small">
              <TableHead>
                <TableRow sx={{ backgroundColor: '#f5f5f5' }}>
                  <TableCell>Name</TableCell>
                  <TableCell>Phone</TableCell>
                  <TableCell align="right">Risk Score</TableCell>
                  <TableCell>Level</TableCell>
                  <TableCell>Reason</TableCell>
                  <TableCell>Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {risks.map((risk) => (
                  <TableRow
                    key={risk.id}
                    hover
                    sx={{
                      backgroundColor:
                        risk.risk_level === 'CRITICAL'
                          ? '#ffebee'
                          : risk.risk_level === 'HIGH'
                          ? '#fff3e0'
                          : 'inherit'
                    }}
                  >
                    <TableCell sx={{ fontWeight: 500 }}>
                      {risk.full_name}
                      {risk.aadhaar_last4 && (
                        <Typography variant="caption" display="block" color="text.secondary">
                          Aadhaar: ...{risk.aadhaar_last4}
                        </Typography>
                      )}
                    </TableCell>
                    <TableCell>{risk.primary_phone || '-'}</TableCell>
                    <TableCell align="right" sx={{ fontWeight: 700 }}>
                      {risk.risk_score}
                    </TableCell>
                    <TableCell>
                      <Chip
                        label={risk.risk_level}
                        size="small"
                        color={getRiskChipColor(risk.risk_level)}
                        icon={getRiskIcon(risk.risk_level)}
                      />
                    </TableCell>
                    <TableCell sx={{ maxWidth: 150 }}>
                      <Box sx={{ fontSize: '0.85rem' }}>
                        {risk.is_blacklisted ? (
                          <Chip
                            label="BLACKLISTED"
                            size="small"
                            color="error"
                            sx={{ mb: 0.5, mr: 0.5 }}
                          />
                        ) : null}
                        {risk.failed_attempts > 0 ? (
                          <Typography variant="caption" display="block">
                            {risk.failed_attempts} failed attempt
                            {risk.failed_attempts > 1 ? 's' : ''}
                          </Typography>
                        ) : null}
                        {risk.low_biometric_matches > 0 ? (
                          <Typography variant="caption" display="block">
                            Low biometric match: {risk.low_biometric_matches}
                          </Typography>
                        ) : null}
                      </Box>
                    </TableCell>
                    <TableCell sx={{ textAlign: 'center' }}>
                      <Button
                        size="small"
                        variant="outlined"
                        color="error"
                        sx={{ textTransform: 'none', fontSize: '0.75rem' }}
                      >
                        Block
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        )}

        {/* Footer Stats */}
        {risks.length > 0 && (
          <Box sx={{ p: 1.5, backgroundColor: '#f9f9f9', borderTop: '1px solid #eee', fontSize: '0.85rem' }}>
            <Typography variant="caption" color="text.secondary">
              Showing {risks.length} visitor{risks.length > 1 ? 's' : ''} with security flags
            </Typography>
          </Box>
        )}
      </CardContent>
    </Card>
  )
}
