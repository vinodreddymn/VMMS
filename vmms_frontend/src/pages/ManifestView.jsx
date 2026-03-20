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
  Chip
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

  // Fetch
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

  // Download
  const handleDownloadPdf = async () => {
    try {
      const res = await labourApi.getManifestPdf(id)
      const blob = new Blob([res.data], { type: 'application/pdf' })
      const url = window.URL.createObjectURL(blob)

      const link = document.createElement('a')
      link.href = url
      link.download = `manifest-${manifest?.id || id}.pdf`
      link.click()

      window.URL.revokeObjectURL(url)
    } catch (err) {
      console.error(err)
      setError('Failed to download PDF.')
    }
  }

  // Table Data
  const tableData = useMemo(
    () =>
      labours.map((labour, index) => ({
        ...labour,
        serial: index + 1
      })),
    [labours]
  )

  const columns = [
    { key: 'serial', label: '#', width: 60, align: 'center' },
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

  // States
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

  return (
    <Box
      sx={{
        p: 3,
        minHeight: '100vh',
        background: 'linear-gradient(135deg, #f1f5f9, #eef2ff)'
      }}
    >
      {/* HEADER */}
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
          <Typography variant="h5" fontWeight="bold">
            Labour Manifest #{manifest.id}
          </Typography>
          <Typography variant="body2" color="text.secondary">
            {formatDate(manifest.manifest_date)}
          </Typography>
        </Box>

        <Chip label={`${labours.length} Labours`} color="primary" />
      </Paper>

      {/* SUPERVISOR DETAILS - VERTICAL */}
      <Paper sx={{ p: 3, mb: 3, borderRadius: 3 }}>
        <Typography variant="h6" mb={2}>
          Supervisor & Project Details
        </Typography>

        <Stack spacing={2}>
          <Box>
            <Typography fontSize={12} color="text.secondary">Supervisor</Typography>
            <Typography fontWeight={600}>{manifest.supervisor_name || '-'}</Typography>
          </Box>

          <Box>
            <Typography fontSize={12} color="text.secondary">Company</Typography>
            <Typography fontWeight={600}>{manifest.company_name || '-'}</Typography>
          </Box>

          <Box>
            <Typography fontSize={12} color="text.secondary">Project</Typography>
            <Typography fontWeight={600}>{manifest.project_name || '-'}</Typography>
          </Box>

          <Box>
            <Typography fontSize={12} color="text.secondary">Primary Phone</Typography>
            <Typography fontWeight={600}>{manifest.primary_phone || '-'}</Typography>
          </Box>

          <Box>
            <Typography fontSize={12} color="text.secondary">Date</Typography>
            <Typography fontWeight={600}>{formatDate(manifest.manifest_date)}</Typography>
          </Box>
        </Stack>
      </Paper>

      {/* TABLE */}
      <Paper sx={{ p: 3, borderRadius: 3 }}>
        <Stack direction="row" justifyContent="space-between" mb={2}>
          <Typography variant="h6">Registered Labours</Typography>

          {/* SINGLE DOWNLOAD BUTTON */}
          <Button
            variant="contained"
            startIcon={<DownloadIcon />}
            onClick={handleDownloadPdf}
          >
            Download PDF
          </Button>
        </Stack>

        <DataTable columns={columns} data={tableData} />
      </Paper>

      <Divider sx={{ my: 4 }} />
    </Box>
  )
}