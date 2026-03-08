import React, { useEffect, useMemo, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import useAuthStore from '../store/auth.store'
import { normalizeRole, canCreateVisitor } from '../utils/visitorPermissions'
import {
  Box,
  Button,
  Paper,
  Typography,
  Stepper,
  Step,
  StepLabel,
  Grid,
  TextField,
  MenuItem,
  Chip,
  Divider,
  CircularProgress,
  Alert
} from '@mui/material'
import { getMasters } from '../api/master.api'
import {
  createVisitor,
  updateVisitor,
  getVisitor,
  uploadVisitorPhoto,
  uploadVisitorDocument,
  issueRFIDCard,
  enrollBiometric
} from '../api/visitor.api'

const DOC_TYPES = [
  'AADHAAR',
  'PASSPORT',
  'DRIVING_LICENSE',
  'COMPANY_ID',
  'VOTER_ID',
  'OTHER'
]

export default function VisitorWizard() {
  const navigate = useNavigate()
  const user = useAuthStore((s) => s.user)
  const role = normalizeRole(user)
  const allowCreate = canCreateVisitor(role)

  const steps = useMemo(() => ([
    'Profile',
    'Photo',
    'Documents',
    'RFID',
    'Biometric',
    'Finish'
  ]), [])

  const [activeStep, setActiveStep] = useState(0)
  const [loading, setLoading] = useState(false)
  const [mastersLoading, setMastersLoading] = useState(true)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')

  const [projects, setProjects] = useState([])
  const [departments, setDepartments] = useState([])
  const [visitorTypes, setVisitorTypes] = useState([])
  const [hosts, setHosts] = useState([])

  const [visitorId, setVisitorId] = useState(null)
  const [visitor, setVisitor] = useState(null)
  const [documents, setDocuments] = useState([])
  const [biometric, setBiometric] = useState(null)

  const [form, setForm] = useState({
    visitor_type_id: '',
    pass_no: '',
    project_id: '',
    department_id: '',
    host_id: '',
    entrance_id: '',
    first_name: '',
    last_name: '',
    designation: '',
    gender: '',
    company_name: '',
    company_address: '',
    primary_phone: '',
    alternate_phone: '',
    email: '',
    date_of_birth: '',
    blood_group: '',
    height_cm: '',
    visible_marks: '',
    temp_address: '',
    perm_address: '',
    work_order_no: '',
    work_order_expiry: '',
    police_verification_certificate_number: '',
    pvc_expiry: '',
    aadhaar: '',
    smartphone_allowed: false,
    smartphone_expiry: '',
    laptop_allowed: false,
    laptop_make: '',
    laptop_model: '',
    laptop_serial: '',
    laptop_expiry: '',
    ops_area_permitted: false,
    can_register_labours: false,
    valid_from: '',
    valid_to: ''
  })

  const [errors, setErrors] = useState({})

  const [photoFile, setPhotoFile] = useState(null)
  const [docType, setDocType] = useState('')
  const [docNumber, setDocNumber] = useState('')
  const [expiryDate, setExpiryDate] = useState('')
  const [docFile, setDocFile] = useState(null)

  const [issueDate, setIssueDate] = useState(new Date().toISOString().split('T')[0])
  const [rfidExpiry, setRfidExpiry] = useState('')

  const [biometricData, setBiometricData] = useState('')

  const toDateInput = (val) => (val ? new Date(val).toISOString().split('T')[0] : '')

  useEffect(() => {
    async function fetchMasters() {
      try {
        const res = await getMasters()
        const data = res.data.data
        setProjects(data.projects || [])
        setDepartments(data.departments || [])
        setVisitorTypes(data.visitorTypes || [])
        setHosts(data.hosts || [])
      } catch (err) {
        console.error('Failed to load master data', err)
      } finally {
        setMastersLoading(false)
      }
    }

    fetchMasters()
  }, [])

  const refreshVisitor = async (id) => {
    if (!id) return
    const res = await getVisitor(id)
    const v = res?.data?.visitor || null
    setVisitor(v)
    setDocuments(res?.data?.documents || [])
    setBiometric(res?.data?.biometric || null)
    if (v) {
      setForm((prev) => ({
        ...prev,
        ...v,
        aadhaar: '',
        date_of_birth: toDateInput(v.date_of_birth),
        work_order_expiry: toDateInput(v.work_order_expiry),
        pvc_expiry: toDateInput(v.pvc_expiry),
        smartphone_expiry: toDateInput(v.smartphone_expiry),
        laptop_expiry: toDateInput(v.laptop_expiry),
        valid_from: toDateInput(v.valid_from),
        valid_to: toDateInput(v.valid_to),
      }))
    }
  }

  const handleChange = (e) => {
    const { name, value } = e.target
    setForm((prev) => ({ ...prev, [name]: value }))
  }

  const toggleBool = (key) => {
    setForm((prev) => ({ ...prev, [key]: !prev[key] }))
  }

  const validateProfile = () => {
    const nextErrors = {}
    if (!form.first_name?.trim()) nextErrors.first_name = 'First name is required'
    if (!form.primary_phone?.trim()) nextErrors.primary_phone = 'Primary phone is required'
    if (!form.visitor_type_id) nextErrors.visitor_type_id = 'Visitor type is required'
    if (!visitorId && !form.pass_no?.trim()) nextErrors.pass_no = 'Pass number is required'
    if (!visitorId && !form.aadhaar?.trim()) nextErrors.aadhaar = 'Aadhaar is required'
    setErrors(nextErrors)
    return Object.keys(nextErrors).length === 0
  }

  const handleProfileSave = async () => {
    if (!validateProfile()) return false
    setLoading(true)
    setError('')
    setSuccess('')
    try {
      if (visitorId) {
        await updateVisitor(visitorId, form)
        await refreshVisitor(visitorId)
      } else {
        const res = await createVisitor(form)
        const id = res?.data?.visitor?.id
        if (!id) throw new Error('Failed to create visitor')
        setVisitorId(id)
        await refreshVisitor(id)
      }
      setSuccess('Profile saved')
      return true
    } catch (err) {
      setError(err?.response?.data?.error || err?.message || 'Failed to save profile')
      return false
    } finally {
      setLoading(false)
    }
  }

  const handlePhotoUpload = async () => {
    if (!visitorId) {
      setError('Save profile first')
      return false
    }
    if (!photoFile) {
      setError('Please select a photo')
      return false
    }
    setLoading(true)
    setError('')
    setSuccess('')
    try {
      const formData = new FormData()
      formData.append('photo', photoFile)
      await uploadVisitorPhoto(visitorId, formData)
      await refreshVisitor(visitorId)
      setSuccess('Photo uploaded')
      return true
    } catch (err) {
      setError(err?.response?.data?.error || err?.message || 'Photo upload failed')
      return false
    } finally {
      setLoading(false)
    }
  }

  const handleDocumentUpload = async () => {
    if (!visitorId) {
      setError('Save profile first')
      return false
    }
    if (!docType || !docFile) {
      setError('Select document type and file')
      return false
    }
    setLoading(true)
    setError('')
    setSuccess('')
    try {
      const formData = new FormData()
      formData.append('visitor_id', visitorId)
      formData.append('doc_type', docType)
      formData.append('doc_number', docNumber)
      formData.append('expiry_date', expiryDate)
      formData.append('file', docFile)

      await uploadVisitorDocument(visitorId, formData)
      await refreshVisitor(visitorId)
      setDocType('')
      setDocNumber('')
      setExpiryDate('')
      setDocFile(null)
      setSuccess('Document uploaded')
      return true
    } catch (err) {
      setError(err?.response?.data?.error || err?.message || 'Document upload failed')
      return false
    } finally {
      setLoading(false)
    }
  }

  const handleIssueRFID = async () => {
    if (!visitorId) {
      setError('Save profile first')
      return false
    }
    if (!rfidExpiry) {
      setError('Select RFID expiry date')
      return false
    }
    setLoading(true)
    setError('')
    setSuccess('')
    try {
      await issueRFIDCard(visitorId, {
        visitor_id: visitorId,
        issue_date: issueDate,
        expiry_date: rfidExpiry
      })
      await refreshVisitor(visitorId)
      setSuccess('RFID issued')
      return true
    } catch (err) {
      setError(err?.response?.data?.error || err?.message || 'RFID issuance failed')
      return false
    } finally {
      setLoading(false)
    }
  }

  const handleEnrollBiometric = async () => {
    if (!visitorId) {
      setError('Save profile first')
      return false
    }
    if (!biometricData) {
      setError('Provide biometric data')
      return false
    }
    setLoading(true)
    setError('')
    setSuccess('')
    try {
      await enrollBiometric(visitorId, {
        visitor_id: visitorId,
        biometric_data: biometricData,
        algorithm: 'SHA256'
      })
      await refreshVisitor(visitorId)
      setBiometricData('')
      setSuccess('Biometric enrolled')
      return true
    } catch (err) {
      setError(err?.response?.data?.error || err?.message || 'Biometric enrollment failed')
      return false
    } finally {
      setLoading(false)
    }
  }

  const handleNext = async () => {
    let ok = true
    if (activeStep === 0) ok = await handleProfileSave()
    if (activeStep === 1 && photoFile) ok = await handlePhotoUpload()
    if (activeStep === 2 && (docType || docFile)) ok = await handleDocumentUpload()
    if (activeStep === 3 && rfidExpiry) ok = await handleIssueRFID()
    if (activeStep === 4 && biometricData) ok = await handleEnrollBiometric()

    if (ok) setActiveStep((s) => Math.min(s + 1, steps.length - 1))
  }

  const handleBack = () => {
    setActiveStep((s) => Math.max(s - 1, 0))
  }

  const fileBase = import.meta.env.VITE_FILE_BASE_URL || 'http://localhost:5000'

  if (!allowCreate) {
    return (
      <AccessDenied
        title="Registration Restricted"
        message="Only ENROLLMENT_STAFF_VISITORS can register new visitors."
        onBack={() => navigate('/visitors')}
      />
    )
  }

  if (mastersLoading) {
    return (
      <Box display="flex" justifyContent="center" mt={5}>
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Box>
      <Paper
        sx={{
          p: 2.5,
          mb: 2,
          borderRadius: 3,
          border: '1px solid rgba(15,23,42,0.08)',
          background:
            'linear-gradient(135deg, rgba(15,23,42,0.92), rgba(14,116,144,0.92))',
          color: '#f8fafc',
          boxShadow: '0 16px 40px rgba(15,23,42,0.2)'
        }}
      >
        <Typography variant="h5" fontWeight={700}>
          Register Visitor
        </Typography>
        {visitorId && visitor?.pass_no && (
          <Typography sx={{ opacity: 0.8 }}>Pass No: {visitor.pass_no}</Typography>
        )}
        <Box sx={{ mt: 1, display: 'flex', gap: 1, flexWrap: 'wrap' }}>
          <Chip
            label={`Role: ${role}`}
            size="small"
            sx={{
              bgcolor: 'rgba(15,23,42,0.5)',
              color: '#e2e8f0',
              border: '1px solid rgba(255,255,255,0.15)',
              fontWeight: 600
            }}
          />
        </Box>
      </Paper>

      <Paper sx={{ p: 2, mb: 2 }}>
        <Stepper activeStep={activeStep} alternativeLabel>
          {steps.map((label) => (
            <Step key={label}>
              <StepLabel>{label}</StepLabel>
            </Step>
          ))}
        </Stepper>
      </Paper>

      <Paper sx={{ p: 3 }}>
        {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
        {success && <Alert severity="success" sx={{ mb: 2 }}>{success}</Alert>}

        {activeStep === 0 && (
          <Box>
            <Section title="Basic Information">
              <Grid container spacing={2}>
                <Field
                  select
                  label="Visitor Type"
                  name="visitor_type_id"
                  value={form.visitor_type_id}
                  onChange={handleChange}
                  error={Boolean(errors.visitor_type_id)}
                  helperText={errors.visitor_type_id}
                >
                  {visitorTypes.map((v) => (
                    <MenuItem key={v.id} value={v.id}>{v.type_name}</MenuItem>
                  ))}
                </Field>

                <Field
                  label="Pass Number"
                  name="pass_no"
                  value={form.pass_no}
                  onChange={handleChange}
                  error={Boolean(errors.pass_no)}
                  helperText={errors.pass_no}
                  disabled={Boolean(visitorId)}
                />

                <Field select label="Project" name="project_id" value={form.project_id} onChange={handleChange}>
                  {projects.map((p) => (
                    <MenuItem key={p.id} value={p.id}>{p.project_name}</MenuItem>
                  ))}
                </Field>

                <Field select label="Department" name="department_id" value={form.department_id} onChange={handleChange}>
                  {departments.map((d) => (
                    <MenuItem key={d.id} value={d.id}>{d.department_name}</MenuItem>
                  ))}
                </Field>

                <Field select label="Host" name="host_id" value={form.host_id} onChange={handleChange}>
                  {hosts.map((h) => (
                    <MenuItem key={h.id} value={h.id}>{h.host_name}</MenuItem>
                  ))}
                </Field>

                <Field
                  label="First Name"
                  name="first_name"
                  value={form.first_name}
                  onChange={handleChange}
                  error={Boolean(errors.first_name)}
                  helperText={errors.first_name}
                />
                <Field label="Last Name" name="last_name" value={form.last_name} onChange={handleChange} />
                <Field select label="Gender" name="gender" value={form.gender} onChange={handleChange}>
                  <MenuItem value="">Select</MenuItem>
                  <MenuItem value="MALE">Male</MenuItem>
                  <MenuItem value="FEMALE">Female</MenuItem>
                  <MenuItem value="OTHER">Other</MenuItem>
                </Field>
                <Field label="Designation" name="designation" value={form.designation} onChange={handleChange} />
                <Field label="Company Name" name="company_name" value={form.company_name} onChange={handleChange} />
                <Field fullWidth label="Company Address" name="company_address" value={form.company_address} onChange={handleChange} />

                <Field
                  label={visitorId ? 'Aadhaar (optional)' : 'Aadhaar'}
                  name="aadhaar"
                  value={form.aadhaar}
                  onChange={handleChange}
                  error={Boolean(errors.aadhaar)}
                  helperText={errors.aadhaar}
                />
                <Field label="Blood Group" name="blood_group" value={form.blood_group} onChange={handleChange} />
                <Field label="Height (cm)" name="height_cm" value={form.height_cm} onChange={handleChange} />
                <Field label="Visible Marks" name="visible_marks" value={form.visible_marks} onChange={handleChange} />
                <Field type="date" label="DOB" name="date_of_birth" value={form.date_of_birth} onChange={handleChange} InputLabelProps={{ shrink: true }} />
              </Grid>
            </Section>

            <Section title="Contact Details">
              <Grid container spacing={2}>
                <Field
                  label="Primary Phone"
                  name="primary_phone"
                  value={form.primary_phone}
                  onChange={handleChange}
                  error={Boolean(errors.primary_phone)}
                  helperText={errors.primary_phone}
                />
                <Field label="Alternate Phone" name="alternate_phone" value={form.alternate_phone} onChange={handleChange} />
                <Field fullWidth label="Email" name="email" value={form.email} onChange={handleChange} />
                <Field fullWidth label="Temporary Address" name="temp_address" value={form.temp_address} onChange={handleChange} />
                <Field fullWidth label="Permanent Address" name="perm_address" value={form.perm_address} onChange={handleChange} />
              </Grid>
            </Section>

            <Section title="Clearance & Compliance">
              <Grid container spacing={2}>
                <Field label="Work Order No" name="work_order_no" value={form.work_order_no} onChange={handleChange} />
                <Field
                  type="date"
                  label="Work Order Expiry"
                  name="work_order_expiry"
                  value={form.work_order_expiry}
                  onChange={handleChange}
                  InputLabelProps={{ shrink: true }}
                />
                <Field
                  label="Police Verification Certificate No"
                  name="police_verification_certificate_number"
                  value={form.police_verification_certificate_number}
                  onChange={handleChange}
                />
                <Field
                  type="date"
                  label="PVC Expiry"
                  name="pvc_expiry"
                  value={form.pvc_expiry}
                  onChange={handleChange}
                  InputLabelProps={{ shrink: true }}
                />
              </Grid>
            </Section>

            <Section title="Access Permissions">
              <Box display="flex" gap={2} flexWrap="wrap">
                <Chip label={`Smartphone: ${form.smartphone_allowed ? 'Yes' : 'No'}`} onClick={() => toggleBool('smartphone_allowed')} />
                <Chip label={`Laptop: ${form.laptop_allowed ? 'Yes' : 'No'}`} onClick={() => toggleBool('laptop_allowed')} />
                <Chip label={`Ops Area: ${form.ops_area_permitted ? 'Yes' : 'No'}`} onClick={() => toggleBool('ops_area_permitted')} />
                <Chip label={`Can Register Labours: ${form.can_register_labours ? 'Yes' : 'No'}`} onClick={() => toggleBool('can_register_labours')} />
              </Box>

              {form.smartphone_allowed && (
                <Grid container spacing={2} mt={1}>
                  <Field
                    type="date"
                    label="Smartphone Expiry"
                    name="smartphone_expiry"
                    value={form.smartphone_expiry}
                    onChange={handleChange}
                    InputLabelProps={{ shrink: true }}
                  />
                </Grid>
              )}

              {form.laptop_allowed && (
                <Grid container spacing={2} mt={1}>
                  <Field label="Laptop Make" name="laptop_make" value={form.laptop_make} onChange={handleChange} />
                  <Field label="Laptop Model" name="laptop_model" value={form.laptop_model} onChange={handleChange} />
                  <Field label="Laptop Serial" name="laptop_serial" value={form.laptop_serial} onChange={handleChange} />
                  <Field
                    type="date"
                    label="Laptop Expiry"
                    name="laptop_expiry"
                    value={form.laptop_expiry}
                    onChange={handleChange}
                    InputLabelProps={{ shrink: true }}
                  />
                </Grid>
              )}
            </Section>

            <Section title="Validity">
              <Grid container spacing={2}>
                <Field type="date" label="Valid From" name="valid_from" value={form.valid_from} onChange={handleChange} InputLabelProps={{ shrink: true }} />
                <Field type="date" label="Valid To" name="valid_to" value={form.valid_to} onChange={handleChange} InputLabelProps={{ shrink: true }} />
              </Grid>
            </Section>
          </Box>
        )}

        {activeStep === 1 && (
          <Box>
            <Typography variant="h6" gutterBottom>Upload Photo</Typography>
            <Divider sx={{ mb: 2 }} />
            <Button variant="contained" component="label" sx={{ mb: 2 }}>
              Select Photo
              <input hidden type="file" accept="image/*" onChange={(e) => setPhotoFile(e.target.files?.[0] || null)} />
            </Button>
            {photoFile && (
              <Typography variant="body2" sx={{ mb: 2 }}>Selected: {photoFile.name}</Typography>
            )}
            {visitor?.enrollment_photo_path && (
              <Box>
                <Typography variant="body2" sx={{ mb: 1 }}>Current Photo:</Typography>
                <img
                  src={`${fileBase}/${visitor.enrollment_photo_path}`}
                  alt="Visitor"
                  style={{ maxWidth: 240, borderRadius: 8 }}
                />
              </Box>
            )}
          </Box>
        )}

        {activeStep === 2 && (
          <Box>
            <Typography variant="h6" gutterBottom>Documents</Typography>
            <Divider sx={{ mb: 2 }} />
            <Grid container spacing={2}>
              <Grid item xs={12} md={4}>
                <TextField
                  select
                  fullWidth
                  label="Document Type"
                  value={docType}
                  onChange={(e) => setDocType(e.target.value)}
                >
                  {DOC_TYPES.map((t) => (
                    <MenuItem key={t} value={t}>{t}</MenuItem>
                  ))}
                </TextField>
              </Grid>
              <Grid item xs={12} md={4}>
                <TextField
                  fullWidth
                  label="Document Number"
                  value={docNumber}
                  onChange={(e) => setDocNumber(e.target.value)}
                />
              </Grid>
              <Grid item xs={12} md={4}>
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
                  Select File
                  <input hidden type="file" onChange={(e) => setDocFile(e.target.files?.[0] || null)} />
                </Button>
                {docFile && (
                  <Typography variant="body2" sx={{ mt: 1 }}>Selected: {docFile.name}</Typography>
                )}
              </Grid>
            </Grid>

            <Divider sx={{ my: 3 }} />
            <Typography variant="subtitle1" gutterBottom>Uploaded Documents</Typography>
            {documents.length === 0 ? (
              <Typography color="text.secondary">No documents uploaded.</Typography>
            ) : (
              <Box display="flex" gap={1} flexWrap="wrap">
                {documents.map((d) => (
                  <Chip key={d.id} label={`${d.doc_type} - ${d.doc_number || 'N/A'}`} />
                ))}
              </Box>
            )}
          </Box>
        )}

        {activeStep === 3 && (
          <Box>
            <Typography variant="h6" gutterBottom>RFID Card</Typography>
            <Divider sx={{ mb: 2 }} />
            {visitor?.card_uid ? (
              <Alert severity="success" sx={{ mb: 2 }}>
                RFID issued: {visitor.card_uid}
              </Alert>
            ) : (
              <Alert severity="warning" sx={{ mb: 2 }}>
                No active RFID card
              </Alert>
            )}
            <Grid container spacing={2}>
              <Grid item xs={12} md={6}>
                <TextField
                  type="date"
                  fullWidth
                  label="Issue Date"
                  value={issueDate}
                  onChange={(e) => setIssueDate(e.target.value)}
                  InputLabelProps={{ shrink: true }}
                />
              </Grid>
              <Grid item xs={12} md={6}>
                <TextField
                  type="date"
                  fullWidth
                  label="Expiry Date"
                  value={rfidExpiry}
                  onChange={(e) => setRfidExpiry(e.target.value)}
                  InputLabelProps={{ shrink: true }}
                />
              </Grid>
            </Grid>
          </Box>
        )}

        {activeStep === 4 && (
          <Box>
            <Typography variant="h6" gutterBottom>Biometric</Typography>
            <Divider sx={{ mb: 2 }} />
            {biometric ? (
              <Alert severity="success" sx={{ mb: 2 }}>
                Enrolled ({biometric.algorithm})
              </Alert>
            ) : (
              <Alert severity="warning" sx={{ mb: 2 }}>
                Not enrolled
              </Alert>
            )}
            <TextField
              fullWidth
              label="Biometric Data"
              multiline
              minRows={3}
              value={biometricData}
              onChange={(e) => setBiometricData(e.target.value)}
              placeholder="Paste fingerprint template / device output"
            />
          </Box>
        )}

        {activeStep === 5 && (
          <Box>
            <Typography variant="h6" gutterBottom>Registration Complete</Typography>
            <Divider sx={{ mb: 2 }} />
            <Typography>Visitor registered successfully.</Typography>
            {visitorId && (
              <Button sx={{ mt: 2 }} variant="contained" onClick={() => navigate(`/visitors/${visitorId}`)}>
                View Visitor Profile
              </Button>
            )}
          </Box>
        )}

        <Divider sx={{ my: 3 }} />
        <Box display="flex" justifyContent="space-between">
          <Button onClick={handleBack} disabled={activeStep === 0}>Back</Button>
          <Box display="flex" gap={1}>
            {activeStep < steps.length - 1 && (
              <Button variant="contained" onClick={handleNext} disabled={loading}>
                {loading ? 'Saving...' : 'Next'}
              </Button>
            )}
            {activeStep === steps.length - 1 && (
              <Button variant="outlined" onClick={() => navigate('/visitors')}>Done</Button>
            )}
          </Box>
        </Box>
      </Paper>
    </Box>
  )
}

function Section({ title, children }) {
  return (
    <>
      <Typography variant="h6" gutterBottom>{title}</Typography>
      <Divider sx={{ mb: 2 }} />
      {children}
      <Divider sx={{ my: 3 }} />
    </>
  )
}

function Field(props) {
  return (
    <Grid item xs={12} sm={6}>
      <TextField fullWidth variant="outlined" {...props} />
    </Grid>
  )
}

function AccessDenied({ title, message, onBack }) {
  return (
    <Paper sx={{ p: 3, maxWidth: 720, mx: 'auto' }}>
      <Alert severity="warning" sx={{ mb: 2 }}>
        <Typography fontWeight={700}>{title}</Typography>
        <Typography variant="body2">{message}</Typography>
      </Alert>
      <Box display="flex" justifyContent="flex-end">
        <Button variant="contained" onClick={onBack}>
          Back to Visitors
        </Button>
      </Box>
    </Paper>
  )
}
