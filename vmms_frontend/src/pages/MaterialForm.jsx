import React, { useState } from 'react'
import Dialog from '@mui/material/Dialog'
import DialogTitle from '@mui/material/DialogTitle'
import DialogContent from '@mui/material/DialogContent'
import DialogActions from '@mui/material/DialogActions'
import TextField from '@mui/material/TextField'
import Button from '@mui/material/Button'
import { createMaterial } from '../api/material.api'

export default function MaterialForm({ open, onClose, onSaved }) {
  const [loading, setLoading] = useState(false)
  const [form, setForm] = useState({ category: '', make: '', model: '', serial_number: '', description: '', is_returnable: false, unit: '' })

  async function handleSave() {
    setLoading(true)
    try {
      await createMaterial(form)
      onSaved && onSaved()
    } catch (err) {
      console.error(err)
      alert(err?.response?.data?.error || 'Save failed')
    } finally {
      setLoading(false)
    }
  }

  return (
    <Dialog open={open} onClose={onClose} fullWidth>
      <DialogTitle>New Material</DialogTitle>
      <DialogContent>
        <div style={{ display: 'grid', gap: 12, marginTop: 8 }}>
          <TextField label="Category" value={form.category} onChange={(e) => setForm({ ...form, category: e.target.value })} />
          <TextField label="Make" value={form.make} onChange={(e) => setForm({ ...form, make: e.target.value })} />
          <TextField label="Model" value={form.model} onChange={(e) => setForm({ ...form, model: e.target.value })} />
          <TextField label="Serial number" value={form.serial_number} onChange={(e) => setForm({ ...form, serial_number: e.target.value })} />
          <TextField label="Description" value={form.description} onChange={(e) => setForm({ ...form, description: e.target.value })} />
        </div>
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose}>Cancel</Button>
        <Button variant="contained" onClick={handleSave} disabled={loading}>Save</Button>
      </DialogActions>
    </Dialog>
  )
}
