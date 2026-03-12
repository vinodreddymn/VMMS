import React, { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import labourApi from '../api/labour.api'
import { Box, Typography, Paper, Button, Divider, CircularProgress, Alert, Stack } from '@mui/material'
import DataTable from '../components/common/DataTable'

export default function ManifestView() {
  const { id } = useParams()

  const [manifest, setManifest] = useState(null)
  const [labours, setLabours] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  // ===============================
  // Fetch Manifest Details
  // ===============================
  const fetchManifest = async () => {
    try {
      setLoading(true)
      setError(null)

      const res = await labourApi.getManifest(id)
      const payload = res?.data || {}

      setManifest(payload.manifest)
      setLabours(payload.labours || [])
    } catch (err) {
      console.error(err)
      setError('Failed to load manifest')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    if (id) fetchManifest()
  }, [id])

  // ===============================
  // Download PDF
  // ===============================
  const handleDownloadPdf = async () => {
    try {
      const res = await labourApi.getManifestPdf(id)
      const url = window.URL.createObjectURL(new Blob([res.data]))
      window.open(url)
    } catch (err) {
      console.error(err)
      setError('Failed to download PDF')
    }
  }

  const labourColumns = [
    { key: 'id', label: 'ID' },
    { key: 'full_name', label: 'Name' },
    { key: 'gender', label: 'Gender' },
    { key: 'age', label: 'Age' },
    { key: 'phone', label: 'Phone' },
    { key: 'token_uid', label: 'RFID Token' },
  ]

  if (loading) {
    return (
      <Box p={3} textAlign="center">
        <CircularProgress />
      </Box>
    )
  }

  if (error) {
    return (
      <Box p={3}>
        <Alert severity="error">{error}</Alert>
      </Box>
    )
  }

  if (!manifest) {
    return (
      <Box p={3}>
        <Typography>No manifest found.</Typography>
      </Box>
    )
  }

  return (
    <Box p={3}>
      {/* Header */}
      <Typography variant="h5" fontWeight="bold" mb={2}>
        Labour Manifest #{manifest.id}
      </Typography>

      {/* Supervisor Details */}
      <Paper sx={{ p: 2, mb: 3 }}>
        <Typography variant="h6" gutterBottom>
          Supervisor Details
        </Typography>
        <Typography><b>Name:</b> {manifest.supervisor_name}</Typography>
        <Typography><b>Company:</b> {manifest.company_name || '-'}</Typography>
        <Typography><b>Project:</b> {manifest.project_name || '-'}</Typography>
        <Typography><b>Phone:</b> {manifest.primary_phone || '-'}</Typography>
        <Typography><b>Date:</b> {manifest.manifest_date}</Typography>
      </Paper>

      {/* Labour List */}
      <Typography variant="h6" mb={2}>
        Registered Labours
      </Typography>

      <DataTable columns={labourColumns} data={labours} />

      <Divider sx={{ my: 3 }} />

      {/* Actions */}
      <Stack direction="row" spacing={2}>
        <Button variant="contained" onClick={handleDownloadPdf}>
          Download PDF
        </Button>
      </Stack>
    </Box>
  )
}
