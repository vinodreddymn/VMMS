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
import AndonHeader from '../components/andon/AndonHeader'
import GateMediaPlayer from "../components/GateMediaPlayer"

const LOCAL_GATE_KEY = 'gateDisplay.selectedGateId'
const STAFF_CODE = import.meta.env.VITE_GATE_SETUP_CODE || 'VMMS-STAFF'

export default function GateDisplay() {
  const [now, setNow] = useState(new Date())
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

  /* ---------------- CLOCK ---------------- */
  useEffect(() => {
    const t = setInterval(() => setNow(new Date()), 1000)
    return () => clearInterval(t)
  }, [])

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

  const DetailRow = ({ label, value }) => (
    <Box display="flex" justifyContent="space-between">
      <Typography sx={{ color: "rgba(226,232,240,0.7)", fontSize: 13 }}>
        {label}
      </Typography>
      <Typography fontWeight={600}>{value || "-"}</Typography>
    </Box>
  );

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

  const headerDate = now.toLocaleDateString('en-IN', {
    weekday: 'short',
    day: '2-digit',
    month: 'long',
    year: 'numeric'
  })

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
    <Box sx={styles.root}>
      {/* HIDDEN VIDEO STREAM FOR CAPTURE ONLY */}
      <video ref={videoRef} autoPlay playsInline style={{ display: 'none' }} />

      
      <AndonHeader now={now} headerDate={headerDate} />
      

      {/* STATUS BANNER */}

      <Box
        sx={{
          ...styles.banner,
          px: 5,
          py: 0,
          borderRadius: 2,
          display: "grid",
          gridTemplateColumns: "1fr auto 1fr",
          alignItems: "center",
          background: errorMessage
            ? "linear-gradient(90deg,#ef4444,#f97316)"
            : currentAccess
            ? currentAccess.direction === "IN"
              ? "linear-gradient(90deg,#10b981,#22c55e)"
              : "linear-gradient(90deg,#f97316,#ef4444)"
            : "linear-gradient(90deg,#0f172a,#1f2937)",
          boxShadow: "0 8px 25px rgba(0,0,0,0.25)"
        }}
      >
        {/* LEFT : STATUS MESSAGE */}
        <Stack spacing={0.5}>
          <Typography
            sx={{
              fontSize: 34,
              fontWeight: 900,
              letterSpacing: 2,
              lineHeight: 1,
              color: "#ffffff"
            }}
          >
            {errorMessage
              ? "ACCESS DENIED"
              : currentAccess
              ? currentAccess.direction === "IN"
                ? "ENTRY AUTHORIZED"
                : "EXIT AUTHORIZED"
              : "READY FOR RFID"}
          </Typography>

          <Typography
            sx={{
              fontSize: 16,
              opacity: 0.9,
              color: "#f1f5f9",
              fontWeight: 500
            }}
          >
            {successMessage ||
              errorMessage ||
              (currentGate
                ? `Scan RFID card or enter UID`
                : "System ready for access verification")}
          </Typography>
        </Stack>

        {/* CENTER : GATE NAME */}
        <Box
          sx={{
            display: "flex",
            justifyContent: "center",
            alignItems: "center"
          }}
        >
          {currentGate && (
            <Typography
              sx={{
                fontSize: 32,
                fontWeight: 900,
                color: "#ffffff",
                letterSpacing: 2,
                px: 3,
                py: 1,
                borderRadius: 2,
                background: "rgba(255,255,255,0.12)",
                border: "1px solid rgba(255,255,255,0.25)",
                backdropFilter: "blur(6px)"
              }}
            >
              {currentGate.gate_name}
            </Typography>
          )}
        </Box>

        {/* RIGHT : ACTION */}
        <Box sx={{ display: "flex", justifyContent: "flex-end" }}>
          <Button
            variant="text"
            size="small"
            color="inherit"
            onClick={requestGateChange}
            sx={{
              textDecoration: "underline",
              fontWeight: 600,
              fontSize: 14
            }}
          >
            Change Gate
          </Button>
        </Box>
      </Box>

      <Box sx={{ px: { xs: 2, md: 3 }, py: { xs: 2, md: 3 } }}>
        <Grid container spacing={2} alignItems="stretch">
          {/* LEFT: INPUT + INSTRUCTIONS */}
          <Grid size={{ xs: 12, md: 4, lg: 2 }}>
            <Paper
              sx={{
                ...styles.cardLight,
                p: 3,
                borderRadius: 3,
                border: "1px solid rgba(15,23,42,0.08)",
                boxShadow: "0 10px 30px rgba(0,0,0,0.06)",
                height: "100%"
              }}
            >
              {/* INSTRUCTION HEADER */}
              {!currentAccess && (
                <>
                  <Typography
                    variant="overline"
                    sx={{
                      color: "#0ea5e9",
                      fontWeight: 700,
                      letterSpacing: 2,
                      display: "block",
                      mb: 1
                    }}
                  >
                    VISITOR INSTRUCTIONS
                  </Typography>

                  <Typography variant="h5" fontWeight={800} gutterBottom>
                    Access Verification
                  </Typography>

                  {/* INSTRUCTION LIST */}
                  <Stack
                    spacing={1.3}
                    sx={{
                      mb: 3,
                      p: 2,
                      borderRadius: 2,
                      bgcolor: "#f8fafc",
                      border: "1px solid #e2e8f0"
                    }}
                  >
                    <Typography>1. Stand on the floor marker.</Typography>
                    <Typography>2. Face the camera directly.</Typography>
                    <Typography>3. Remove helmet, mask, or glasses.</Typography>
                    <Typography>4. Keep still during photo capture.</Typography>
                    <Typography>5. Tap RFID card or enter UID below.</Typography>
                  </Stack>

                  <Divider sx={{ mb: 3 }} />
                </>
              )}

              {/* INPUT FORM */}
              <Box component="form" onSubmit={handleScan}>
                <Stack spacing={2.2}>

                  {/* RFID INPUT */}
                  <TextField
                    inputRef={inputRef}
                    label="RFID / Token UID"
                    variant="outlined"
                    value={rfidInput}
                    onChange={(e) => setRfidInput(e.target.value)}
                    fullWidth
                    autoFocus
                    disabled={selectingGate}
                    sx={{
                      bgcolor: "#f8fafc",
                      borderRadius: 1,
                      "& .MuiOutlinedInput-root": {
                        fontSize: 16,
                        fontWeight: 600
                      }
                    }}
                  />

                  {/* VERIFY BUTTON */}
                  <Button
                    variant="contained"
                    size="large"
                    type="submit"
                    disabled={loading || selectingGate || !gateId}
                    sx={{
                      py: 1.4,
                      fontWeight: 700,
                      fontSize: 16,
                      borderRadius: 2
                    }}
                  >
                    {loading ? <CircularProgress size={22} /> : "Verify Access"}
                  </Button>

                  {/* CAMERA STATUS */}
                  <Chip
                    label={cameraReady ? "Camera Ready" : "Camera Not Available"}
                    color={cameraReady ? "success" : "error"}
                    sx={{
                      fontWeight: 600,
                      justifyContent: "center"
                    }}
                  />
                </Stack>
              </Box>
            </Paper>
          </Grid>

          {/* CENTER: PHOTOS + STATUS */}
          {/* CENTER: MEDIA / VERIFICATION */}
          <Grid size={{ xs: 12, md: 5, lg: 6 }}>
            <Paper
              sx={{
                ...styles.cardLight,
                p: 3,
                height: "100%",
                borderRadius: 3,
                border: "1px solid rgba(15,23,42,0.08)",
                boxShadow: "0 10px 30px rgba(0,0,0,0.06)",
                overflow: "hidden"
              }}
            >

            {/* IDLE STATE → PLAY MEDIA */}
            {!currentAccess && (
              <GateMediaPlayer idle />
            )}

            {/* VERIFICATION STATE */}
            {currentAccess && (
              <Stack spacing={3}>

                {/* PERSON HEADER */}
                <Box display="flex" justifyContent="space-between" alignItems="center">
                  <Box>
                    <Typography variant="h4" fontWeight={800}>
                      {currentAccess.full_name}
                    </Typography>

                    <Typography color="text.secondary">
                      {currentAccess.person_type} • {currentAccess.direction === "IN" ? "Entry" : "Exit"}
                    </Typography>
                  </Box>

                  <Stack spacing={1}>
                    <Chip
                      label={currentAccess.person_type}
                      color="info"
                      sx={{ fontWeight: 600 }}
                    />

                    <Chip
                      label={currentAccess.direction === "IN" ? "ENTRY" : "EXIT"}
                      color={currentAccess.direction === "IN" ? "success" : "warning"}
                      sx={{ fontWeight: 700 }}
                    />
                  </Stack>
                </Box>

                <Divider />

                {/* PHOTO COMPARISON */}
                <Grid container spacing={2}>

                  <Grid size={6}>
                    <Stack spacing={1} alignItems="center">
                      <Typography variant="caption">REGISTERED PHOTO</Typography>

                      <Box
                        component="img"
                        src={resolvePhoto(registeredPhoto)}
                        sx={{
                          width: "100%",
                          maxWidth: 220,
                          height: 220,
                          objectFit: "cover",
                          borderRadius: 2
                        }}
                      />
                    </Stack>
                  </Grid>

                  <Grid size={6}>
                    <Stack spacing={1} alignItems="center">
                      <Typography variant="caption">LIVE CAPTURE</Typography>

                      <Box
                        component="img"
                        src={livePhoto || ""}
                        sx={{
                          width: "100%",
                          maxWidth: 220,
                          height: 220,
                          objectFit: "cover",
                          borderRadius: 2,
                          border: "2px solid #3b82f6"
                        }}
                      />
                    </Stack>
                  </Grid>

                </Grid>

              </Stack>
            )}

            </Paper>
          </Grid>

          {/* RIGHT: DETAILS STRIP */}
          <Grid size={{ xs: 12, md: 3, lg: 4 }}>
            <Paper
              sx={{
                ...styles.cardDark,
                p: 3,
                borderRadius: 3,
                border: "1px solid rgba(255,255,255,0.08)",
                height: "100%"
              }}
            >
              {/* HEADER */}
              <Typography
                variant="h6"
                fontWeight={800}
                sx={{ mb: 2, letterSpacing: 1 }}
              >
                ACCESS DETAILS
              </Typography>

              {!currentAccess ? (
                <Typography color="rgba(226,232,240,0.7)">
                  No visitor data yet.
                </Typography>
              ) : currentAccess.person_type === "LABOUR" ? (

                /* LABOUR DETAILS */
                <Stack spacing={1.5}>
                  <DetailRow label="Supervisor" value={currentAccess.supervisor_name} />
                  <DetailRow
                    label="Valid Until"
                    value={
                      currentAccess.valid_until
                        ? new Date(currentAccess.valid_until).toLocaleString()
                        : "-"
                    }
                  />
                  <DetailRow label="Token UID" value={currentAccess.rfid_uid} />
                </Stack>

              ) : (

                /* VISITOR DETAILS */
                <Stack spacing={1.4}>
                  <DetailRow label="Aadhaar (Last 4)" value={currentAccess.aadhaar_last4} />
                  <DetailRow label="Project" value={currentAccess.project_name} />
                  <DetailRow label="Department" value={currentAccess.department_name} />
                  <DetailRow label="Company" value={currentAccess.company_name} />
                  <DetailRow label="Visitor Type" value={currentAccess.visitor_type_name} />
                  <DetailRow label="Host" value={currentAccess.host_name} />

                  <Divider sx={{ borderColor: "rgba(255,255,255,0.1)", my: 1 }} />

                  {/* PERMISSIONS */}
                  <Stack direction="row" flexWrap="wrap" gap={1}>
                    <Chip
                      label={`Mobile: ${currentAccess.smartphone_allowed ? "YES" : "NO"}`}
                      color={currentAccess.smartphone_allowed ? "success" : "default"}
                      size="small"
                    />
                    <Chip
                      label={`Laptop: ${currentAccess.laptop_allowed ? "YES" : "NO"}`}
                      color={currentAccess.laptop_allowed ? "success" : "default"}
                      size="small"
                    />
                    <Chip
                      label={`Ops Area: ${currentAccess.ops_area_permitted ? "YES" : "NO"}`}
                      color={currentAccess.ops_area_permitted ? "success" : "default"}
                      size="small"
                    />
                    <Chip
                      label={`Labour Register: ${currentAccess.can_register_labours ? "YES" : "NO"}`}
                      color={currentAccess.can_register_labours ? "success" : "default"}
                      size="small"
                    />
                  </Stack>

                  <Divider sx={{ borderColor: "rgba(255,255,255,0.1)", my: 1 }} />

                  <DetailRow
                    label="Valid From"
                    value={
                      currentAccess.valid_from
                        ? new Date(currentAccess.valid_from).toLocaleDateString()
                        : "-"
                    }
                  />

                  <DetailRow
                    label="Valid To"
                    value={
                      currentAccess.valid_to
                        ? new Date(currentAccess.valid_to).toLocaleDateString()
                        : "-"
                    }
                  />

                  <DetailRow label="RFID UID" value={currentAccess.rfid_uid} />
                </Stack>
              )}
            </Paper>
          </Grid>
        </Grid>

      </Box>

      <Box
          sx={{
            ...styles.banner,
            px: 5,
            py: 0,
            borderRadius: 2,

            display: "grid",
            gridTemplateColumns: "1fr auto 1fr",
            alignItems: "center",

            position: "relative",
            overflow: "hidden",

            background: errorMessage
              ? "linear-gradient(90deg,#ef4444,#f97316)"
              : currentAccess
              ? currentAccess.direction === "IN"
                ? "linear-gradient(90deg,#10b981,#22c55e)"
                : "linear-gradient(90deg,#f97316,#ef4444)"
              : "linear-gradient(90deg,#0f172a,#1f2937)",

            boxShadow: "0 8px 25px rgba(0,0,0,0.25)",

            "@keyframes scrollText": {
              "0%": { transform: "translateX(100%)" },
              "100%": { transform: "translateX(-100%)" }
            }
          }}
        >

        {/* SCROLLING INSTRUCTIONS */}
        <Box
          sx={{
            position: "absolute",
            bottom: 4,
            left: 0,
            width: "100%",
            overflow: "hidden",
            whiteSpace: "nowrap"
          }}
        >
          <Typography
            sx={{
              display: "inline-block",
              color: "#f8fafc",
              fontWeight: 500,
              fontSize: 14,
              opacity: 0.9,
              animation: "scrollText 18s linear infinite"
            }}
          >
            Please scan your RFID card or enter UID • Ensure your face is visible to the camera • Follow gate security instructions • Contact security desk if access is denied
          </Typography>
        </Box>

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

/* ---------------- STYLES ---------------- */
const styles = {


  root: {
    height: '100vh',
    width: '100vw',
    overflow: 'hidden',
    color: '#0f172a',

    background:
      'radial-gradient(1200px 600px at 10% 0%, rgba(59,130,246,0.18), transparent 60%), radial-gradient(900px 520px at 90% 10%, rgba(16,185,129,0.16), transparent 55%), linear-gradient(180deg, #0a0f24 0%, #0b1c38 60%, #0b2448 100%)',

    padding: '10px 14px',
    display: 'flex',
    flexDirection: 'column',
  },




  banner: {
    height: '100px',
    borderRadius: 12,

    padding: '10px 18px',
    marginTop: '10px', 

    color: '#fff',

    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',

    background:
      'linear-gradient(135deg, rgba(30,41,59,0.95), rgba(15,23,42,0.95))',

    border: '1px solid rgba(255,255,255,0.08)',

    boxShadow: '0 8px 22px rgba(0,0,0,0.35)',
  },

  bannerTitle: {
    fontWeight: 800,
    fontSize: 22,
    letterSpacing: 1,
    textTransform: 'uppercase',
  },

  bannerSubtitle: {
    fontSize: 12,
    opacity: 0.85,
  },

  /* MAIN CONTENT AREA */

  content: {
    flex: 1,
    maxWidth: '1840px',
    margin: '10px auto 0 auto',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'space-between',
  },

  /* GRID ROW */

  gridRow: {
    height: 'calc(100vh - 120px)', // header + margins
    display: 'grid',
    gridTemplateColumns: '1.2fr 1fr 1fr',
    gap: '14px',
  },

  /* CARDS */

  cardLight: {
    padding: '16px',
    background: 'rgba(255,255,255,0.96)',
    borderRadius: 12,
    border: '1px solid rgba(15,23,42,0.08)',
    boxShadow: '0 10px 26px rgba(15,23,42,0.10)',
    height: '100%',
    overflow: 'hidden',
  },

  cardDark: {
    padding: '16px',
    background: 'rgba(12,18,40,0.92)',
    color: '#e2e8f0',
    borderRadius: 12,
    border: '1px solid rgba(148,163,184,0.18)',
    boxShadow: '0 10px 28px rgba(0,0,0,0.45)',
    height: '100%',
    overflow: 'hidden',
  },

  /* CAMERA PANEL */

  cameraPanel: {
    height: '100%',
    borderRadius: 10,
    overflow: 'hidden',
    background: '#000',
    border: '2px solid rgba(255,255,255,0.12)',
  },

  /* VISITOR PHOTO */

  visitorPhoto: {
    width: 130,
    height: 130,
    borderRadius: 10,
    objectFit: 'cover',
    border: '3px solid #22c55e',
  },

  /* STATUS BOX */

  statusBox: {
    padding: '12px',
    borderRadius: 10,
    fontSize: 16,
    fontWeight: 700,
    textAlign: 'center',
  },

  statusSuccess: {
    background: 'linear-gradient(135deg,#16a34a,#22c55e)',
    color: '#fff',
  },

  statusWarning: {
    background: 'linear-gradient(135deg,#f59e0b,#fbbf24)',
    color: '#000',
  },

  statusError: {
    background: 'linear-gradient(135deg,#dc2626,#ef4444)',
    color: '#fff',
  },

  /* ENTRY / EXIT INDICATOR */

  gateIndicator: {
    fontSize: 36,
    fontWeight: 900,
    letterSpacing: 2,
    textAlign: 'center',
    padding: '8px',
    borderRadius: 10,
    background:
      'linear-gradient(135deg, rgba(59,130,246,0.95), rgba(37,99,235,0.95))',
    color: '#fff',
  },

  /* FOOTER */

  footerBar: {
    height: '36px',
    marginTop: '6px',
    padding: '6px 14px',
    borderRadius: 8,
    background: 'rgba(15,23,42,0.85)',
    color: '#e2e8f0',
    fontSize: 12,
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    flexShrink: 0,
  },
}