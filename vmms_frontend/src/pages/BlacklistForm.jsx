import React, { useState } from 'react'
import Dialog from '@mui/material/Dialog'
import DialogTitle from '@mui/material/DialogTitle'
import DialogContent from '@mui/material/DialogContent'
import DialogActions from '@mui/material/DialogActions'
import TextField from '@mui/material/TextField'
import Button from '@mui/material/Button'
import MenuItem from '@mui/material/MenuItem'
import { addToBlacklist } from '../api/blacklist.api'

export default function BlacklistForm({ open, onClose, onSaved }) {
  const [loading, setLoading] = useState(false)
  const [errors, setErrors] = useState({})
  const [form, setForm] = useState({
    aadhaar: '',
    phone: '',
    biometric_hash: '',
    reason: '',
    block_type: 'TEMPORARY',
  })

  async function handleSave() {
    const nextErrors = {}
    const hasIdentifier = Boolean(form.aadhaar?.trim() || form.phone?.trim() || form.biometric_hash?.trim())
    if (!hasIdentifier) nextErrors.identity = 'Provide Aadhaar, Phone, or Biometric Hash'
    if (form.aadhaar && !/^\d{12}$/.test(form.aadhaar.trim())) nextErrors.aadhaar = 'Aadhaar must be 12 digits'
    if (form.phone && !/^\d{10,15}$/.test(form.phone.trim())) nextErrors.phone = 'Phone must be 10-15 digits'
    if (!form.reason?.trim()) nextErrors.reason = 'Reason is required'
    if (form.reason && form.reason.length > 240) nextErrors.reason = 'Reason too long (max 240 chars)'
    setErrors(nextErrors)
    if (Object.keys(nextErrors).length) return

    setLoading(true)
    try {
      await addToBlacklist({
        aadhaar: form.aadhaar.trim() || null,
        phone: form.phone.trim() || null,
        biometric_hash: form.biometric_hash.trim() || null,
        reason: form.reason.trim(),
        block_type: form.block_type,
      })
      onSaved && onSaved({ success: true })
      onClose()
    } catch (err) {
      console.error(err)
      onSaved && onSaved({ success: false, message: err?.response?.data?.error || 'Save failed' })
    } finally {
      setLoading(false)
    }
  }

  return (
    <Dialog open={open} onClose={onClose} fullWidth>
      <DialogTitle>Add to Blacklist</DialogTitle>
      <DialogContent>
        <div style={{ display: 'grid', gap: 12, marginTop: 8 }}>
          <TextField
            label="Aadhaar (12 digits)"
            value={form.aadhaar}
            onChange={(e) => setForm({ ...form, aadhaar: e.target.value })}
            error={Boolean(errors.aadhaar)}
            helperText={errors.aadhaar}
          />
          <TextField
            label="Phone"
            value={form.phone}
            onChange={(e) => setForm({ ...form, phone: e.target.value })}
            error={Boolean(errors.phone)}
            helperText={errors.phone}
          />
          <TextField
            label="Biometric Hash"
            value={form.biometric_hash}
            onChange={(e) => setForm({ ...form, biometric_hash: e.target.value })}
          />
          {errors.identity && (
            <div style={{ color: '#d32f2f', fontSize: 12 }}>{errors.identity}</div>
          )}
          <TextField
            label="Reason"
            value={form.reason}
            onChange={(e) => setForm({ ...form, reason: e.target.value })}
            error={Boolean(errors.reason)}
            helperText={errors.reason}
          />
          <TextField select label="Block Type" value={form.block_type} onChange={(e) => setForm({ ...form, block_type: e.target.value })}>
            <MenuItem value="TEMPORARY">TEMPORARY</MenuItem>
            <MenuItem value="PERMANENT">PERMANENT</MenuItem>
          </TextField>
        </div>
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose}>Cancel</Button>
        <Button variant="contained" onClick={handleSave} disabled={loading}>Save</Button>
      </DialogActions>
    </Dialog>
  )
}
