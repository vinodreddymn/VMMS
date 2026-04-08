import React, { useEffect, useState, useCallback } from 'react'
import DataTable from '../components/common/DataTable'
import labourApi from '../api/labour.api'
import useAuthStore from '../store/auth.store'
import LabourForm from './LabourForm'
import Button from '@mui/material/Button'
import { useNavigate } from 'react-router-dom'
import Snackbar from '@mui/material/Snackbar'
import Alert from '@mui/material/Alert'
import Box from '@mui/material/Box'
import Typography from '@mui/material/Typography'
import Divider from '@mui/material/Divider'
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import Grid from '@mui/material/Grid'
import TextField from '@mui/material/TextField'
import Paper from '@mui/material/Paper'

export default function Labour() {
  const user = useAuthStore((s) => s.user)
  const navigate = useNavigate()

  const supervisorId = user?.visitor_id || user?.id

  const [manifests, setManifests] = useState([])
  const [selectedDate, setSelectedDate] = useState(new Date().toISOString().split('T')[0])

  const [analytics, setAnalytics] = useState({
    total_registered: 0,
    total_checked_in: 0,
    total_checked_out: 0,
    total_returned_tokens: 0,
  })

  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)

  const [formOpen, setFormOpen] = useState(false)
  const [snackbar, setSnackbar] = useState({
    open: false,
    severity: 'success',
    message: '',
  })

  // ===============================
  // Fetch Labour Analytics for Date
  // ===============================
  const fetchLabourAnalytics = useCallback(async (date) => {
    setLoading(true)
    setError(null)

    try {
      const res = await labourApi.getLabourAnalytics(date)
      const payload = res?.data || {}
      
      // Calculate analytics from manifest data
      const manifests = payload.manifests || []
      
      const totalRegistered = manifests.reduce((sum, m) => sum + (m.total_labours || 0), 0)
      const totalCheckedIn = manifests.reduce((sum, m) => sum + (m.checked_in || 0), 0)
      const totalCheckedOut = manifests.reduce((sum, m) => sum + (m.checked_out || 0), 0)
      const totalReturnedTokens = manifests.reduce((sum, m) => sum + (m.returned_tokens || 0), 0)

      setAnalytics({
        total_registered: totalRegistered,
        total_checked_in: totalCheckedIn,
        total_checked_out: totalCheckedOut,
        total_returned_tokens: totalReturnedTokens,
      })
      
      setManifests(manifests)
    } catch (err) {
      console.error('Fetch Labour Analytics Error:', err)
      setError('Failed to load labour analytics')
      setAnalytics({
        total_registered: 0,
        total_checked_in: 0,
        total_checked_out: 0,
        total_returned_tokens: 0,
      })
      setManifests([])
    } finally {
      setLoading(false)
    }
  }, [])

  // ===============================
  // Handle Date Change
  // ===============================
  const handleDateChange = (event) => {
    const newDate = event.target.value
    setSelectedDate(newDate)
    fetchLabourAnalytics(newDate)
  }

  // ===============================
  // Fetch data on component mount
  // ===============================
  useEffect(() => {
    if (!user) return
    fetchLabourAnalytics(selectedDate)
  }, [user, fetchLabourAnalytics])

  // ===============================
  // Auto-refresh every 10 seconds
  // ===============================
  useEffect(() => {
    const interval = setInterval(() => {
      fetchLabourAnalytics(selectedDate)
    }, 10000) // 10 seconds

    return () => clearInterval(interval)
  }, [selectedDate, fetchLabourAnalytics])

  // ===============================
  // Manifest Table Columns
  // ===============================
  const manifestColumns = [
    { key: 'supervisor_name', label: 'Supervisor Name' },
    { key: 'company_name', label: 'Company' },
    { key: 'phone', label: 'Phone Number' },
    { key: 'total_labours', label: 'No. of Labours Registered' },
  ]

  // ===============================
  // Analytics Card Component
  // ===============================
  const AnalyticsCard = ({ title, value, color = 'primary' }) => (
    <Card sx={{ boxShadow: 2 }}>
      <CardContent>
        <Typography color="textSecondary" gutterBottom>
          {title}
        </Typography>
        <Typography variant="h4" sx={{ color, fontWeight: 'bold' }}>
          {value}
        </Typography>
      </CardContent>
    </Card>
  )

  return (
    <Box sx={{ p: 3 }}>
      {/* Header */}
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h5" fontWeight="bold">
          Labour Analytics
        </Typography>

        <Box display="flex" gap={2}>
          <Button variant="contained" onClick={() => setFormOpen(true)}>
            Enroll Labours
          </Button>
          <Button variant="outlined" onClick={() => navigate('/labour/tokens/return')}>
            Return Tokens
          </Button>
        </Box>
      </Box>

      {/* Date Picker */}
      <Box mb={3}>
        <TextField
          label="Select Date"
          type="date"
          value={selectedDate}
          onChange={handleDateChange}
          InputLabelProps={{
            shrink: true,
          }}
          sx={{ width: 200 }}
        />
      </Box>

      {/* Analytics Cards */}
      {loading ? (
        <Typography mt={2}>Loading analytics...</Typography>
      ) : error ? (
        <Typography mt={2} color="error">
          {error}
        </Typography>
      ) : (
        <>
          <Grid container spacing={2} mb={4}>
            <Grid size={{ xs: 12, sm: 6, md: 3 }}>
              <AnalyticsCard
                title="Total Labours Registered/Tokens Issued"
                value={analytics.total_registered}
                color="#2196F3"
              />
            </Grid>
            <Grid size={{ xs: 12, sm: 6, md: 3 }}>
              <AnalyticsCard
                title="Total Labours Checked In"
                value={analytics.total_checked_in}
                color="#4CAF50"
              />
            </Grid>
            <Grid size={{ xs: 12, sm: 6, md: 3 }}>
              <AnalyticsCard
                title="Total Labours Checked Out"
                value={analytics.total_checked_out}
                color="#FF9800"
              />
            </Grid>
            <Grid size={{ xs: 12, sm: 6, md: 3 }}>
              <AnalyticsCard
                title="Total Tokens Returned"
                value={analytics.total_returned_tokens}
                color="#F44336"
              />
            </Grid>
          </Grid>

          {/* Divider */}
          <Divider sx={{ my: 3 }} />

          {/* Manifests Section */}
          <Typography variant="h6" fontWeight="bold" mb={2}>
            Manifests for {selectedDate}
          </Typography>

          {!manifests.length ? (
            <Typography>No manifests generated for this date.</Typography>
          ) : (
            <DataTable
              columns={manifestColumns}
              data={manifests}
              actions={[
                {
                  label: 'View Manifest',
                  onClick: (row) => {
                    console.log('Navigating to manifest:', row.id, row)
                    navigate(`/labour/manifest/${row.id}`)
                  },
                },
                {
                  label: 'Download PDF',
                  onClick: async (row) => {
                    try {
                      console.log('Downloading PDF for manifest:', row.id)
                      const res = await labourApi.getManifestPdf(row.id)
                      const blob = new Blob([res.data], { type: 'application/pdf' })
                      const url = window.URL.createObjectURL(blob)
                      const link = document.createElement('a')
                      link.href = url
                      link.download = `manifest-${row.manifest_number}.pdf`
                      document.body.appendChild(link)
                      link.click()
                      document.body.removeChild(link)
                      window.URL.revokeObjectURL(url)
                      
                      setSnackbar({
                        open: true,
                        severity: 'success',
                        message: 'PDF downloaded successfully',
                      })
                    } catch (err) {
                      console.error('Error downloading PDF:', err)
                      setSnackbar({
                        open: true,
                        severity: 'error',
                        message: 'Failed to download PDF: ' + err.message,
                      })
                    }
                  },
                },
              ]}
            />
          )}
        </>
      )}

      {/* Form Dialog */}
      <LabourForm
        open={formOpen}
        onClose={() => setFormOpen(false)}
        onSaved={(manifest) => {
          setSnackbar({
            open: true,
            severity: 'success',
            message: manifest?.manifest_number
              ? `Labours enrolled. Manifest ${manifest.manifest_number} generated.`
              : 'Labours enrolled successfully',
          })
          // Refresh data for today
          fetchLabourAnalytics(new Date().toISOString().split('T')[0])
        }}
      />

      {/* Snackbar */}
      <Snackbar
        open={snackbar.open}
        autoHideDuration={3000}
        onClose={() => setSnackbar((prev) => ({ ...prev, open: false }))}
      >
        <Alert severity={snackbar.severity} variant="filled">
          {snackbar.message}
        </Alert>
      </Snackbar>
    </Box>
  )
}
