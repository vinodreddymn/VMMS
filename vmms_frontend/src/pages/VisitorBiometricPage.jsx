import React, { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import {
  Box,
  Typography,
  Paper,
  Button,
  Divider,
  CircularProgress,
  Chip,
  TextField,
  Alert
} from '@mui/material'
import {
  getVisitor,
  getBiometric,
  enrollBiometric,
  updateBiometric,
  deleteBiometric,
} from '../api/visitor.api'
import useAuthStore from '../store/auth.store'
import { normalizeRole, canEditVisitor } from '../utils/visitorPermissions'

export default function VisitorBiometricPage() {
  const { id } = useParams()
  const navigate = useNavigate()
  const user = useAuthStore((s) => s.user)
  const allowEdit = canEditVisitor(normalizeRole(user))

  const [loading, setLoading] = useState(true)
  const [submitting, setSubmitting] = useState(false)
  const [visitor, setVisitor] = useState(null)
  const [biometric, setBiometric] = useState(null)
  const [biometricData, setBiometricData] = useState('')
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')

  if (!allowEdit) {
    return (
      <Paper sx={{ p: 3, maxWidth: 720, mx: 'auto' }}>
        <Alert severity="warning" sx={{ mb: 2 }}>
          Biometric enrollment is restricted to ADMIN, SUPER_ADMIN, or REGULATING_PETTY_OFFICER.
        </Alert>
        <Button variant="contained" onClick={() => navigate(-1)}>
          Back
        </Button>
      </Paper>
    )
  }

  useEffect(() => {
    let mounted = true
    setLoading(true)

    Promise.all([getVisitor(id), getBiometric(id)])
      .then(([visitorRes, biometricRes]) => {
        if (!mounted) return
        setVisitor(visitorRes?.data?.visitor || null)
        setBiometric(biometricRes?.data?.biometric || null)
      })
      .finally(() => mounted && setLoading(false))

    return () => (mounted = false)
  }, [id])

  const handleSaveBiometric = async () => {
    if (!biometricData) {
      alert('Please provide biometric data')
      return
    }

    try {
      setSubmitting(true)
      setError('')
      setSuccess('')

      if (biometric) {
        await updateBiometric(id, {
          biometric_data: biometricData,
          algorithm: 'SHA256',
        })
      } else {
        await enrollBiometric(id, {
          visitor_id: id,
          biometric_data: biometricData,
          algorithm: 'SHA256'
        })
      }

      const latest = await getBiometric(id)
      setBiometric(latest?.data?.biometric || null)
      setBiometricData('')
      setSuccess(biometric ? 'Biometric updated successfully' : 'Biometric enrolled successfully')
    } catch (err) {
      console.error(err)
      setError(err?.response?.data?.error || 'Failed to save biometric')
    } finally {
      setSubmitting(false)
    }
  }

  const handleDeleteBiometric = async () => {
    const ok = window.confirm('Delete biometric data for this visitor?')
    if (!ok) return

    try {
      setSubmitting(true)
      setError('')
      setSuccess('')
      await deleteBiometric(id)
      setBiometric(null)
      setBiometricData('')
      setSuccess('Biometric deleted successfully')
    } catch (err) {
      console.error(err)
      setError(err?.response?.data?.error || 'Failed to delete biometric')
    } finally {
      setSubmitting(false)
    }
  }

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" mt={5}>
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Box>
      {/* Header */}
      <Paper sx={{ p: 3, mb: 2 }}>
        <Typography variant="h5" fontWeight={600}>
          Biometric Enrollment
        </Typography>
        <Typography color="text.secondary">
          Visitor: {visitor?.full_name} (Pass: {visitor?.pass_no})
        </Typography>
      </Paper>

      {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
      {success && <Alert severity="success" sx={{ mb: 2 }}>{success}</Alert>}

      {/* Current Status */}
      <Paper sx={{ p: 3, mb: 3 }}>
        <Typography variant="h6">Current Biometric Status</Typography>
        <Divider sx={{ my: 2 }} />

        {biometric ? (
          <Chip label={`Enrolled (${biometric.algorithm})`} color="success" />
        ) : (
          <Chip label="Not Enrolled" color="default" />
        )}
      </Paper>

      {/* Enrollment Form */}
      <Paper sx={{ p: 3 }}>
        <Typography variant="h6">
          {biometric ? 'Update Biometric' : 'Enroll New Biometric'}
        </Typography>
        <Divider sx={{ mb: 2 }} />

        {/* Placeholder input – replace with actual scanner integration later */}
        <TextField
          fullWidth
          label="Biometric Data (Scanner Output / Template)"
          multiline
          minRows={3}
          value={biometricData}
          onChange={(e) => setBiometricData(e.target.value)}
          placeholder="Paste fingerprint template / device output here"
        />

        <Divider sx={{ my: 3 }} />

        <Box display="flex" justifyContent="flex-end" gap={2}>
          <Button variant="outlined" onClick={() => navigate(-1)}>
            Cancel
          </Button>
          {biometric && (
            <Button
              variant="outlined"
              color="error"
              onClick={handleDeleteBiometric}
              disabled={submitting}
            >
              Delete Biometric
            </Button>
          )}
          <Button
            variant="contained"
            onClick={handleSaveBiometric}
            disabled={submitting}
          >
            {submitting ? <CircularProgress size={20} /> : biometric ? 'Update Biometric' : 'Enroll Biometric'}
          </Button>
        </Box>
      </Paper>
    </Box>
  )
}
