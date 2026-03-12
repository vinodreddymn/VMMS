import React, { useState } from 'react'
import {
  Box,
  Button,
  Paper,
  TextField,
  Typography,
  Alert,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
} from '@mui/material'
import labourApi from '../api/labour.api'
import visitorApi from '../api/visitor.api'
import useAuthStore from '../store/auth.store'

export default function LabourTokenReturn() {
  const [step, setStep] = useState(1)
  const [supervisorId, setSupervisorId] = useState('')
  const [supervisor, setSupervisor] = useState(null)
  const [labours, setLabours] = useState([])

  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')

  const { user } = useAuthStore()
  const canForceCheckout = user?.role === 'SUPER_ADMIN' || user?.role === 'SECURITY_HEAD'

  const isRegisteredToday = (createdAt) => {
    if (!createdAt) return false
    const created = new Date(createdAt)
    const now = new Date()
    return (
      created.getFullYear() === now.getFullYear() &&
      created.getMonth() === now.getMonth() &&
      created.getDate() === now.getDate()
    )
  }

  const validateSupervisor = async () => {
    if (!supervisorId.trim()) return
    setLoading(true)
    setError('')
    setSuccess('')

    try {
      const res = await visitorApi.getVisitor(supervisorId.trim())
      const data = res?.data?.visitor
      if (!data) throw new Error('Supervisor not found')

      setSupervisor(data)
      setStep(2)

      const lRes = await labourApi.getLaboursBySupervisor(data.id || supervisorId.trim())
      const rows = (lRes?.data?.labours || []).filter((l) => isRegisteredToday(l.created_at))
      setLabours(rows)
    } catch (err) {
      const msg = err?.response?.data?.error || err?.response?.data?.message || err?.message
      setError(msg || 'Invalid Supervisor ID')
      setSupervisor(null)
      setLabours([])
    } finally {
      setLoading(false)
    }
  }

  const handleReturn = async (token_uid) => {
    if (!token_uid) return
    setLoading(true)
    setError('')
    setSuccess('')
    try {
      const res = await labourApi.returnLabourToken({ token_uid })
      setSuccess(res?.data?.message || 'Token returned successfully')

      const lRes = await labourApi.getLaboursBySupervisor(supervisor.id)
      const rows = (lRes?.data?.labours || []).filter((l) => isRegisteredToday(l.created_at))
      setLabours(rows)
    } catch (err) {
      const msg = err?.response?.data?.error || err?.response?.data?.message || err?.message
      setError(msg || 'Failed to return token')
      console.error('Token return error:', err?.response?.data || err)
    } finally {
      setLoading(false)
    }
  }

  const handleForceCheckout = async (labourId, labourName) => {
    const confirmed = window.confirm(
      `Force checkout ${labourName} so their token can be returned? This should only be used for stale records.`
    )
    if (!confirmed) return

    setLoading(true)
    setError('')
    setSuccess('')
    try {
      const res = await labourApi.forceCheckoutLabour(labourId)
      setSuccess(res?.data?.message || 'Labour checked out successfully. Now you can return their token.')

      // Refresh the labour list
      const lRes = await labourApi.getLaboursBySupervisor(supervisor.id)
      const rows = (lRes?.data?.labours || []).filter((l) => isRegisteredToday(l.created_at))
      setLabours(rows)
    } catch (err) {
      const status = err?.response?.status
      let msg = err?.response?.data?.error || err?.response?.data?.message || err?.message || 'Failed to force checkout labour'
      
      if (status === 403) {
        msg = 'You do not have permission to force checkout labour. This feature requires SUPER_ADMIN or SECURITY_HEAD role.'
      }
      
      setError(msg)
      console.error('Force checkout error:', err?.response?.data || err)
    } finally {
      setLoading(false)
    }
  }

  const handleReturnAll = async () => {
    if (!supervisor?.id) return
    const confirmed = window.confirm(
      `Return all active labour tokens for supervisor ${supervisor.full_name}?`
    )
    if (!confirmed) return

    setLoading(true)
    setError('')
    setSuccess('')
    try {
      const res = await labourApi.returnLabourToken({ supervisor_id: supervisor.id })
      const returnedCount = res?.data?.returned_count || 0
      setSuccess(
        returnedCount
          ? `Returned ${returnedCount} token(s) and cleared active supervisor mapping`
          : 'No active tokens found for this supervisor'
      )

      const lRes = await labourApi.getLaboursBySupervisor(supervisor.id)
      const rows = lRes?.data?.labours || []
      setLabours(rows)
    } catch (err) {
      const msg = err?.response?.data?.error || err?.response?.data?.message || err?.message
      setError(msg || 'Failed to return all tokens')
    } finally {
      setLoading(false)
    }
  }

  const handleReset = () => {
    setStep(1)
    setSupervisorId('')
    setSupervisor(null)
    setLabours([])
    setError('')
    setSuccess('')
  }

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h5" fontWeight="bold" mb={2}>
        RFID Token De-registration
      </Typography>

      <Paper sx={{ p: 3 }}>
        <Typography variant="body2" mb={2}>
          Tokens are valid only for today. Collect all issued tokens and return them here.
        </Typography>

        {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
        {success && <Alert severity="success" sx={{ mb: 2 }}>{success}</Alert>}

        {step === 1 && (
          <>
            <TextField
              label="Supervisor ID"
              value={supervisorId}
              onChange={(e) => setSupervisorId(e.target.value)}
              fullWidth
              sx={{ mb: 2 }}
            />

            <Button variant="contained" onClick={validateSupervisor} disabled={loading}>
              {loading ? 'Validating...' : 'Validate Supervisor'}
            </Button>
          </>
        )}

        {step === 2 && supervisor && (
          <>
            <Box sx={{ mb: 2 }}>
              <Typography variant="subtitle1" fontWeight="bold">
                Supervisor Details
              </Typography>
              <Typography><b>Name:</b> {supervisor.full_name}</Typography>
              <Typography><b>Phone:</b> {supervisor.primary_phone}</Typography>
              <Typography><b>Company:</b> {supervisor.company_name || '-'}</Typography>
            </Box>

            <Table size="small">
              <TableHead>
                <TableRow>
                  <TableCell>Labour ID</TableCell>
                  <TableCell>Name</TableCell>
                  <TableCell>Gender</TableCell>
                  <TableCell>Age</TableCell>
                  <TableCell>Phone</TableCell>
                  <TableCell>RFID Token</TableCell>
                  <TableCell>Action</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {labours.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={7} align="center">
                      No labour registrations found for today.
                    </TableCell>
                  </TableRow>
                ) : (
                  labours.map((l) => (
                    <TableRow key={l.id}>
                      <TableCell>{l.id}</TableCell>
                      <TableCell>{l.full_name}</TableCell>
                      <TableCell>{l.gender || '-'}</TableCell>
                      <TableCell>{l.age ?? '-'}</TableCell>
                      <TableCell>{l.phone || '-'}</TableCell>
                      <TableCell>{l.token_uid || '-'}</TableCell>
                      <TableCell>
                        <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
                          <Button
                            size="small"
                            variant="outlined"
                            disabled={loading || !l.token_uid}
                            onClick={() => handleReturn(l.token_uid)}
                          >
                            De-register
                          </Button>
                          {l.token_uid && canForceCheckout && (
                            <Button
                              size="small"
                              variant="outlined"
                              color="warning"
                              disabled={loading}
                              onClick={() => handleForceCheckout(l.id, l.full_name)}
                              title="Force checkout stale labour (requires SUPER_ADMIN or SECURITY_HEAD role)"
                            >
                              Force Checkout
                            </Button>
                          )}
                        </Box>
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>

            <Box sx={{ mt: 2 }}>
              <Button
                variant="contained"
                color="warning"
                onClick={handleReturnAll}
                disabled={loading}
                sx={{ mr: 1 }}
              >
                De-register All Tokens
              </Button>
              <Button onClick={handleReset}>Back</Button>
            </Box>
          </>
        )}
      </Paper>
    </Box>
  )
}
