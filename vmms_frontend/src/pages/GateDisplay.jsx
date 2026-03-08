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
} from '@mui/material'
import Grid from '@mui/material/Grid'
import CameraAltIcon from '@mui/icons-material/CameraAlt'
import api from '../api/axios'

export default function GateDisplay() {
  const [gateId] = useState(1)
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

  /* ---------------- CAMERA ---------------- */
  useEffect(() => {
    initCamera()
    inputRef.current?.focus()
    return () => stopCamera()
  }, [])

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
      if (v.data?.status === 'SUCCESS') {
        const normalized = normalizeVisitor(v.data, uid)
        displayAccess(normalized, photo)
        setRfidInput('')
        return
      }

      const l = await api.post('/gate/authenticate-labour', {
        token_uid: uid,
        gate_id: gateId,
        photo,
      })
      if (l.data?.status === 'SUCCESS') {
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

  /* ---------------- RENDER ---------------- */
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
          {successMessage || errorMessage || 'Tap RFID card or enter UID'}
        </Typography>
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
                GATE {gateId}
              </Typography>
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
                    sx={{ bgcolor: '#f8fafc', borderRadius: 1 }}
                  />
                  <Button variant="contained" type="submit" disabled={loading}>
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
