import React, { useState, useRef, useEffect } from 'react'
import {
  Alert,
  Box,
  Button,
  CircularProgress,
  Paper,
  Stack,
  TextField,
  Typography,
  Chip,
  Divider,
  FormControl,
  InputLabel,
  MenuItem,
  Select,
} from '@mui/material'
import Grid from '@mui/material/Grid'
import CameraAltIcon from '@mui/icons-material/CameraAlt'
import api from '../api/axios'
import { getMasters } from '../api/master.api'

const LOCAL_GATE_KEY = 'gateDisplay.selectedGateId'
const STAFF_CODE = import.meta.env.VITE_GATE_SETUP_CODE || 'VMMS-STAFF'

export default function GateDisplay() {
  const [gates, setGates] = useState([])
  const [gateId, setGateId] = useState(null)
  const [gatesLoading, setGatesLoading] = useState(false)
  const [selectingGate, setSelectingGate] = useState(true)
  const [rfidInput, setRfidInput] = useState('')
  const [loading, setLoading] = useState(false)
  const [errorMessage, setErrorMessage] = useState('')
  const [successMessage, setSuccessMessage] = useState('')
  const [currentAccess, setCurrentAccess] = useState(null)
  const [registeredPhoto, setRegisteredPhoto] = useState(null)
  const [livePhoto, setLivePhoto] = useState(null)
  const [cameraReady, setCameraReady] = useState(false)

  const videoRef = useRef(null)
  const canvasRef = useRef(null)
  const streamRef = useRef(null)
  const inputRef = useRef(null)

  /* ---------------- CAMERA & GATE INIT ---------------- */
  useEffect(() => {
    loadGates()
  }, [])

  useEffect(() => {
    if (selectingGate || !gateId) return undefined
    initCamera()
    inputRef.current?.focus()
    return () => stopCamera()
  }, [selectingGate, gateId])

  useEffect(() => {
    if (!gateId) return
    localStorage.setItem(LOCAL_GATE_KEY, String(gateId))
  }, [gateId])

  const initCamera = async () => {
    try {
      if (!navigator?.mediaDevices?.getUserMedia) {
        setCameraReady(false)
        setErrorMessage('Camera unavailable in this browser or context')
        return
      }
      const stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: 'user', width: { ideal: 1280 }, height: { ideal: 720 } },
      })
      videoRef.current.srcObject = stream
      streamRef.current = stream
      setCameraReady(true)
    } catch (err) {
      console.error(err)
      setCameraReady(false)
      setErrorMessage('Camera access required')
    }
  }

  const stopCamera = () => {
    streamRef.current?.getTracks().forEach(t => t.stop())
  }

  /* ---------------- GATE MASTER & LOGS ---------------- */
  const loadGates = async () => {
    setGatesLoading(true)
    try {
      const res = await getMasters()
      const masterGates = res.data?.data?.gates || []
      setGates(masterGates)

      const savedId = Number(localStorage.getItem(LOCAL_GATE_KEY))
      const fallbackId = masterGates[0]?.id || masterGates[0]?.gate_id || null
      const defaultGate =
        masterGates.find((g) => g.id === savedId || g.gate_id === savedId) || null
      const defaultId = defaultGate?.id ?? defaultGate?.gate_id ?? fallbackId
      setGateId(defaultId)
      setSelectingGate(!defaultId)
    } catch (err) {
      console.error('Failed to load gates', err)
      setErrorMessage(err?.response?.data?.error || 'Unable to load gates')
    } finally {
      setGatesLoading(false)
    }
  }

  const capturePhoto = () => {
    if (!videoRef.current || !canvasRef.current) return null
    const canvas = canvasRef.current
    const ctx = canvas.getContext('2d')
    canvas.width = 640
    canvas.height = 480
    ctx.drawImage(videoRef.current, 0, 0, 640, 480)
    return canvas.toDataURL('image/jpeg', 0.7)
  }

  /* ---------------- HELPERS ---------------- */
  const resetDisplay = () => {
    setTimeout(() => {
      setCurrentAccess(null)
      setLivePhoto(null)
      setRegisteredPhoto(null)
      setSuccessMessage('')
      setErrorMessage('')
      inputRef.current?.focus()
    }, 7000)
  }

  const displayError = (msg) => {
    setCurrentAccess(null)
    setSuccessMessage('')
    setErrorMessage(msg || 'Access Denied')
    resetDisplay()
  }

  const gateNameById = (id) => {
    const g = gates.find(
      (x) => Number(x.id) === Number(id) || Number(x.gate_id) === Number(id)
    )
    return g?.gate_name || g?.name || `Gate ${id}`
  }

  const renderGateGuidance = (allowed = []) => {
    if (!allowed?.length) return ''
    const names = allowed.map((id) => gateNameById(id)).join(', ')
    return `Please proceed to: ${names}`
  }

  const handleGateChange = (newGateId) => {
    const normalized = Number(newGateId) || null
    setGateId(normalized)
    setCurrentAccess(null)
    setLivePhoto(null)
    setRegisteredPhoto(null)
    setSuccessMessage('')
    setErrorMessage('')
  }

  const confirmGateSelection = () => {
    if (!gateId) {
      setErrorMessage('Select a gate to start')
      return
    }
    setSelectingGate(false)
    setSuccessMessage('')
    setErrorMessage('')
    localStorage.setItem(LOCAL_GATE_KEY, String(gateId))
  }

  const requestGateChange = () => {
    const input = window.prompt('Staff only: enter gate setup code')
    if (input === null) return
    if (input === STAFF_CODE) {
      setSelectingGate(true)
    } else {
      alert('Invalid code')
    }
  }

  const displayAccess = (data, photo) => {
    setCurrentAccess(data)
    setLivePhoto(photo)
    setRegisteredPhoto(data.photo_url || data.enrollment_photo_url || null)
    const greet = data.direction === 'IN' ? 'Welcome' : 'Thank you'
    setSuccessMessage(`${greet}, ${data.full_name}`)
    setErrorMessage('')
    resetDisplay()
  }

  const normalizeVisitor = (res, uid) => ({
    person_type: 'VISITOR',
    direction: res.direction,
    full_name: res.name || 'Visitor',
    aadhaar_last4: res.aadhaar || '-',
    project_name: res.project_name || '-',
    department_name: res.department_name || '-',
    company_name: res.company_name || '-',
    visitor_type_name: res.visitor_type_name || '-',
    host_name: res.host_name || '-',
    smartphone_allowed: res.smartphone_allowed,
    laptop_allowed: res.laptop_allowed,
    ops_area_permitted: res.ops_area_permitted,
    can_register_labours: res.can_register_labours,
    valid_from: res.valid_from,
    valid_to: res.valid_to,
    photo_url: res.enrollment_photo_path || res.photo_url,
    rfid_uid: uid,
    visitor_id: res.visitor_id || res.id || null,
  })

  const normalizeLabour = (res, uid) => ({
    person_type: 'LABOUR',
    direction: res.direction,
    full_name: res.name || 'Labour',
    supervisor_name: res.supervisor_name || '-',
    valid_until: res.valid_until,
    photo_url: res.photo_url,
    rfid_uid: uid,
    labour_id: res.labour_id || res.id || null,
  })

  /* ---------------- RFID HANDLER ---------------- */
  const handleScan = async (e) => {
    e.preventDefault()
    const uid = rfidInput.trim()
    if (!uid) return
    if (!gateId || selectingGate) {
      setErrorMessage('Select a gate (staff) to start scanning')
      return
    }

    setLoading(true)
    setErrorMessage('')
    setSuccessMessage('')

    try {
      const photo = capturePhoto()
      const v = await api.post('/gate/authenticate', {
        card_uid: uid,
        gate_id: gateId,
        photo,
      })
      if ((v.data?.status || '').toUpperCase() === 'SUCCESS') {
        const normalized = normalizeVisitor(v.data, uid)
        displayAccess(normalized, photo)
        setRfidInput('')
        return
      }

      if (v.data?.error_code === 'E105') {
        const guidance = renderGateGuidance(v.data?.allowed_gates)
        displayError(
          guidance
            ? `Access denied at this gate. ${guidance}`
            : 'Access denied: gate not permitted for this visitor'
        )
        setRfidInput('')
        return
      }

      const l = await api.post('/gate/authenticate-labour', {
        token_uid: uid,
        gate_id: gateId,
        photo,
      })
      if ((l.data?.status || '').toUpperCase() === 'SUCCESS') {
        const normalized = normalizeLabour(l.data, uid)
        displayAccess(normalized, photo)
        setRfidInput('')
        return
      }

      displayError(`RFID ${uid} not authorized`)
    } catch (err) {
      displayError(err?.response?.data?.error || 'Verification Failed')
    } finally {
      setLoading(false)
    }
  }

  /* ---------------- UI COLOR LOGIC ---------------- */
  const getBannerColor = () => {
    if (errorMessage) return '#f59e0b'
    if (!currentAccess) return '#1f2937'
    return currentAccess.direction === 'IN' ? '#16a34a' : '#dc2626'
  }

  const fileBase =
    import.meta.env.VITE_FILE_BASE_URL ||
    (import.meta.env.VITE_API_BASE_URL
      ? import.meta.env.VITE_API_BASE_URL.replace(/\/api\/?$/, '')
      : 'http://localhost:5000')

  const resolvePhoto = (p) => {
    if (!p) return null
    if (p.startsWith('http://') || p.startsWith('https://')) return p
    return `${fileBase}/${p}`
  }

  const currentGate = gates.find((g) => g.id === gateId || g.gate_id === gateId)

  const formatDateTime = (value) => {
    if (!value) return '-'
    const d = new Date(value)
    if (Number.isNaN(d.getTime())) return '-'
    return d.toLocaleString()
  }

  /* ---------------- RENDER ---------------- */
  const renderGateSelector = () => (
    <Box
      sx={{
        minHeight: '100vh',
        color: '#0f172a',
        background:
          'radial-gradient(1200px 600px at 10% 0%, rgba(16,185,129,0.12), transparent 60%), radial-gradient(900px 500px at 90% 0%, rgba(244,114,182,0.12), transparent 55%), linear-gradient(180deg, #f8fafc 0%, #eef2f7 60%, #e5e7eb 100%)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        px: 2,
      }}
    >
      <Paper sx={{ p: 4, maxWidth: 480, width: '100%', borderRadius: 3, boxShadow: '0 18px 48px rgba(15,23,42,0.18)' }}>
        <Typography variant="h5" fontWeight={800} gutterBottom>
          Staff: Select Gate
        </Typography>
        <Typography color="text.secondary" sx={{ mb: 2 }}>
          Choose the active gate to start the display. Visitors cannot change this setting.
        </Typography>
        <FormControl fullWidth>
          <InputLabel>Select Gate</InputLabel>
          <Select
            label="Select Gate"
            value={gateId || ''}
            onChange={(e) => handleGateChange(e.target.value)}
            disabled={gatesLoading || gates.length === 0}
          >
            {gates.map((g) => {
              const value = g.id ?? g.gate_id
              return (
                <MenuItem key={value} value={value}>
                  {g.gate_name} {g.ip_address ? `• ${g.ip_address}` : ''}
                </MenuItem>
              )
            })}
          </Select>
        </FormControl>
        <Stack direction="row" spacing={2} sx={{ mt: 3 }} justifyContent="flex-end">
          <Button variant="contained" onClick={confirmGateSelection} disabled={!gateId}>
            Start Display
          </Button>
        </Stack>
      </Paper>
    </Box>
  )

  if (selectingGate || !gateId) {
    return renderGateSelector()
  }

  return (
    <Box
      sx={{
        minHeight: '100vh',
        color: '#0f172a',
        background:
          'radial-gradient(1200px 600px at 10% 0%, rgba(16,185,129,0.12), transparent 60%), radial-gradient(900px 500px at 90% 0%, rgba(244,114,182,0.12), transparent 55%), linear-gradient(180deg, #f8fafc 0%, #eef2f7 60%, #e5e7eb 100%)',
      }}
    >
      {/* HIDDEN VIDEO STREAM FOR CAPTURE ONLY */}
      <video ref={videoRef} autoPlay playsInline style={{ display: 'none' }} />

      {/* STATUS BANNER */}
      <Box
        sx={{
          background: errorMessage
            ? 'linear-gradient(90deg, #f59e0b 0%, #f97316 100%)'
            : currentAccess
            ? currentAccess.direction === 'IN'
              ? 'linear-gradient(90deg, #10b981 0%, #22c55e 100%)'
              : 'linear-gradient(90deg, #ef4444 0%, #f97316 100%)'
            : 'linear-gradient(90deg, #0f172a 0%, #1f2937 100%)',
          textAlign: 'center',
          color: '#ffffff',
          py: { xs: 2, md: 2.5 },
          transition: 'all 0.3s ease',
          boxShadow: '0 12px 30px rgba(15,23,42,0.2)',
        }}
      >
        <Typography variant="h4" fontWeight={800} letterSpacing={1}>
          {errorMessage
            ? 'ACCESS DENIED'
            : currentAccess
            ? currentAccess.direction === 'IN'
              ? 'ENTRY AUTHORIZED'
              : 'EXIT AUTHORIZED'
            : 'READY FOR RFID'}
        </Typography>
        <Typography variant="body1" sx={{ opacity: 0.95 }}>
          {successMessage ||
            errorMessage ||
            (currentGate ? `Tap RFID card or enter UID at ${currentGate.gate_name}` : 'Select a gate to begin')}
        </Typography>
        <Box sx={{ mt: 1, display: 'flex', justifyContent: 'center', gap: 1 }}>
          {currentGate && (
            <Chip
              label={`Gate: ${currentGate.gate_name}`}
              color="info"
              variant="outlined"
              size="small"
            />
          )}
            <Button variant="text" size="small" color="inherit" onClick={requestGateChange} sx={{ opacity: 0.8, textDecoration: 'underline' }}>
              Change gate (staff)
            </Button>
        </Box>
      </Box>

      <Box sx={{ px: { xs: 2, md: 3 }, py: { xs: 2, md: 3 } }}>
        <Grid container spacing={2} alignItems="stretch">
          {/* LEFT: INPUT + (INSTRUCTIONS ONLY BEFORE SCAN) */}
          <Grid size={{ xs: 12, md: 4, lg: 3 }}>
            <Paper
              sx={{
                p: 3,
                bgcolor: '#ffffff',
                borderRadius: 3,
                border: '1px solid rgba(15,23,42,0.08)',
                boxShadow: '0 16px 40px rgba(15,23,42,0.08)',
                height: '100%',
              }}
            >
              <Typography variant="overline" sx={{ color: '#0ea5e9', fontWeight: 700, letterSpacing: 2 }}>
                Gate Console
              </Typography>

              {currentGate ? (
                <Stack direction="row" spacing={1} sx={{ flexWrap: 'wrap', mb: 2 }}>
                  <Chip label={currentGate.gate_name} color="primary" />
                  <Chip label={currentGate.ip_address || 'No IP'} />
                  <Chip label={currentGate.device_serial || 'No Device'} />
                  <Chip
                    label={currentGate.is_active ? 'Active' : 'Inactive'}
                    color={currentGate.is_active ? 'success' : 'default'}
                  />
                </Stack>
              ) : (
                <Alert severity="info" sx={{ mb: 2 }}>
                  {gatesLoading ? 'Loading gates…' : 'No gates found. Please add a gate in Admin > Gates.'}
                </Alert>
              )}
              {!currentAccess && (
                <>
                  <Typography variant="h5" fontWeight={800} gutterBottom>
                    Visitor Instructions
                  </Typography>
                  <Stack spacing={1.2} sx={{ mb: 2, color: '#0f172a' }}>
                    <Typography>Stand on the floor marker facing the camera.</Typography>
                    <Typography>Keep your face clear. Remove helmet or mask.</Typography>
                    <Typography>Look straight and hold still during capture.</Typography>
                    <Typography>Tap RFID card or enter UID below.</Typography>
                  </Stack>
                  <Divider sx={{ my: 2, borderColor: 'rgba(15,23,42,0.12)' }} />
                </>
              )}

              <Box component="form" onSubmit={handleScan}>
                <Stack spacing={2}>
                  <TextField
                    inputRef={inputRef}
                    label="RFID / Token UID"
                    variant="outlined"
                    value={rfidInput}
                    onChange={(e) => setRfidInput(e.target.value)}
                    fullWidth
                    autoFocus
                    disabled={selectingGate}
                    sx={{ bgcolor: '#f8fafc', borderRadius: 1 }}
                  />
                  <Button variant="contained" type="submit" disabled={loading || selectingGate || !gateId}>
                    {loading ? <CircularProgress size={22} /> : 'Verify Access'}
                  </Button>
                  <Chip
                    label={cameraReady ? 'Camera Ready' : 'Camera Off'}
                    color={cameraReady ? 'success' : 'error'}
                  />
                </Stack>
              </Box>
            </Paper>
          </Grid>

          {/* CENTER: PHOTOS + STATUS */}
          <Grid size={{ xs: 12, md: 5, lg: 6 }}>
            <Paper
              sx={{
                p: 3,
                bgcolor: '#ffffff',
                borderRadius: 3,
                border: '1px solid rgba(15,23,42,0.08)',
                boxShadow: '0 16px 40px rgba(15,23,42,0.08)',
                height: '100%',
              }}
            >
              {!currentAccess ? (
                <Stack spacing={2} alignItems="center" sx={{ mt: 6, color: '#0f172a' }}>
                  <CameraAltIcon sx={{ fontSize: 54, opacity: 0.5 }} />
                  <Typography variant="h5" fontWeight={700}>Waiting for RFID / Token</Typography>
                  <Typography color="text.secondary">
                    Capture will happen automatically on success.
                  </Typography>
                </Stack>
              ) : (
                <Stack spacing={2}>
                  <Box display="flex" justifyContent="space-between" alignItems="center">
                    <Box>
                      <Typography variant="h4" fontWeight={800}>
                        {currentAccess.full_name}
                      </Typography>
                      <Typography color="text.secondary">
                        {currentAccess.person_type} ? {currentAccess.direction === 'IN' ? 'Entry' : 'Exit'}
                      </Typography>
                    </Box>
                    <Chip label={currentAccess.person_type} color="info" />
                  </Box>

                  <Box display="flex" gap={2}>
                    <Box sx={{ flex: 1 }}>
                      <Typography variant="caption">Registered Photo</Typography>
                      <Box
                        component="img"
                        src={resolvePhoto(registeredPhoto)}
                        alt="Registered"
                        sx={{
                          width: '100%',
                          height: 160,
                          objectFit: 'cover',
                          borderRadius: 2,
                          bgcolor: '#f1f5f9',
                          border: '1px solid rgba(15,23,42,0.08)',
                        }}
                      />
                    </Box>
                    <Box sx={{ flex: 1 }}>
                      <Typography variant="caption">Captured Photo</Typography>
                      <Box
                        component="img"
                        src={livePhoto || ''}
                        alt="Captured"
                        sx={{
                          width: '100%',
                          height: 160,
                          objectFit: 'cover',
                          borderRadius: 2,
                          bgcolor: '#f1f5f9',
                          border: '1px solid rgba(15,23,42,0.08)',
                        }}
                      />
                    </Box>
                  </Box>
                </Stack>
              )}
            </Paper>
          </Grid>

          {/* RIGHT: DETAILS STRIP */}
          <Grid size={{ xs: 12, md: 3, lg: 3 }}>
            <Paper
              sx={{
                p: 3,
                bgcolor: '#0f172a',
                color: '#e2e8f0',
                borderRadius: 3,
                border: '1px solid rgba(15,23,42,0.15)',
                boxShadow: '0 16px 40px rgba(15,23,42,0.15)',
                height: '100%',
              }}
            >
              <Typography variant="h6" fontWeight={700} gutterBottom>
                Details
              </Typography>
              {!currentAccess ? (
                <Typography color="rgba(226,232,240,0.7)">
                  No visitor data yet.
                </Typography>
              ) : currentAccess.person_type === 'LABOUR' ? (
                <Stack spacing={1}>
                  <Typography>Supervisor: {currentAccess.supervisor_name}</Typography>
                  <Typography>Valid Until: {currentAccess.valid_until ? new Date(currentAccess.valid_until).toLocaleString() : '-'}</Typography>
                  <Typography>Token UID: {currentAccess.rfid_uid}</Typography>
                </Stack>
              ) : (
                <Stack spacing={1}>
                  <Typography>Aadhaar (Last 4): {currentAccess.aadhaar_last4}</Typography>
                  <Typography>Project: {currentAccess.project_name}</Typography>
                  <Typography>Department: {currentAccess.department_name}</Typography>
                  <Typography>Company: {currentAccess.company_name}</Typography>
                  <Typography>Visitor Type: {currentAccess.visitor_type_name}</Typography>
                  <Typography>Host: {currentAccess.host_name}</Typography>
                  <Typography>Mobile Allowed: {currentAccess.smartphone_allowed ? 'YES' : 'NO'}</Typography>
                  <Typography>Laptop Allowed: {currentAccess.laptop_allowed ? 'YES' : 'NO'}</Typography>
                  <Typography>Ops Area: {currentAccess.ops_area_permitted ? 'YES' : 'NO'}</Typography>
                  <Typography>Labour Register: {currentAccess.can_register_labours ? 'YES' : 'NO'}</Typography>
                  <Typography>Valid From: {currentAccess.valid_from ? new Date(currentAccess.valid_from).toLocaleDateString() : '-'}</Typography>
                  <Typography>Valid To: {currentAccess.valid_to ? new Date(currentAccess.valid_to).toLocaleDateString() : '-'}</Typography>
                  <Typography>RFID UID: {currentAccess.rfid_uid}</Typography>
                </Stack>
              )}
            </Paper>
          </Grid>
        </Grid>

      </Box>
      {/* ALERTS */}
      <Box sx={{ position: 'fixed', bottom: 20, right: 20 }}>
        {errorMessage && <Alert severity="error">{errorMessage}</Alert>}
        {successMessage && <Alert severity="success">{successMessage}</Alert>}
      </Box>

      <canvas ref={canvasRef} style={{ display: 'none' }} />
    </Box>
  )
}
