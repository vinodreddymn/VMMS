import React, { useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { Box, Button, Paper, Typography, Alert } from '@mui/material'
import { uploadVisitorPhoto } from '../api/visitor.api'
import useAuthStore from '../store/auth.store'
import { normalizeRole, canEditVisitor } from '../utils/visitorPermissions'

export default function VisitorPhotoUpload() {
  const { id } = useParams()
  const navigate = useNavigate()
  const user = useAuthStore((s) => s.user)
  const allowEdit = canEditVisitor(normalizeRole(user))

  const [file, setFile] = useState(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  if (!allowEdit) {
    return (
      <Paper sx={{ p: 3, maxWidth: 600, mx: 'auto' }}>
        <Alert severity="warning" sx={{ mb: 2 }}>
          Photo uploads are restricted to ADMIN, SUPER_ADMIN, or REGULATING_PETTY_OFFICER.
        </Alert>
        <Button variant="contained" onClick={() => navigate(-1)}>
          Back
        </Button>
      </Paper>
    )
  }

  const handleSubmit = async () => {
    if (!file) {
      setError('Please select a photo')
      return
    }

    setLoading(true)
    setError('')

    try {
      const formData = new FormData()
      formData.append('photo', file)

      await uploadVisitorPhoto(id, formData)
      navigate(`/visitors/${id}`)
    } catch (err) {
      const msg = err?.response?.data?.error || err?.message || 'Photo upload failed'
      setError(msg)
    } finally {
      setLoading(false)
    }
  }

  return (
    <Box>
      <Paper sx={{ p: 3, mb: 2 }}>
        <Typography variant="h5" fontWeight={600}>
          Upload Visitor Photo
        </Typography>
        <Typography color="text.secondary">Visitor ID: {id}</Typography>
      </Paper>

      <Paper sx={{ p: 3, maxWidth: 600 }}>
        {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}

        <Button variant="contained" component="label" sx={{ mb: 2 }}>
          Select Photo
          <input
            hidden
            type="file"
            accept="image/*"
            onChange={(e) => setFile(e.target.files?.[0] || null)}
          />
        </Button>

        {file && (
          <Typography variant="body2" sx={{ mb: 2 }}>
            Selected: {file.name}
          </Typography>
        )}

        <Box display="flex" gap={2} justifyContent="flex-end">
          <Button variant="outlined" onClick={() => navigate(-1)}>Cancel</Button>
          <Button variant="contained" onClick={handleSubmit} disabled={loading}>
            {loading ? 'Uploading...' : 'Upload Photo'}
          </Button>
        </Box>
      </Paper>
    </Box>
  )
}
