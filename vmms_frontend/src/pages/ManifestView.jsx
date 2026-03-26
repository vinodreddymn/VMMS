import React, { useEffect, useMemo, useState, useCallback } from 'react'
import { useParams } from 'react-router-dom'
import labourApi from '../api/labour.api'

import {
  Box,
  Typography,
  Paper,
  Button,
  Divider,
  CircularProgress,
  Alert,
  Stack,
  Chip,
  Avatar,
  Dialog
} from '@mui/material'

import DownloadIcon from '@mui/icons-material/Download'
import RefreshIcon from '@mui/icons-material/Refresh'

import DataTable from '../components/common/DataTable'

// ===============================
// Helpers
// ===============================
const formatDate = (date) => {
  if (!date) return '-'
  return new Date(date).toLocaleDateString('en-IN', {
    day: '2-digit',
    month: 'short',
    year: 'numeric'
  })
}

// ===============================
// Component
// ===============================
export default function ManifestView() {
  const { id } = useParams()

  const [manifest, setManifest] = useState(null)
  const [labours, setLabours] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  const [previewImage, setPreviewImage] = useState(null)

  // ================= FETCH =================
  const fetchManifest = useCallback(async () => {
    try {
      setLoading(true)
      setError(null)

      const res = await labourApi.getManifest(id)
      const payload = res?.data || {}

      setManifest(payload.manifest || null)
      setLabours(payload.labours || [])
    } catch (err) {
      console.error(err)
      setError('Unable to load manifest. Please try again.')
    } finally {
      setLoading(false)
    }
  }, [id])

  useEffect(() => {
    if (id) fetchManifest()
  }, [id, fetchManifest])

  // ================= DOWNLOAD =================
  const handleDownloadPdf = async () => {
    try {
      const res = await labourApi.getManifestPdf(id)
      const blob = new Blob([res.data], { type: 'application/pdf' })
      const url = window.URL.createObjectURL(blob)

      const link = document.createElement('a')
      link.href = url
      link.download = `manifest-${manifest?.manifest_number || id}.pdf`
      link.click()

      window.URL.revokeObjectURL(url)
    } catch (err) {
      console.error(err)
      setError('Failed to download PDF.')
    }
  }

  // ================= TABLE DATA =================
  const tableData = useMemo(
    () =>
      labours.map((labour, index) => ({
        ...labour,
        serial: index + 1
      })),
    [labours]
  )

  // ================= COLUMNS =================
  const columns = [
    { key: 'serial', label: '#', width: 60, align: 'center' },

    {
      key: 'photo',
      label: 'Photo',
      render: (_, row) =>
        row.photo_url ? (
          <Avatar
            src={row.photo_url}
            sx={{ width: 42, height: 42, cursor: 'pointer' }}
            onClick={() => setPreviewImage(row.photo_url)}
          />
        ) : (
          <Avatar sx={{ width: 42, height: 42 }}>
            {row.full_name?.[0] || '?'}
          </Avatar>
        )
    },

    { key: 'full_name', label: 'Name' },
    { key: 'gender', label: 'Gender', width: 90 },
    { key: 'age', label: 'Age', width: 70, align: 'center' },

    {
      key: 'aadhaar',
      label: 'Aadhaar',
      render: (_, row) =>
        row.aadhaar ||
        row.aadhaar_number ||
        row.aadhaar_last4 ||
        '-'
    },

    { key: 'phone', label: 'Phone' },
    { key: 'token_uid', label: 'RFID Token' }
  ]

  // ================= STATES =================
  if (loading) {
    return (
      <Box height="60vh" display="flex" alignItems="center" justifyContent="center">
        <CircularProgress />
      </Box>
    )
  }

  if (error) {
    return (
      <Box p={3}>
        <Alert
          severity="error"
          action={
            <Button onClick={fetchManifest} startIcon={<RefreshIcon />}>
              Retry
            </Button>
          }
        >
          {error}
        </Alert>
      </Box>
    )
  }

  if (!manifest) {
    return (
      <Box p={3}>
        <Alert severity="warning">No manifest data available.</Alert>
      </Box>
    )
  }

  // ================= UI =================
  return (
    <Box sx={{ p: 3, background: '#f5f7fb', minHeight: '100vh' }}>

      {/* ===== HEADER ===== */}
      <Paper
        sx={{
          p: 3,
          mb: 3,
          borderRadius: 3,
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center'
        }}
      >
        <Box>
          <Typography variant="h5" fontWeight={700}>
            Manifest #{manifest.manifest_number || manifest.id}
          </Typography>

          <Typography variant="body2" color="text.secondary">
            {formatDate(manifest.manifest_date)}
          </Typography>
        </Box>

        <Stack direction="row" spacing={2}>
          <Chip label={`${labours.length} Labours`} color="primary" />

          <Button
            variant="outlined"
            startIcon={<RefreshIcon />}
            onClick={fetchManifest}
          >
            Refresh
          </Button>

          <Button
            variant="contained"
            startIcon={<DownloadIcon />}
            onClick={handleDownloadPdf}
          >
            Download
          </Button>
        </Stack>
      </Paper>

      {/* ===== SUPERVISOR ===== */}
      <Paper sx={{ p: 3, mb: 3, borderRadius: 3 }}>
        <Typography variant="h6" mb={2}>
          Supervisor Details
        </Typography>

        <Box display="flex" flexDirection="column" gap={1.5}>
          <Typography><strong>Supervisor:</strong> {manifest.supervisor_name}</Typography>
          <Typography><strong>Company:</strong> {manifest.company_name}</Typography>
          <Typography><strong>Project:</strong> {manifest.project_name}</Typography>
          <Typography><strong>Phone:</strong> {manifest.primary_phone}</Typography>
          <Typography><strong>Date:</strong> {formatDate(manifest.manifest_date)}</Typography>
        </Box>
      </Paper>

      {/* ===== TABLE ===== */}
      <Paper sx={{ p: 3, borderRadius: 3 }}>
        <Typography variant="h6" mb={2}>
          Registered Labours
        </Typography>

        <DataTable columns={columns} data={tableData} />
      </Paper>

      {/* ===== IMAGE PREVIEW MODAL ===== */}
      <Dialog open={!!previewImage} onClose={() => setPreviewImage(null)}>
        <Box
          component="img"
          src={previewImage}
          alt="preview"
          sx={{ maxWidth: '90vw', maxHeight: '90vh' }}
        />
      </Dialog>

      <Divider sx={{ my: 4 }} />
    </Box>
  )
}

// ================= SUB COMPONENT =================
function Info({ label, value }) {
  return (
    <Box minWidth={150}>
      <Typography fontSize={12} color="text.secondary">
        {label}
      </Typography>
      <Typography fontWeight={600}>
        {value || '-'}
      </Typography>
    </Box>
  )
}