import React, { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import labourApi from '../api/labour.api'
import { Paper, Typography, Grid, Divider } from '@mui/material'

export default function LabourDetail() {
  const { id } = useParams()
  const [labour, setLabour] = useState(null)

  useEffect(() => {
    let mounted = true
    labourApi
      .getLabour(id)
      .then((res) => {
        if (!mounted) return
        setLabour(res.data.data || res.data)
      })
      .catch(() => {})
    return () => (mounted = false)
  }, [id])

  return (
    <div style={{ padding: 20 }}>
        <Typography variant="h5" gutterBottom>
          Labour Details
        </Typography>

        {!labour ? (
          <Typography>Loading...</Typography>
        ) : (
          <Paper sx={{ p: 3 }}>
            <Grid container spacing={2}>
              <Grid item xs={12} md={6}>
                <Typography><b>Name:</b> {labour.full_name}</Typography>
              </Grid>

              <Grid item xs={12} md={6}>
                <Typography><b>Phone:</b> {labour.phone || 'N/A'}</Typography>
              </Grid>

              <Grid item xs={12} md={6}>
                <Typography><b>Gender:</b> {labour.gender || 'N/A'}</Typography>
              </Grid>

              <Grid item xs={12} md={6}>
                <Typography><b>Age:</b> {labour.age ?? 'N/A'}</Typography>
              </Grid>

              <Grid item xs={12} md={6}>
                <Typography>
                  <b>Aadhaar (Last 4):</b> {labour.aadhaar_last4 || '****'}
                </Typography>
              </Grid>

              <Grid item xs={12} md={6}>
                <Typography>
                  <b>Supervisor ID:</b> {labour.supervisor_id}
                </Typography>
              </Grid>

              <Grid item xs={12} md={6}>
                <Typography>
                  <b>RFID UID:</b> {labour.token_uid || 'Not Assigned'}
                </Typography>
              </Grid>

              <Grid item xs={12} md={6}>
                <Typography>
                  <b>RFID Valid Until:</b>{' '}
                  {labour.valid_until
                    ? new Date(labour.valid_until).toLocaleString()
                    : 'N/A'}
                </Typography>
              </Grid>

              <Grid item xs={12}>
                <Divider sx={{ my: 1 }} />
              </Grid>

              <Grid item xs={12}>
                <Typography variant="body2" color="text.secondary">
                  <b>Registered On:</b>{' '}
                  {labour.created_at
                    ? new Date(labour.created_at).toLocaleString()
                    : 'N/A'}
                </Typography>
              </Grid>
            </Grid>
          </Paper>
        )}
    </div>
  )
}
