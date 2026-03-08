import React, { useState } from 'react'
import {
  Container,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Button,
  TextField,
  Box,
  Typography,
  Alert,
  Divider,
  CircularProgress,
  Stack,
} from '@mui/material'
import PrintIcon from '@mui/icons-material/Print'
import {
  createManifest,
  getManifestHistoryBySupervisor,
} from '../api/labour.api'
import api from '../api/axios'

export default function LabourManifest() {
  const [supervisorInput, setSupervisorInput] = useState('')
  const [supervisor, setSupervisor] = useState(null)
  const [manifests, setManifests] = useState([])

  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')
  const [lastManifest, setLastManifest] = useState(null)

  const fetchSupervisorData = async () => {
    if (!supervisorInput.trim()) {
      setError('Please enter Supervisor Visitor ID or Pass No')
      return
    }

    setLoading(true)
    setError('')
    setSuccess('')
    setSupervisor(null)
    setManifests([])
    setLastManifest(null)

    try {
      const supRes = await api.get(`/visitors/${supervisorInput.trim()}`)
      const supData = supRes?.data?.visitor || supRes?.data?.data
      if (!supData) throw new Error('Supervisor not found')

      setSupervisor(supData)

      const manifestRes = await getManifestHistoryBySupervisor(supData.id)
      setManifests(manifestRes?.data?.manifests || [])
    } catch (err) {
      console.error(err)
      setError(err?.response?.data?.error || 'Invalid Supervisor ID/Pass No or failed to fetch data')
    } finally {
      setLoading(false)
    }
  }

  const handleGenerateManifest = async () => {
    if (!supervisor?.id) {
      setError('Validate supervisor first')
      return
    }

    const confirmed = window.confirm(
      `Generate a new manifest for supervisor ${supervisor.full_name}?`
    )
    if (!confirmed) return

    setLoading(true)
    setError('')
    setSuccess('')

    try {
      const res = await createManifest({
        supervisor_id: supervisor.id,
      })

      const manifest = res?.data?.manifest || null
      setLastManifest(manifest)
      setSuccess(
        manifest?.manifest_number
          ? `Manifest ${manifest.manifest_number} generated and saved as PDF.`
          : 'Manifest generated successfully.'
      )

      const historyRes = await getManifestHistoryBySupervisor(supervisor.id)
      setManifests(historyRes?.data?.manifests || [])
    } catch (err) {
      console.error(err)
      setError(err?.response?.data?.error || 'Failed to create manifest')
    } finally {
      setLoading(false)
    }
  }

  const handleOpenPdf = async (manifestId) => {
    try {
      const res = await api.get(`/labour/manifests/${manifestId}/pdf`, { responseType: 'blob' })
      const file = new Blob([res.data], { type: 'application/pdf' })
      const fileURL = URL.createObjectURL(file)
      window.open(fileURL, '_blank')
    } catch (err) {
      console.error(err)
      setError(err?.response?.data?.error || 'Failed to open manifest PDF')
    }
  }

  return (
    <Container maxWidth="lg" sx={{ py: 3 }}>
      <Typography variant="h4" fontWeight="bold" sx={{ mb: 3 }}>
        Labour Manifests
      </Typography>

      <Paper sx={{ p: 3 }}>
        <Box sx={{ display: 'flex', gap: 2, mb: 2 }}>
          <TextField
            label="Supervisor Visitor ID / Pass No"
            value={supervisorInput}
            onChange={(e) => setSupervisorInput(e.target.value)}
            fullWidth
          />
          <Button variant="contained" onClick={fetchSupervisorData} disabled={loading}>
            {loading ? <CircularProgress size={20} /> : 'Validate & Fetch'}
          </Button>
        </Box>

        {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
        {success && <Alert severity="success" sx={{ mb: 2 }}>{success}</Alert>}

        {supervisor && (
          <Box sx={{ mb: 2 }}>
            <Typography variant="h6">Supervisor Details</Typography>
            <Typography><b>Name:</b> {supervisor.full_name}</Typography>
            <Typography><b>Phone:</b> {supervisor.primary_phone || '-'}</Typography>
            <Typography><b>Company:</b> {supervisor.company_name || '-'}</Typography>
            <Typography><b>Can Register Labours:</b> {supervisor.can_register_labours ? 'Yes' : 'No'}</Typography>
          </Box>
        )}

        {lastManifest && (
          <Alert severity="info" sx={{ mb: 2 }}>
            Last Generated: {lastManifest.manifest_number || lastManifest.id}
          </Alert>
        )}

        <Divider sx={{ my: 2 }} />

        {supervisor && (
          <Box sx={{ mt: 2 }}>
            <Button
              variant="contained"
              color="secondary"
              onClick={handleGenerateManifest}
              disabled={loading}
            >
              Generate New Manifest
            </Button>
          </Box>
        )}

        <Divider sx={{ my: 3 }} />

        <Typography variant="h6" sx={{ mb: 1 }}>
          Manifest History
        </Typography>

        {!manifests.length ? (
          <Typography variant="body2">No manifests available for this supervisor.</Typography>
        ) : (
          <TableContainer>
            <Table size="small">
              <TableHead>
                <TableRow>
                  <TableCell>Manifest No</TableCell>
                  <TableCell>Date</TableCell>
                  <TableCell>Action</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {manifests.map((m) => (
                  <TableRow key={m.id}>
                    <TableCell>{m.manifest_number || m.id}</TableCell>
                    <TableCell>{m.manifest_date ? new Date(m.manifest_date).toLocaleDateString() : '-'}</TableCell>
                    <TableCell>
                      <Stack direction="row" spacing={1}>
                        <Button
                          size="small"
                          variant="outlined"
                          startIcon={<PrintIcon />}
                          onClick={() => handleOpenPdf(m.id)}
                        >
                          View PDF
                        </Button>
                      </Stack>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        )}
      </Paper>
    </Container>
  )
}
