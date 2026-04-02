import React, { useEffect, useRef, useState, useMemo, useCallback } from 'react';
import {
  Box,
  Typography,
  Paper,
  Grid,
  Stack,
  Button,
  Chip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  MenuItem,
  TextField,
  CircularProgress,
} from '@mui/material';
import { styled } from '@mui/material/styles';
import { io } from 'socket.io-client';
import api from '../api/axios';
import { getMasters } from '../api/master.api';
import EventPopup from '../components/andon/EventPopup';

const STAFF_CODE = import.meta.env.VITE_GATE_SETUP_CODE || 'VMMS-STAFF';

const palette = {
  navy: '#0b1d2e',
  deep: '#050b14',
  gold: '#d4af37',
  teal: '#22d3ee',
  panel: '#0f172a',
};

const KeyButton = styled(Button)(({ theme }) => ({
  minHeight: 64,
  fontSize: '1.1rem',
  fontWeight: 800,
  letterSpacing: 0.5,
  borderRadius: 14,
  borderColor: 'rgba(255,255,255,0.14)',
  background: 'linear-gradient(135deg, rgba(255,255,255,0.04), rgba(255,255,255,0.08))',
  color: '#e2e8f0',
  '&:hover': {
    background: 'linear-gradient(135deg, rgba(255,255,255,0.10), rgba(255,255,255,0.18))',
  },
  '&.MuiButton-containedSuccess': {
    background: 'linear-gradient(135deg,#16a34a,#22c55e)',
    color: '#04120a',
  },
  '&:active': {
    transform: 'scale(0.97)',
  },
}));

const StatusBox = styled(Box)(({ tone }) => ({
  padding: '24px',
  textAlign: 'center',
  minHeight: 110,
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
  borderRadius: 12,
  background: `linear-gradient(120deg, ${tone}, rgba(255,255,255,0.04))`,
  boxShadow: '0 18px 42px rgba(0,0,0,0.45)',
}));

const Card = styled(Paper)(() => ({
  background: 'linear-gradient(180deg, rgba(255,255,255,0.03), rgba(0,0,0,0.28))',
  border: '1px solid rgba(255,255,255,0.08)',
  borderRadius: 18,
  boxShadow: '0 20px 48px rgba(0,0,0,0.45)',
}));

export default function TouchGateUltimate() {
  const [gates, setGates] = useState([]);
  const [gateId, setGateId] = useState(null);
  const [uid, setUid] = useState('');
  const [status, setStatus] = useState('READY'); // READY | PROCESSING | SUCCESS | ERROR
  const [eventCard, setEventCard] = useState(null);
  const [message, setMessage] = useState('');
  const [openGateDialog, setOpenGateDialog] = useState(false);
  const [eventQueue, setEventQueue] = useState([]);
  const [activeEvent, setActiveEvent] = useState(null);
  const [lastEventTime, setLastEventTime] = useState(null);
  const [socketConnected, setSocketConnected] = useState(false);

  const videoRef = useRef(null);
  const canvasRef = useRef(null);
  const streamRef = useRef(null);
  const socketRef = useRef(null);
  const seenEvents = useRef(new Map()); // id -> lastSeenTs
  const shownEvents = useRef(new Map()); // id -> lastShownTs
  const pendingTimerRef = useRef(null);

  /* ---------------- INIT ---------------- */
  useEffect(() => {
    loadGates();
    initCamera();
    setLastEventTime(new Date().toISOString());

    return () => stopCamera();
  }, []);

  const lastEventTimeRef = useRef(null);
  useEffect(() => {
    lastEventTimeRef.current = lastEventTime;
  }, [lastEventTime]);

  const eventKey = useCallback((evt) => {
    if (!evt) return null;
    return (
      evt.access_log_id ||
      evt.event_id ||
      evt.id ||
      evt.pass_no ||
      evt.card_uid ||
      evt.token_uid ||
      null
    );
  }, []);

  const isEventReady = useCallback((evt) => {
    if (!evt) return false;
    return Boolean(
      evt.full_name &&
        evt.pass_no &&
        evt.scan_time &&
        evt.person_type &&
        evt.direction
    );
  }, []);

  const mergeEvent = useCallback((oldEvt, newEvt) => {
    if (!oldEvt) return newEvt;
    if (!newEvt) return oldEvt;
    const merged = { ...oldEvt, ...newEvt };
    // Prefer newer scan_time if present
    if (newEvt.scan_time) merged.scan_time = newEvt.scan_time;
    return merged;
  }, []);

  const preparingPopup = eventQueue.length > 0 && !activeEvent;

  const upsertEvent = useCallback(
    (evt) => {
      const key = eventKey(evt);
      if (!key) return;

      // If currently showing the same event, just merge/update without requeue
      setActiveEvent((prev) => {
        if (prev && eventKey(prev) === key) {
          return mergeEvent(prev, evt);
        }
        return prev;
      });

      // If already shown before and not active, ignore to prevent repeat popups
      const shownTs = shownEvents.current.get(key);
      if (shownTs && Date.now() - shownTs < 10 * 60 * 1000) return;

      setEventQueue((prev) => {
        const filtered = prev.filter((e) => eventKey(e) !== key);
        const merged = mergeEvent(filtered.find((e) => eventKey(e) === key), evt);
        return [...filtered, merged];
      });
    },
    [eventKey, mergeEvent]
  );

  const loadGates = async () => {
    const res = await getMasters();
    const g = res.data?.data?.gates || [];
    setGates(g);
    setGateId(g[0]?.id ?? g[0]?.gate_id ?? null);
  };

  const fileBase =
    import.meta.env.VITE_FILE_BASE_URL ||
    (import.meta.env.VITE_API_BASE_URL
      ? import.meta.env.VITE_API_BASE_URL.replace(/\/api\/?$/, '')
      : window.location.origin);

  const resolvePhoto = (path) => {
    if (!path) return null;
    if (path.startsWith('data:')) return path;
    if (path.startsWith('http')) return path;
    return `${fileBase}/${path}`;
  };

  /* ---------------- CAMERA ---------------- */
  const isMobileOrTablet = () =>
    /Mobi|Android|iPhone|iPad|iPod/i.test(navigator.userAgent || '') ||
    (window.innerWidth && window.innerWidth < 900);

  const initCamera = async () => {
    try {
      const facingMode = isMobileOrTablet() ? { ideal: 'environment' } : { ideal: 'user' };
      const stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode, width: { ideal: 1280 }, height: { ideal: 720 } },
      });
      if (videoRef.current) {
        videoRef.current.srcObject = stream;
        videoRef.current.onloadedmetadata = () => {
          videoRef.current?.play().catch(() => {});
        };
      }
      streamRef.current = stream;
    } catch (err) {
      setMessage('Camera unavailable');
    }
  };

  const stopCamera = () => {
    streamRef.current?.getTracks().forEach((t) => t.stop());
  };

  /* ---------------- SOCKET & EVENTS ---------------- */
  const EVENT_POPUP_DURATION = 10000;

  useEffect(() => {
    const enabled =
      import.meta.env.VITE_ENABLE_SOCKET === 'true' || Boolean(import.meta.env.VITE_SOCKET_URL);
    if (!enabled || socketRef.current) return;

    const baseUrl =
      import.meta.env.VITE_SOCKET_URL ||
      (import.meta.env.VITE_API_BASE_URL
        ? import.meta.env.VITE_API_BASE_URL.replace(/\/api\/?$/, '')
        : window.location.origin);

    const socket = io(baseUrl, { transports: ['websocket', 'polling'], reconnection: true });
    socket.on('connect', () => setSocketConnected(true));
    socket.on('disconnect', () => setSocketConnected(false));

    socket.on('ANDON_EVENT', (event) => {
      const accepted = acceptEvent(event, lastEventTimeRef.current, seenEvents, gateId);
      if (!accepted) return;
      if (event.scan_time) {
        setLastEventTime(event.scan_time);
      }
      upsertEvent(event);
    });

    socketRef.current = socket;
    return () => socket.disconnect();
  }, [gateId, upsertEvent]);

  // Fallback polling if sockets not connected
  useEffect(() => {
    if (socketConnected) return;
    const timer = setInterval(async () => {
      if (!lastEventTimeRef.current) return;
      try {
        const { data } = await api.get(
          `/public/andon/events?since=${encodeURIComponent(lastEventTimeRef.current)}`
        );
        const events = data?.events || [];
        const accepted = events.filter((evt) =>
          acceptEvent(evt, lastEventTimeRef.current, seenEvents, gateId)
        );
        if (!accepted.length) return;
        const latest = accepted[accepted.length - 1]?.scan_time;
        if (latest) setLastEventTime(latest);
        accepted.forEach((evt) => upsertEvent(evt));
      } catch (err) {
        console.error('Events poll error', err);
      }
    }, 8000);
    return () => clearInterval(timer);
  }, [socketConnected, gateId, upsertEvent]);

  // Event queue processing
  useEffect(() => {
    if (activeEvent || eventQueue.length === 0) return;
    if (pendingTimerRef.current) clearTimeout(pendingTimerRef.current);
    const [next, ...rest] = eventQueue;
    pendingTimerRef.current = setTimeout(() => {
      setActiveEvent(next);
      setEventQueue(rest);
      const key = eventKey(next);
      if (key) {
        shownEvents.current.set(key, Date.now());
        purgeSeenMap(shownEvents.current, 15 * 60 * 1000);
      }
      pendingTimerRef.current = null;
    }, 500); // delay to allow backend to enrich event payload
  }, [eventQueue, activeEvent, eventKey]);

  useEffect(() => () => {
    if (pendingTimerRef.current) clearTimeout(pendingTimerRef.current);
  }, []);

  useEffect(() => {
    if (!activeEvent) return;
    const timer = setTimeout(() => setActiveEvent(null), EVENT_POPUP_DURATION);
    return () => clearTimeout(timer);
  }, [activeEvent]);

  const capturePhoto = () => {
    const canvas = canvasRef.current;
    const video = videoRef.current;
    if (!canvas || !video) return null;
    if (!video.videoWidth || !video.videoHeight) return null;
    const ctx = canvas.getContext('2d');
    canvas.width = 480;
    canvas.height = 360;
    ctx.drawImage(video, 0, 0, 480, 360);
    return canvas.toDataURL('image/jpeg', 0.85);
  };

  /* ---------------- AUTH ---------------- */
  const handleSubmit = async () => {
    if (!uid) return;

    let photo = capturePhoto();
    if (!photo) {
      await new Promise((r) => setTimeout(r, 150));
      photo = capturePhoto();
    }

    setStatus('PROCESSING');
    setMessage('Verifying credentials...');

    try {
      const v = await api.post('/gate/authenticate', { card_uid: uid, gate_id: gateId, photo });
      if ((v.data.status || '').toUpperCase() === 'SUCCESS') {
        const evt = buildEventCard(v.data, 'VISITOR', photo);
        setEventCard(evt);
        upsertEvent(evt);
        setStatus('SUCCESS');
        setMessage(`ACCESS GRANTED - ${v.data.full_name || 'Visitor'}`);
        reset();
        return;
      }

      const l = await api.post('/gate/authenticate-labour', { token_uid: uid, gate_id: gateId, photo });
      if ((l.data.status || '').toUpperCase() === 'SUCCESS') {
        const evt = buildEventCard(l.data, 'LABOUR', photo);
        setEventCard(evt);
        upsertEvent(evt);
        setStatus('SUCCESS');
        setMessage(`ACCESS GRANTED - ${l.data.name || 'Labour'}`);
        reset();
        return;
      }

      throw new Error();
    } catch (err) {
      setStatus('ERROR');
      setMessage('ACCESS DENIED');
      setEventCard(null);
      reset();
    } finally {
      setUid('');
    }
  };

  const reset = () => {
    setTimeout(() => {
      setStatus('READY');
      setMessage('');
    }, 5500);
  };

  /* ---------------- KEYPAD ---------------- */
  const keyRows = useMemo(
    () => [
      ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
      ['CLEAR', 'DEL'],
    ],
    []
  );

  const pressKey = (k) => {
    if (k === 'DEL') return setUid((p) => p.slice(0, -1));
    if (k === 'CLEAR') return setUid('');
    if (k === 'OK') return handleSubmit();
    setUid((p) => (p + k).slice(0, 20));
  };

  /* ---------------- GATE ---------------- */
  const requestGateChange = () => {
    const code = prompt('Enter staff code');
    if (code === STAFF_CODE) setOpenGateDialog(true);
    else if (code) alert('Invalid code');
  };

  const statusTone = () => {
    if (status === 'SUCCESS') return 'linear-gradient(135deg,#16a34a,#22c55e)';
    if (status === 'ERROR') return 'linear-gradient(135deg,#ef4444,#f97316)';
    if (status === 'PROCESSING') return 'linear-gradient(135deg,#2563eb,#22d3ee)';
    return 'linear-gradient(135deg,#1f2937,#0b1d2e)';
  };

  const buildEventCard = (data, type, livePhoto) => {
    const now = new Date();
    return {
      person_type: type,
      direction: data.direction || 'IN',
      gate_id: data.gate_id || data.id || data.gateId || gateId,
      gate_name: data.gate_name || gateLabel,
      full_name: data.full_name || data.name || 'NA',
      company_name: data.company_name || '-',
      department_name: data.department_name || '-',
      project_name: data.project_name || '-',
      designation: data.designation || data.role || '',
      pass_no: data.pass_no || data.token_uid || data.card_uid || uid,
      pass_valid_from: data.valid_from,
      pass_valid_to: data.valid_to || data.valid_until,
      permissions: data.permissions,
      enrollment_photo_path: data.photo_url || data.enrollment_photo_path,
      live_photo_path: livePhoto,
      scan_time: now.toISOString(),
      phone: data.phone,
      supervisor_name: data.supervisor_name,
    };
  };

  const gateLabel = gates.find((g) => g.id === gateId || g.gate_id === gateId)?.gate_name || gateId || 'Select';

  /* ---------------- UI ---------------- */
  return (
    <Box
      sx={{
        minHeight: '100vh',
        height: '100vh',
        minWidth: 360,
        width: '100%',
        display: 'flex',
        flexDirection: 'column',
        background: `
          radial-gradient(1100px 600px at 10% 0%, rgba(27,64,115,0.25), transparent 55%),
          radial-gradient(900px 480px at 90% 10%, rgba(212,175,55,0.18), transparent 50%),
          linear-gradient(180deg, ${palette.navy} 0%, ${palette.deep} 100%)
        `,
        color: '#fff',
        overflowX: 'hidden',
      }}
    >
      {/* Hidden capture elements (camera not shown on UI) */}
      <video ref={videoRef} autoPlay playsInline muted style={{ display: 'none' }} />
      <canvas ref={canvasRef} style={{ display: 'none' }} />

      {/* Branded hero bar */}
      <Box
        sx={{
          px: { xs: 1.5, md: 3 },
          py: 2,
          borderBottom: '1px solid rgba(255,255,255,0.08)',
          background: 'linear-gradient(90deg, rgba(11,29,46,0.9), rgba(8,20,35,0.9))',
        }}
      >
        <Box
          sx={{
            maxWidth: 1400,
            mx: 'auto',
            display: 'flex',
            flexWrap: 'wrap',
            alignItems: 'center',
            gap: 2,
            justifyContent: 'space-between',
          }}
        >
          <Stack direction="row" spacing={2} alignItems="center">
            <Box component="img" src="/logos/indian_navy.png" alt="Indian Navy" sx={{ height: 44 }} />
            <Box>
              <Typography sx={{ color: '#9fb3d9', letterSpacing: 1, fontSize: 12 }}>
                NAVAL AIRFIELD VISITOR MANAGEMENT SYSTEM
              </Typography>
              <Typography sx={{ fontWeight: 800, fontSize: { xs: 18, md: 22 }, letterSpacing: 1 }}>
                Touch Gate Pro
              </Typography>
              <Typography sx={{ color: '#9fb3d9', fontSize: 12, letterSpacing: 0.8 }}>
                INS RAJALI - INDIAN NAVY
              </Typography>
            </Box>
          </Stack>

          <Stack direction="row" spacing={1.5} alignItems="center">
            <Chip
              label={`Gate ${gateLabel}`}
              onClick={requestGateChange}
              sx={{
                fontSize: 14,
                py: 1,
                px: 1.5,
                background: 'linear-gradient(135deg,#d4af37,#f8d568)',
                color: '#0b1d2e',
                fontWeight: 800,
                cursor: 'pointer',
              }}
            />
            <Chip label={status} variant="outlined" sx={{ color: '#e2e8f0', borderColor: '#334155' }} />
          </Stack>
        </Box>
      </Box>

      {/* Status banner */}
      <Box sx={{ width: '100%', maxWidth: 1400, mx: 'auto', px: { xs: 1.5, md: 3 }, pt: 1.5 }}>
        <StatusBox tone={statusTone()}>
          <Stack
            spacing={0.6}
            sx={{ width: '100%', alignItems: 'center', px: { xs: 1, md: 4 }, textAlign: 'center' }}
          >
            <Typography
              sx={{
                fontWeight: 900,
                letterSpacing: 1,
                fontSize: { xs: 24, sm: 30, md: 36 },
                textAlign: 'center',
              }}
            >
              {status === 'READY' && 'READY FOR INPUT'}
              {status === 'PROCESSING' && 'PROCESSING...'}
              {status === 'SUCCESS' && 'ACCESS GRANTED'}
              {status === 'ERROR' && 'ACCESS DENIED'}
            </Typography>
            <Typography variant="body1" sx={{ opacity: 0.85, textAlign: 'center' }}>
              {message || 'Align face, scan RFID or enter UID'}
            </Typography>
          </Stack>
        </StatusBox>
      </Box>

      {/* Main layout */}
      <Box
        sx={{
          px: { xs: 1.5, md: 3 },
          py: { xs: 1.5, md: 2.5 },
          maxWidth: '100vh',
          mx: 'auto',
        }}
      >
        <Grid container spacing={2} sx={{ alignItems: 'stretch' }}>
          <Grid item xs={12}>
            <Card sx={{ p: { xs: 2, md: 2.5 }, height: '100%', width: '100%' }}>
              <Stack direction="row" alignItems="center" justifyContent="space-between" mb={1.5}>
                <Typography variant="h6" fontWeight={800}>
                  Credential Input
                </Typography>
                <Chip label="Secure" size="small" color="success" variant="outlined" />
              </Stack>

              <Box
                sx={{
                  fontSize: { xs: 22, sm: 24, md: 30 },
                  fontWeight: 800,
                  letterSpacing: { xs: 1, md: 3 },
                  minHeight: 60,
                  width: '100%',
                  mb: 1.5,
                  color: uid ? '#67e8f9' : '#94a3b8',
                  textAlign: 'center',
                  borderBottom: '2px dashed #334155',
                  pb: 1,
                  wordBreak: 'break-word',
                }}
              >
                {uid || '------'}
              </Box>

              <Stack spacing={1}>
                {keyRows.map((row, idx) => (
                  <Stack key={idx} direction="row" spacing={1} justifyContent="center" flexWrap="wrap">
                    {row.map((k) => (
                      <KeyButton
                        key={k}
                        sx={{
                          minWidth: { xs: k.length > 3 ? 96 : 52, sm: 62 },
                          flex:
                            k === 'OK'
                              ? { xs: '1 0 120px', sm: '1 0 140px' }
                              : { xs: '1 0 64px', sm: '0 0 auto' },
                          fontSize: { xs: 14, sm: 16 },
                          background:
                            k === 'OK'
                              ? 'linear-gradient(135deg,#16a34a,#22c55e)'
                              : undefined,
                          color: k === 'OK' ? '#04120a' : undefined,
                        }}
                        variant={k === 'OK' ? 'contained' : 'outlined'}
                        color={k === 'OK' ? 'success' : 'inherit'}
                        onClick={() => pressKey(k)}
                      >
                        {k}
                      </KeyButton>
                    ))}
                  </Stack>
                ))}
              </Stack>

              <Button
                variant="contained"
                fullWidth
                sx={{
                  mt: 2,
                  py: 1.2,
                  fontWeight: 800,
                  letterSpacing: 0.5,
                  background: 'linear-gradient(135deg,#2563eb,#22d3ee)',
                }}
                onClick={handleSubmit}
              >
                Verify & Capture
              </Button>

              <Stack spacing={1} mt={2} direction={{ xs: 'column', sm: 'row' }}>
                <StatusBox tone="linear-gradient(135deg,#1f2937,#0b1d2e)" sx={{ p: 2, minHeight: 'auto', flex: 1 }}>
                  <Stack spacing={0.4} alignItems="center">
                    <Typography sx={{ fontWeight: 700, fontSize: 14 }}>Quick Tips</Typography>
                    <Typography sx={{ fontSize: 12, opacity: 0.7, textAlign: 'center' }}>
                      Tap numbers/letters or scan RFID. Use OK to submit, DEL to correct.
                    </Typography>
                  </Stack>
                </StatusBox>
              </Stack>
            </Card>
          </Grid>
        </Grid>
      </Box>

      {/* Inline prep indicator while waiting to show popup */}
      {preparingPopup && (
        <Box
          sx={{
            position: 'fixed',
            bottom: { xs: 12, md: 20 },
            right: { xs: 12, md: 24 },
            zIndex: 1400,
            display: 'flex',
            alignItems: 'center',
            gap: 1,
            background: 'rgba(15,23,42,0.9)',
            border: '1px solid rgba(148,163,184,0.3)',
            borderRadius: 12,
            px: 1.5,
            py: 1,
            boxShadow: '0 12px 32px rgba(0,0,0,0.45)',
          }}
        >
          <CircularProgress size={18} thickness={4} color="info" />
          <Typography sx={{ fontWeight: 700, fontSize: 13, color: '#e2e8f0' }}>
            Preparing access record...
          </Typography>
        </Box>
      )}

      {/* Popup overlay for live event */}
      <EventPopup event={activeEvent} resolvePhoto={resolvePhoto} />

      {/* Gate selection dialog */}
      <Dialog open={openGateDialog} onClose={() => setOpenGateDialog(false)} maxWidth="sm" fullWidth>
        <DialogTitle>Select Active Gate</DialogTitle>
        <DialogContent>
          <TextField
            select
            fullWidth
            label="Gate"
            value={gateId || ''}
            onChange={(e) => setGateId(e.target.value)}
            margin="dense"
          >
            {gates.map((g) => (
              <MenuItem key={g.id || g.gate_id} value={g.id || g.gate_id}>
                {g.gate_name || `Gate ${g.id || g.gate_id}`}
              </MenuItem>
            ))}
          </TextField>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenGateDialog(false)}>Close</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}

/* ---------------- HELPERS ---------------- */
function acceptEvent(event, lastEventTime, seenEvents, gateId) {
  if (!event) return false;

  // gate filter
  const evGateId = Number(event.gate_id || event.gateId || event.gateid);
  const selGateId = Number(gateId);
  if (selGateId && evGateId && evGateId !== selGateId) return false;

  const id = event.access_log_id || event.event_id || event.id || event.pass_no || event.card_uid || event.token_uid;
  if (!id) return false; // ignore events without a strict unique ID

  const eventTsRaw = event.scan_time ? new Date(event.scan_time).getTime() : Date.now();
  const eventTs = Number.isNaN(eventTsRaw) ? Date.now() : eventTsRaw;
  const lastSeen = seenEvents.current.get(id);

  // time-window dedupe (default 5s)
  if (lastSeen && eventTs - lastSeen < 5000) return false;

  // ensure monotonic by scan_time if available
  if (event.scan_time && lastEventTime) {
    const lastTs = new Date(lastEventTime).getTime();
    if (!Number.isNaN(eventTs) && !Number.isNaN(lastTs) && eventTs <= lastTs) {
      return false;
    }
  }

  seenEvents.current.set(id, eventTs || Date.now());
  purgeSeenMap(seenEvents.current, 10 * 60 * 1000); // 10 min TTL to avoid leak
  return true;
}

function purgeSeenMap(map, ttlMs) {
  const cutoff = Date.now() - ttlMs;
  for (const [key, ts] of map.entries()) {
    if (ts < cutoff) map.delete(key);
  }
}
