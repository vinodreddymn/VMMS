import React, { useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import {
  Box,
  Typography,
  Paper,
  Button,
  TextField,
  Grid,
  MenuItem,
  Chip,
  Divider,
  Stack,
  CircularProgress,
  Alert
} from '@mui/material'
import { uploadVisitorDocument } from '../api/visitor.api'
import useAuthStore from '../store/auth.store'
import { normalizeRole, canEditVisitor } from '../utils/visitorPermissions'

const DOC_TYPES = [
  'AADHAAR',
  'PASSPORT',
  'DRIVING_LICENSE',
  'COMPANY_ID',
  'VOTER_ID',
  'OTHER'
]

export default function VisitorDocumentUpload() {
  const { id } = useParams()
  const navigate = useNavigate()
  const user = useAuthStore((s) => s.user)
  const allowEdit = canEditVisitor(normalizeRole(user))

  const [loading, setLoading] = useState(false)
  const [docType, setDocType] = useState('')
  const [docNumber, setDocNumber] = useState('')
  const [expiryDate, setExpiryDate] = useState('')
  const [file, setFile] = useState(null)

  if (!allowEdit) {
    return (
      <Paper sx={{ p: 3, maxWidth: 720, mx: 'auto' }}>
        <Alert severity="warning" sx={{ mb: 2 }}>
          Document uploads are restricted to ADMIN, SUPER_ADMIN, or REGULATING_PETTY_OFFICER.
        </Alert>
        <Button variant="contained" onClick={() => navigate(-1)}>
          Back
        </Button>
      </Paper>
    )
  }

  const handleFileChange = (e) => {
    setFile(e.target.files?.[0] || null)
  }

  const handleSubmit = async () => {
    if (!docType || !file) {
      alert('Please select document type and file')
      return
    }

    try {
      setLoading(true)

      const formData = new FormData()
      formData.append('visitor_id', id)
      formData.append('doc_type', docType)
      formData.append('doc_number', docNumber)
      formData.append('expiry_date', expiryDate)

      formData.append('file', file)

      await uploadVisitorDocument(id, formData)

      navigate(`/visitors/${id}`)
    } catch (err) {
      console.error(err)
      alert('Document upload failed')
    } finally {
      setLoading(false)
    }
  }

  return (
    <Box>
      <Paper sx={{ p: 3, mb: 2 }}>
        <Typography variant="h5" fontWeight={600}>
          Upload Visitor Document
        </Typography>
        <Typography color="text.secondary">
          Visitor ID: {id}
        </Typography>
      </Paper>

      <Paper sx={{ p: 3 }}>
        <Typography variant="h6" gutterBottom>
          Document Details
        </Typography>
        <Divider sx={{ mb: 2 }} />

        <Grid container spacing={2}>
          <Grid item xs={12} md={6}>
            <TextField
              select
              fullWidth
              label="Document Type"
              value={docType}
              onChange={(e) => setDocType(e.target.value)}
            >
              {DOC_TYPES.map((type) => (
                <MenuItem key={type} value={type}>
                  {type}
                </MenuItem>
              ))}
            </TextField>
          </Grid>

          <Grid item xs={12} md={6}>
            <TextField
              fullWidth
              label="Document Number"
              value={docNumber}
              onChange={(e) => setDocNumber(e.target.value)}
            />
          </Grid>

          <Grid item xs={12} md={6}>
            <TextField
              type="date"
              fullWidth
              label="Expiry Date"
              value={expiryDate}
              onChange={(e) => setExpiryDate(e.target.value)}
              InputLabelProps={{ shrink: true }}
            />
          </Grid>

          <Grid item xs={12}>
            <Button variant="contained" component="label">
              Select File(s)
              <input hidden type="file" onChange={handleFileChange} />
            </Button>
          </Grid>
        </Grid>

        {file && (
          <Box mt={2}>
            <Typography variant="subtitle2">Selected Files:</Typography>
            <Stack direction="row" flexWrap="wrap" gap={1} mt={1}>
              <Chip label={file.name} />
            </Stack>
          </Box>
        )}

        <Divider sx={{ my: 3 }} />

        <Box display="flex" justifyContent="flex-end" gap={2}>
          <Button variant="outlined" onClick={() => navigate(-1)}>
            Cancel
          </Button>
          <Button
            variant="contained"
            onClick={handleSubmit}
            disabled={loading}
          >
            {loading ? <CircularProgress size={20} /> : 'Upload Document'}
          </Button>
        </Box>
      </Paper>
    </Box>
  )
}
