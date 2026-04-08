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

const fileBase =
  import.meta.env.VITE_FILE_BASE_URL ||
  (import.meta.env.VITE_API_BASE_URL
    ? import.meta.env.VITE_API_BASE_URL.replace(/\/api\/?$/, '')
    : 'http://localhost:5000')

const makeUrl = (path) => {
  if (!path) return ''
  if (path.startsWith('http://') || path.startsWith('https://')) return path
  return `${fileBase}/${path.replace(/^\/+/, '')}`
}

const buildRegisteredPhotoUrl = (row, manifest) => {
  const path =
    row.registered_photo_path ||
    row.photo_path ||
    row.photo_url ||
    row.enrollment_photo_path

  if (!path) return ''

  if (path.includes('/')) return makeUrl(path)

  const supervisorId = manifest?.supervisor_id
  if (supervisorId) {
    return makeUrl(`uploads/visitors/${supervisorId}/manifests/${path}`)
  }
  return makeUrl(path)
}

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

const formatTime = (ts) => {
  if (!ts) return '-'
  return new Date(ts).toLocaleTimeString('en-IN', {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  })
}

const formatDuration = (start, end) => {
  if (!start || !end) return '-'
  const diffMs = new Date(end) - new Date(start)
  if (diffMs <= 0) return '-'
  const totalSec = Math.floor(diffMs / 1000)
  const hrs = Math.floor(totalSec / 3600)
  const mins = Math.floor((totalSec % 3600) / 60)
  const secs = totalSec % 60
  const parts = []
  if (hrs) parts.push(`${hrs}h`)
  if (mins || hrs) parts.push(`${mins}m`)
  parts.push(`${secs}s`)
  return parts.join(' ')
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
      key: 'registered_photo',
      label: 'Registered Photo',
      render: (_, row) =>
        (() => {
          const src = buildRegisteredPhotoUrl(row, manifest)
          if (src) {
            return (
              <Avatar
                src={src}
                sx={{ width: 42, height: 42, cursor: 'pointer' }}
                onClick={() => setPreviewImage(src)}
              />
            )
          }
          return (
            <Avatar sx={{ width: 42, height: 42 }}>
              {row.full_name?.[0] || '?'}
            </Avatar>
          )
        })()
    },
    {
      key: 'live_photo',
      label: 'Live Photo',
      render: (_, row) =>
        row.live_photo_path ? (
          <Avatar
            src={makeUrl(row.live_photo_path)}
            sx={{ width: 42, height: 42, cursor: 'pointer' }}
            onClick={() => setPreviewImage(makeUrl(row.live_photo_path))}
          />
        ) : (
          <Avatar sx={{ width: 42, height: 42, bgcolor: 'grey.300', color: 'text.secondary' }}>
            -
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
    { key: 'token_uid', label: 'RFID Token' },
    {
      key: 'first_check_in',
      label: 'Check-In Time',
      render: (_, row) => formatTime(row.first_check_in)
    },
    {
      key: 'last_check_out',
      label: 'Check-Out Time',
      render: (_, row) => formatTime(row.last_check_out)
    },
    {
      key: 'duration_inside',
      label: 'Time Stayed Inside',
      render: (_, row) => {
        if (!row.first_check_in && !row.last_check_out) {
          return 'Did not check in'
        }
        return formatDuration(row.first_check_in, row.last_check_out)
      }
    }
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
      <Paper
        sx={{
          p: 3,
          mb: 3,
          borderRadius: 4,
          boxShadow: "0 4px 20px rgba(0,0,0,0.05)",
        }}
      >
        <Typography
          variant="h6"
          mb={2}
          sx={{ fontWeight: 600, letterSpacing: 0.5 }}
        >
          Supervisor Details
        </Typography>

        <Box
          display="grid"
          gridTemplateColumns={{ xs: "1fr", md: "2fr 1fr" }}
          gap={3}
          alignItems="center"
        >
          {/* LEFT - DETAILS */}
          <Box
            display="grid"
            gridTemplateColumns="repeat(auto-fit, minmax(220px, 1fr))"
            gap={2}
          >
            {[
              { label: "Supervisor", value: manifest.supervisor_name },
              { label: "Company", value: manifest.company_name },
              { label: "Project", value: manifest.project_name },
              { label: "Phone", value: manifest.primary_phone },
              { label: "Date", value: formatDate(manifest.manifest_date) },
            ].map((item, index) => (
              <Box
                key={index}
                sx={{
                  p: 1.5,
                  borderRadius: 2,
                  backgroundColor: "#f9fafb",
                }}
              >
                <Typography
                  variant="caption"
                  sx={{ color: "text.secondary", fontWeight: 500 }}
                >
                  {item.label}
                </Typography>

                <Typography
                  variant="body1"
                  sx={{ fontWeight: 600, mt: 0.5 }}
                >
                  {item.value || "-"}
                </Typography>
              </Box>
            ))}
          </Box>

          {/* RIGHT - PHOTO */}
          <Box
            display="flex"
            flexDirection="column"
            alignItems="center"
            justifyContent="center"
            sx={{
              p: 2,
              borderRadius: 3,
              background: "#f9fafb",
              border: "1px solid #e5e7eb",
            }}
          >
            <Typography
              variant="subtitle2"
              color="text.secondary"
              mb={1}
            >
              Registered Photo
            </Typography>

            <Avatar
              src={makeUrl(manifest.enrollment_photo_path || "")}
              sx={{
                width: 130,
                height: 130,
                borderRadius: 3,
                border: "3px solid white",
                boxShadow: "0 4px 12px rgba(0,0,0,0.1)",
              }}
              variant="rounded"
            >
              {manifest.supervisor_name?.[0] || "?"}
            </Avatar>

            <Typography
              variant="body2"
              mt={1.5}
              sx={{ fontWeight: 500 }}
            >
              {manifest.supervisor_name || "Unknown"}
            </Typography>
          </Box>
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
