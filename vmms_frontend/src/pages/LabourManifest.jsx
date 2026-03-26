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
  Card,
  CardContent,
} from '@mui/material'
import PrintIcon from '@mui/icons-material/Print'

import { getManifestHistoryBySupervisor } from '../api/labour.api'
import api from '../api/axios'

export default function LabourManifest() {
  const [supervisorInput, setSupervisorInput] = useState('')
  const [supervisor, setSupervisor] = useState(null)
  const [manifests, setManifests] = useState([])

  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  // ================= FETCH DATA =================
  const fetchSupervisorData = async () => {
    if (!supervisorInput.trim()) {
      return setError('Please enter Supervisor Visitor ID or Pass No')
    }

    setLoading(true)
    setError('')
    setSupervisor(null)
    setManifests([])

    try {
      const res = await api.get(`/visitors/${supervisorInput.trim()}`)
      const sup = res?.data?.visitor || res?.data?.data

      if (!sup) throw new Error('Supervisor not found')

      setSupervisor(sup)

      const historyRes = await getManifestHistoryBySupervisor(sup.id)

      const manifestsWithCount = (historyRes?.data?.manifests || []).map(m => ({
        ...m,
        labour_count:
          m.labour_count ??
          m.total_labours ??
          m.labours?.length ??
          0,
      }))

      setManifests(manifestsWithCount)

    } catch (err) {
      console.error(err)
      setError(
        err?.response?.data?.error ||
        'Invalid Supervisor ID / Failed to fetch data'
      )
    } finally {
      setLoading(false)
    }
  }

  // ================= OPEN PDF =================
  const handleOpenPdf = async (manifestId) => {
    try {
      const res = await api.get(
        `/labour/manifests/${manifestId}/pdf`,
        { responseType: 'blob' }
      )

      const file = new Blob([res.data], { type: 'application/pdf' })
      const url = URL.createObjectURL(file)

      window.open(url, '_blank')

    } catch (err) {
      console.error(err)
      setError('Failed to open manifest PDF')
    }
  }

  // ================= DATE FORMATTERS =================
  const formatDate = (date) => {
    if (!date) return '-'
    return new Date(date).toLocaleDateString()
  }

  const formatTime = (date) => {
    if (!date) return '-'
    return new Date(date).toLocaleTimeString()
  }

  return (
    <Container maxWidth="xl" sx={{ py: 3 }}>
      <Typography variant="h4" fontWeight="bold" mb={3}>
        Manifest History
      </Typography>

      <Paper sx={{ p: 3 }}>

        {/* SEARCH */}
        <Box display="flex" gap={2} mb={2}>
          <TextField
            label="Supervisor Visitor ID / Pass No"
            value={supervisorInput}
            onChange={(e) => setSupervisorInput(e.target.value)}
            fullWidth
          />

          <Button
            variant="contained"
            onClick={fetchSupervisorData}
            disabled={loading}
          >
            {loading ? <CircularProgress size={20} /> : 'Fetch'}
          </Button>
        </Box>

        {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}

        {/* SUPERVISOR */}
        {supervisor && (
          <Card sx={{ mb: 3 }}>
            <CardContent>
              <Typography variant="h6">Supervisor Details</Typography>
              <Typography><b>Name:</b> {supervisor.full_name}</Typography>
              <Typography><b>Phone:</b> {supervisor.primary_phone || '-'}</Typography>
              <Typography><b>Company:</b> {supervisor.company_name || '-'}</Typography>
            </CardContent>
          </Card>
        )}

        <Divider sx={{ mb: 3 }} />

        <Typography variant="h6" mb={2}>
          Manifests
        </Typography>

        {loading ? (
          <Box display="flex" justifyContent="center" py={4}>
            <CircularProgress />
          </Box>
        ) : manifests.length > 0 ? (
          <TableContainer>
            <Table size="small">

              <TableHead>
                <TableRow>
                  <TableCell><b>Manifest No</b></TableCell>
                  <TableCell><b>Date</b></TableCell>
                  <TableCell><b>Time Created</b></TableCell>
                  <TableCell><b>No. of Labours</b></TableCell>
                  <TableCell><b>Action</b></TableCell>
                </TableRow>
              </TableHead>

              <TableBody>
                {manifests.map((m) => (
                  <TableRow key={m.id}>
                    <TableCell>{m.manifest_number || m.id}</TableCell>

                    <TableCell>{formatDate(m.manifest_date)}</TableCell>

                    {/* 🔹 NEW COLUMN */}
                    <TableCell>{formatTime(m.manifest_date)}</TableCell>

                    <TableCell>
                      <b>{m.labour_count}</b>
                    </TableCell>

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
        ) : (
          supervisor && <Typography>No manifests found.</Typography>
        )}
      </Paper>
    </Container>
  )
}