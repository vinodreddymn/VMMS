import React, { useEffect, useMemo, useState } from 'react'
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

import { getManifestsByDate } from '../api/labour.api'
import api from '../api/axios'

export default function LabourManifest() {
  const navigate = useNavigate()
  const [fromDate, setFromDate] = useState(() => {
    const d = new Date()
    d.setDate(d.getDate() - 7)
    return d.toISOString().split('T')[0]
  })

  const [toDate, setToDate] = useState(() =>
    new Date().toISOString().split('T')[0]
  )

  const [manifests, setManifests] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  // ================= FETCH DATA =================
  const fetchManifests = async () => {
    setLoading(true)
    setError('')

    try {
      const start = new Date(fromDate)
      const end = new Date(toDate)

      if (isNaN(start) || isNaN(end) || start > end) {
        throw new Error('Please provide a valid date range')
      }

      const days = []
      for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
        days.push(new Date(d))
      }

      const aggregated = []

      for (const day of days) {
        const dateStr = day.toISOString().split('T')[0]
        const res = await getManifestsByDate(dateStr)
        const list = res?.data?.manifests || res?.data || []

        const withCounts = list.map(m => ({
          ...m,
          labour_count:
            m.labour_count ??
            m.total_labours ??
            m.labours?.length ??
            0,
        }))

        aggregated.push(...withCounts)
      }

      setManifests(aggregated)

    } catch (err) {
      console.error(err)
      setError(
        err?.response?.data?.error ||
        err?.response?.data?.message ||
        err?.message ||
        'Failed to fetch manifests'
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
    return new Date(date).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' })
  }

  useEffect(() => {
    fetchManifests()
  }, [])

  const rows = useMemo(() => {
    return [...manifests].sort((a, b) => {
      const aTime = new Date(a.created_at || a.manifest_date || 0).getTime()
      const bTime = new Date(b.created_at || b.manifest_date || 0).getTime()
      return bTime - aTime
    })
  }, [manifests])

  return (
    <Container maxWidth="xxl" sx={{ py: 3 }}>
      <Typography variant="h4" fontWeight="bold" mb={3}>
        Labour Manifests
      </Typography>

      <Paper sx={{ p: 3 }}>

        {/* DATE FILTERS */}
        <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2} mb={3}>
          <TextField
            label="From Date"
            type="date"
            value={fromDate}
            onChange={(e) => setFromDate(e.target.value)}
            InputLabelProps={{ shrink: true }}
          />
          <TextField
            label="To Date"
            type="date"
            value={toDate}
            onChange={(e) => setToDate(e.target.value)}
            InputLabelProps={{ shrink: true }}
          />
          <Button
            variant="contained"
            onClick={fetchManifests}
            disabled={loading}
            sx={{ minWidth: 140 }}
          >
            {loading ? <CircularProgress size={20} /> : 'Apply Filter'}
          </Button>
        </Stack>

        {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}

        <Divider sx={{ mb: 3 }} />

        {loading ? (
          <Box display="flex" justifyContent="center" py={4}>
            <CircularProgress />
          </Box>
        ) : rows.length > 0 ? (
          <TableContainer>
            <Table size="small">

              <TableHead>
                <TableRow>
                  <TableCell><b>Sl. No</b></TableCell>
                  <TableCell><b>Date</b></TableCell>
                  <TableCell><b>Time Created</b></TableCell>
                  <TableCell><b>Manifest No</b></TableCell>
                  <TableCell><b>Supervisor Name</b></TableCell>
                  <TableCell><b>Company</b></TableCell>
                  <TableCell><b>Project</b></TableCell>
                  <TableCell><b>Phone Number</b></TableCell>
                  <TableCell><b>No. of Labours</b></TableCell>
                  <TableCell><b>Action</b></TableCell>
                </TableRow>
              </TableHead>

              <TableBody>
                {rows.map((m, idx) => {
                  const timeSource = m.created_at || m.manifest_date
                  return (
                    <TableRow key={m.id}>
                      <TableCell>{idx + 1}</TableCell>
                      <TableCell>{formatDate(timeSource)}</TableCell>
                      <TableCell>{formatTime(timeSource)}</TableCell>
                      <TableCell>{m.manifest_number || m.id}</TableCell>
                      <TableCell>{m.supervisor_name || '-'}</TableCell>
                      <TableCell>{m.company_name || '-'}</TableCell>
                      <TableCell>{m.project_name || m.project || '-'}</TableCell>
                      <TableCell>{m.phone || m.supervisor_phone || '-'}</TableCell>
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
                        <Button
                          size="small"
                          variant="contained"
                          onClick={() => navigate(`/labour/manifest/${m.id}`)}
                        >
                          View
                        </Button>
                      </Stack>
                    </TableCell>
                  </TableRow>
                  )
                })}
              </TableBody>

            </Table>
          </TableContainer>
        ) : (
          <Typography>No manifests found.</Typography>
        )}
      </Paper>
    </Container>
  )
}
import { useNavigate } from 'react-router-dom'
