import React, { useState, useEffect } from "react"
import { useNavigate, useParams } from "react-router-dom"

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
  Alert,
  IconButton,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  Tooltip
} from "@mui/material"

import EditIcon from "@mui/icons-material/Edit"
import DeleteIcon from "@mui/icons-material/Delete"
import VisibilityIcon from "@mui/icons-material/Visibility"

import {
  uploadVisitorDocument,
  getVisitorDocuments,
  extendVisitorDocument,
  deleteVisitorDocument
} from "../api/visitor.api"

import useAuthStore from "../store/auth.store"
import { normalizeRole, canEditVisitor } from "../utils/visitorPermissions"

const DOC_TYPES = [
  "AADHAAR",
  "COMPANY_ID",
  "VOTER_ID",
  "PASSPORT",
  "DRIVING_LICENSE",
  "VEHICLE_REGISTRATION_CERTIFICATE",
  "VEHICLE_EMISSION_TEST_CERTIFICATE",

  "POLICE_VERIFICATION_CERTIFICATE",
  "OTHER"
]

export default function VisitorDocumentUpload() {
  const { id } = useParams()
  const navigate = useNavigate()

  const user = useAuthStore((s) => s.user)
  const allowEdit = canEditVisitor(normalizeRole(user))

  const [documents, setDocuments] = useState([])
  const [loading, setLoading] = useState(false)
  const fileBase = import.meta.env.VITE_FILE_BASE_URL || "http://localhost:5000"

  const [docType, setDocType] = useState("")
  const [docNumber, setDocNumber] = useState("")
  const [expiryDate, setExpiryDate] = useState("")
  const [file, setFile] = useState(null)

  const [editDocId, setEditDocId] = useState(null)
  const [newExpiry, setNewExpiry] = useState("")

  useEffect(() => {
    loadDocuments()
  }, [])

  const loadDocuments = async () => {
    try {
      const res = await getVisitorDocuments(id)

      const docs =
        res?.data?.data ||
        res?.data?.documents ||
        res?.data ||
        []

      setDocuments(Array.isArray(docs) ? docs : [])

    } catch (err) {
      console.error("Error loading documents:", err)
      setDocuments([])
    }
  }

  const handleUpload = async () => {
    if (!docType || !file) {
      alert("Please select document type and file")
      return
    }

    try {
      setLoading(true)

      const formData = new FormData()
      formData.append("visitor_id", id)
      formData.append("doc_type", docType)
      formData.append("doc_number", docNumber)
      formData.append("expiry_date", expiryDate)
      formData.append("file", file)

      await uploadVisitorDocument(id, formData)

      setDocType("")
      setDocNumber("")
      setExpiryDate("")
      setFile(null)

      loadDocuments()

    } catch (err) {
      console.error(err)
      alert("Document upload failed")
    } finally {
      setLoading(false)
    }
  }

  const handleExtend = async (docId) => {
    if (!newExpiry) {
      alert("Select new expiry date")
      return
    }

    try {
      await extendVisitorDocument(docId, newExpiry)

      setEditDocId(null)
      setNewExpiry("")

      loadDocuments()
    } catch (err) {
      console.error(err)
    }
  }

  const handleDelete = async (docId) => {
    if (!window.confirm("Delete this document?")) return

    try {
      await deleteVisitorDocument(docId)
      loadDocuments()
    } catch (err) {
      console.error(err)
    }
  }

  if (!allowEdit) {
    return (
      <Paper sx={{ p: 3, maxWidth: 600, mx: "auto" }}>
        <Alert severity="warning">
          You do not have permission to upload documents.
        </Alert>
      </Paper>
    )
  }

  return (
    <Box>

      {/* Header */}

      <Paper sx={{ p: 3, mb: 3 }}>
        <Typography variant="h5" fontWeight={600}>
          Visitor Documents
        </Typography>
        <Typography color="text.secondary">
          Visitor ID: {id}
        </Typography>
      </Paper>

      {/* Upload Section */}

      <Paper sx={{ p: 3, mb: 3 }}>
        <Typography variant="h6">Upload New Document</Typography>

        <Divider sx={{ my: 2 }} />

        <Grid container spacing={2}>

          <Grid size={{ xs: 12, md: 6 }}>
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

          <Grid size={{ xs: 12, md: 6 }}>
            <TextField
              fullWidth
              label="Document Number"
              value={docNumber}
              onChange={(e) => setDocNumber(e.target.value)}
            />
          </Grid>

          <Grid size={{ xs: 12, md: 6 }}>
            <TextField
              type="date"
              fullWidth
              label="Expiry Date"
              value={expiryDate}
              onChange={(e) => setExpiryDate(e.target.value)}
              InputLabelProps={{ shrink: true }}
            />
          </Grid>

          <Grid size={{ xs: 12 }}>
            <Button variant="contained" component="label">
              Select File
              <input hidden type="file" onChange={(e) => setFile(e.target.files?.[0])} />
            </Button>
          </Grid>

        </Grid>

        {file && (
          <Box mt={2}>
            <Chip label={file.name} />
          </Box>
        )}

        <Box mt={3} display="flex" justifyContent="flex-end">
          <Button
            variant="contained"
            onClick={handleUpload}
            disabled={loading}
          >
            {loading ? <CircularProgress size={20} /> : "Upload Document"}
          </Button>
        </Box>

      </Paper>

      {/* Documents Table */}

      <Paper sx={{ p: 3 }}>

        <Typography variant="h6">Uploaded Documents</Typography>

        <Divider sx={{ my: 2 }} />

        <Table size="small">

          <TableHead>
            <TableRow>
              <TableCell>Type</TableCell>
              <TableCell>Number</TableCell>
              <TableCell>Expiry</TableCell>
              <TableCell width={220}>Actions</TableCell>
            </TableRow>
          </TableHead>

          <TableBody>

            {documents.length === 0 && (
              <TableRow>
                <TableCell colSpan={4} align="center">
                  No documents uploaded
                </TableCell>
              </TableRow>
            )}

            {documents.map((doc) => (
              <TableRow key={doc.id}>

                <TableCell>{doc.doc_type}</TableCell>
                <TableCell>{doc.doc_number}</TableCell>

                <TableCell>

                  {editDocId === doc.id ? (

                    <Stack direction="row" spacing={1}>

                      <TextField
                        type="date"
                        size="small"
                        value={newExpiry}
                        onChange={(e) => setNewExpiry(e.target.value)}
                      />

                      <Button
                        size="small"
                        variant="contained"
                        onClick={() => handleExtend(doc.id)}
                      >
                        Save
                      </Button>

                    </Stack>

                  ) : (
                    doc.expiry_date
                  )}

                </TableCell>

                <TableCell>

                  <Stack direction="row" spacing={1}>

                    <Tooltip title="Preview">
                      <IconButton
                        color="primary"
                        size="small"
                        onClick={() => {
                          if (doc.file_path) {
                            const url = `${fileBase}/${doc.file_path}`
                            window.open(url, "_blank", "noopener,noreferrer")
                          } else {
                            alert("File not available for this document")
                          }
                        }}
                      >
                        <VisibilityIcon />
                      </IconButton>
                    </Tooltip>

                    <Tooltip title="Extend Validity">
                      <IconButton
                        color="primary"
                        size="small"
                        onClick={() => {
                          setEditDocId(doc.id)
                          setNewExpiry(doc.expiry_date)
                        }}
                      >
                        <EditIcon />
                      </IconButton>
                    </Tooltip>

                    <Tooltip title="Delete Document">
                      <IconButton
                        color="error"
                        size="small"
                        onClick={() => handleDelete(doc.id)}
                      >
                        <DeleteIcon />
                      </IconButton>
                    </Tooltip>

                  </Stack>

                </TableCell>

              </TableRow>
            ))}

          </TableBody>

        </Table>

      </Paper>

    </Box>
  )
}
