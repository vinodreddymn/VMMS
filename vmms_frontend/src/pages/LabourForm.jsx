import React, { useEffect, useMemo, useState } from 'react'
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Button,
  Box,
  Typography,
  Divider,
  Autocomplete,
} from '@mui/material'
import visitorApi from '../api/visitor.api'
import labourApi from '../api/labour.api'

export default function LabourEnrollmentDialog({ open, onClose, onSaved }) {
  const [step, setStep] = useState(1)
  const [supervisorId, setSupervisorId] = useState('')
  const [supervisor, setSupervisor] = useState(null)

  const [labours, setLabours] = useState([
    { full_name: '', phone: '', aadhaar: '', token_uid: '' },
  ])

  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const [tokenQuery, setTokenQuery] = useState('')
  const [tokenOptions, setTokenOptions] = useState([])
  const [tokenLoading, setTokenLoading] = useState(false)

  const duplicateTokens = useMemo(() => {
    const counts = {}
    for (const row of labours) {
      const token = String(row.token_uid || '').trim()
      if (!token) continue
      counts[token] = (counts[token] || 0) + 1
    }
    return new Set(Object.keys(counts).filter((t) => counts[t] > 1))
  }, [labours])

  // ===============================
  // Validate Supervisor
  // ===============================
  const validateSupervisor = async () => {
    if (!supervisorId) return

    setLoading(true)
    setError(null)

    try {
      const res = await visitorApi.getVisitor(supervisorId)
      const data = res?.data?.visitor

      const canRegister = Boolean(data?.can_register_labours) || Boolean(data?.allows_labour)
      if (!data || !canRegister) {
        throw new Error('Supervisor not authorized for labour registration')
      }

      setSupervisor(data)
      setStep(2)
    } catch (err) {
      console.error(err)
      setError('Invalid Supervisor ID or not authorized')
      setSupervisor(null)
    } finally {
      setLoading(false)
    }
  }

  // ===============================
  // Labour Input Handling
  // ===============================
  const handleLabourChange = (index, field, value) => {
    const updated = [...labours]
    updated[index][field] = value
    setLabours(updated)
  }

  const addRow = () => {
    setLabours([...labours, { full_name: '', phone: '', aadhaar: '', token_uid: '' }])
  }

  const removeRow = (index) => {
    const updated = labours.filter((_, i) => i !== index)
    setLabours(updated)
  }

  // ===============================
  // Submit Labours + Create Manifest
  // ===============================
  const handleSubmit = async () => {
    const validRows = labours.filter((l) => l.full_name || l.aadhaar || l.token_uid)
    if (!validRows.length) {
      setError('Please add at least one labour')
      return
    }

    const duplicateToken = (() => {
      const seen = new Set()
      for (const row of validRows) {
        const token = String(row.token_uid || '').trim()
        if (!token) continue
        if (seen.has(token)) return token
        seen.add(token)
      }
      return null
    })()

    if (duplicateToken) {
      setError(`Duplicate RFID token entered: ${duplicateToken}. Each labour must have a unique token.`)
      return
    }

    const confirmed = window.confirm(
      `Confirm registration of ${validRows.length} labour(s) under supervisor ${supervisor?.full_name || supervisor?.id}?`
    )
    if (!confirmed) return

    try {
      setLoading(true)
      setError(null)
      const createdLabourIds = []

      for (const labour of validRows) {
        if (!labour.full_name || !labour.aadhaar || !labour.token_uid) {
          throw new Error('Name, Aadhaar, and RFID Token are required')
        }

        const res = await labourApi.createLabour({
          supervisor_id: supervisor.id,
          full_name: labour.full_name,
          phone: labour.phone,
          aadhaar: labour.aadhaar,
          token_uid: labour.token_uid,
        })

        const id = res?.data?.labour?.id
        if (id) createdLabourIds.push(id)
      }

      let manifest = null
      if (createdLabourIds.length) {
        const manifestRes = await labourApi.createManifest({
          supervisor_id: supervisor.id,
          labour_ids: createdLabourIds,
        })
        manifest = manifestRes?.data?.manifest || null
      }

      onSaved?.(manifest)
      handleClose()
    } catch (err) {
      console.error(err)
      const backendError =
        err?.response?.data?.error ||
        err?.response?.data?.message ||
        err?.message
      setError(backendError || 'Failed to enroll labours')
    } finally {
      setLoading(false)
    }
  }

  const handleClose = () => {
    setStep(1)
    setSupervisorId('')
    setSupervisor(null)
    setLabours([{ full_name: '', phone: '', aadhaar: '', token_uid: '' }])
    setError(null)
    onClose()
  }

  useEffect(() => {
    let active = true
    if (!tokenQuery) {
      setTokenOptions([])
      return undefined
    }

    setTokenLoading(true)
    const t = setTimeout(async () => {
      try {
        const res = await labourApi.getAvailableTokens(tokenQuery, 20)
        const rows = res?.data?.tokens || []
        if (active) {
          setTokenOptions(rows.map((r) => r.uid))
        }
      } catch (err) {
        if (active) setTokenOptions([])
      } finally {
        if (active) setTokenLoading(false)
      }
    }, 300)

    return () => {
      active = false
      clearTimeout(t)
    }
  }, [tokenQuery])

  return (
    <Dialog open={open} onClose={handleClose} maxWidth="lg" fullWidth>
      <DialogTitle>Labour Enrollment</DialogTitle>

      <DialogContent>
        {/* STEP 1: Supervisor Validation */}
        {step === 1 && (
          <Box>
            <Typography variant="subtitle1" mb={1}>
              Enter Supervisor ID / Pass No
            </Typography>

            <TextField
              fullWidth
              label="Supervisor ID"
              value={supervisorId}
              onChange={(e) => setSupervisorId(e.target.value)}
              margin="normal"
            />

            {error && (
              <Typography color="error" variant="body2">
                {error}
              </Typography>
            )}

            <Button
              variant="contained"
              onClick={validateSupervisor}
              disabled={loading}
              sx={{ mt: 2 }}
            >
              Validate Supervisor
            </Button>
          </Box>
        )}

        {/* STEP 2: Supervisor + Labour Entry */}
        {step === 2 && supervisor && (
          <Box>
            <Typography variant="h6" mb={1}>
              Supervisor Details
            </Typography>

            <Box mb={2}>
              <Typography><b>Name:</b> {supervisor.full_name}</Typography>
              <Typography><b>Company:</b> {supervisor.company_name || '-'}</Typography>
              <Typography><b>Phone:</b> {supervisor.primary_phone}</Typography>
            </Box>

            <Divider sx={{ my: 2 }} />

            <Typography variant="h6" mb={1}>
              Register Labours (RFID token required, valid only today)
            </Typography>

            {labours.map((labour, index) => {
              const tokenValue = String(labour.token_uid || '').trim()
              const isDuplicate = tokenValue && duplicateTokens.has(tokenValue)
              const usedTokens = new Set(
                labours
                  .map((l, i) => (i === index ? '' : String(l.token_uid || '').trim()))
                  .filter(Boolean)
              )
              const availableOptions = tokenOptions.filter(
                (t) => !usedTokens.has(t) || t === tokenValue
              )

              return (
              <Box key={index} display="flex" gap={2} mb={2} alignItems="center">
                <TextField
                  label="Full Name"
                  value={labour.full_name}
                  onChange={(e) => handleLabourChange(index, 'full_name', e.target.value)}
                  fullWidth
                  sx={{ flex: 1 }}
                />
                <TextField
                  label="Phone"
                  value={labour.phone}
                  onChange={(e) => handleLabourChange(index, 'phone', e.target.value)}
                  fullWidth
                  sx={{ flex: 0.9, minWidth: 140 }}
                />
                <TextField
                  label="Aadhaar"
                  value={labour.aadhaar}
                  onChange={(e) => handleLabourChange(index, 'aadhaar', e.target.value)}
                  fullWidth
                  sx={{ flex: 0.9, minWidth: 160 }}
                />
                <Autocomplete
                  freeSolo
                  options={availableOptions}
                  loading={tokenLoading}
                  value={labour.token_uid || ''}
                  onInputChange={(_, value) => {
                    handleLabourChange(index, 'token_uid', value)
                    setTokenQuery(value)
                  }}
                  renderInput={(params) => (
                    <TextField
                      {...params}
                      label="RFID Token"
                      fullWidth
                      sx={{ flex: 2.2, minWidth: 260 }}
                      error={Boolean(isDuplicate)}
                      helperText={
                        isDuplicate
                          ? 'This token is already selected for another labour'
                          : ''
                      }
                    />
                  )}
                />
                <Button color="error" onClick={() => removeRow(index)}>
                  Remove
                </Button>
              </Box>
              )
            })}

            <Button onClick={addRow}>+ Add Another Labour</Button>

            {error && (
              <Typography color="error" variant="body2" mt={2}>
                {error}
              </Typography>
            )}
          </Box>
        )}
      </DialogContent>

      <DialogActions>
        <Button onClick={handleClose}>Cancel</Button>
        {step === 2 && (
          <Button variant="contained" onClick={handleSubmit} disabled={loading}>
            Submit Labours
          </Button>
        )}
      </DialogActions>
    </Dialog>
  )
}
