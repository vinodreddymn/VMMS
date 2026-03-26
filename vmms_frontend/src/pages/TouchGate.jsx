import React, { useEffect, useRef, useState, useCallback } from 'react';
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
  Alert,
} from '@mui/material';
import { styled } from '@mui/material/styles';
import api from '../api/axios';
import { getMasters } from '../api/master.api';

const STAFF_CODE = import.meta.env.VITE_GATE_SETUP_CODE || 'VMMS-STAFF';

// Styled components for better touch experience
const KeyButton = styled(Button)(({ theme }) => ({
  minHeight: 72,
  fontSize: '1.5rem',
  fontWeight: 'bold',
  borderRadius: 12,
  '&:active': {
    transform: 'scale(0.95)',
    backgroundColor: theme.palette.primary.dark,
  },
}));

const StatusBox = styled(Box)(({ statuscolor }) => ({
  padding: '24px',
  textAlign: 'center',
  backgroundColor: statuscolor,
  transition: 'all 0.4s ease',
  minHeight: 120,
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
}));

export default function TouchGatePro() {
  const [gates, setGates] = useState([]);
  const [gateId, setGateId] = useState(null);
  const [uid, setUid] = useState('');
  const [status, setStatus] = useState('READY'); // READY | SUCCESS | ERROR | LOADING
  const [message, setMessage] = useState('');
  const [person, setPerson] = useState(null);
  const [openGateDialog, setOpenGateDialog] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const videoRef = useRef(null);
  const canvasRef = useRef(null);
  const streamRef = useRef(null);

  /* ---------------- INIT ---------------- */
  useEffect(() => {
    loadGates();
    initCamera();

    return () => {
      stopCamera();
    };
  }, []);

  const loadGates = async () => {
    try {
      const res = await getMasters();
      const g = res.data?.data?.gates || [];
      setGates(g);
      if (g.length > 0) {
        setGateId(g[0].id ?? g[0].gate_id ?? null);
      }
    } catch (err) {
      console.error('Failed to load gates', err);
    }
  };

  /* ---------------- CAMERA ---------------- */
  const initCamera = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: 'user', width: { ideal: 1280 }, height: { ideal: 720 } },
      });
      if (videoRef.current) {
        videoRef.current.srcObject = stream;
      }
      streamRef.current = stream;
    } catch (err) {
      console.error('Camera access failed:', err);
      setMessage('Camera not available');
    }
  };

  const stopCamera = () => {
    streamRef.current?.getTracks().forEach((track) => track.stop());
    streamRef.current = null;
  };

  const capturePhoto = useCallback(() => {
    const canvas = canvasRef.current;
    const video = videoRef.current;
    if (!canvas || !video) return null;

    const ctx = canvas.getContext('2d');
    canvas.width = 640;
    canvas.height = 480;
    ctx.drawImage(video, 0, 0, 640, 480);
    return canvas.toDataURL('image/jpeg', 0.85);
  }, []);

  /* ---------------- AUTH ---------------- */
  const handleSubmit = async () => {
    if (!uid || isLoading) return;

    setIsLoading(true);
    setStatus('LOADING');
    setMessage('Verifying...');

    const photo = capturePhoto();

    try {
      // Try Visitor first
      const visitorRes = await api.post('/gate/authenticate', {
        card_uid: uid,
        gate_id: gateId,
        photo,
      });

      if ((visitorRes.data.status || '').toUpperCase() === 'SUCCESS') {
        const data = visitorRes.data;
        setPerson({ ...data, type: 'VISITOR', livePhoto: photo });
        setStatus('SUCCESS');
        setMessage(`WELCOME ${data.full_name || 'Guest'}`);
        reset();
        return;
      }

      // Try Labour
      const labourRes = await api.post('/gate/authenticate-labour', {
        token_uid: uid,
        gate_id: gateId,
        photo,
      });

      if ((labourRes.data.status || '').toUpperCase() === 'SUCCESS') {
        const data = labourRes.data;
        setPerson({ ...data, type: 'LABOUR', livePhoto: photo });
        setStatus('SUCCESS');
        setMessage(`WELCOME ${data.name || 'Labour'}`);
        reset();
        return;
      }

      throw new Error('Access Denied');
    } catch (error) {
      console.error(error);
      setStatus('ERROR');
      setMessage('ACCESS DENIED');
      setPerson(null);
      reset();
    } finally {
      setIsLoading(false);
      setUid('');
    }
  };

  const reset = useCallback(() => {
    setTimeout(() => {
      setPerson(null);
      setStatus('READY');
      setMessage('');
      setUid('');
    }, 6500);
  }, []);

  /* ---------------- KEYPAD ---------------- */
  const keys = [
    ...'1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split(''),
    'DEL',
    'CLEAR',
    'OK',
  ];

  const pressKey = (k) => {
    if (k === 'DEL') {
      setUid((prev) => prev.slice(0, -1));
      return;
    }
    if (k === 'CLEAR') {
      setUid('');
      return;
    }
    if (k === 'OK') {
      handleSubmit();
      return;
    }
    setUid((prev) => (prev + k).slice(0, 20)); // limit length
  };

  /* ---------------- GATE CHANGE ---------------- */
  const requestGateChange = () => {
    const code = prompt('Enter staff code to change gate:');
    if (code === STAFF_CODE) {
      setOpenGateDialog(true);
    } else if (code) {
      alert('Invalid staff code');
    }
  };

  const getStatusColor = () => {
    if (status === 'SUCCESS') return '#16a34a';
    if (status === 'ERROR') return '#dc2626';
    if (status === 'LOADING') return '#ca8a04';
    return '#1e2937';
  };

  return (
    <Box
      sx={{
        minHeight: '100vh',
        background: 'linear-gradient(180deg, #020617 0%, #0f172a 100%)',
        color: '#fff',
        fontFamily: 'system-ui, sans-serif',
        touchAction: 'manipulation',
      }}
    >
      {/* Hidden elements */}
      <video
        ref={videoRef}
        autoPlay
        playsInline
        muted
        style={{ display: 'none' }}
      />
      <canvas ref={canvasRef} style={{ display: 'none' }} />

      {/* HEADER */}
      <Box
        sx={{
          p: 3,
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          borderBottom: '1px solid rgba(255,255,255,0.1)',
        }}
      >
        <Typography variant="h4" fontWeight="bold">
          Touch Gate Pro
        </Typography>
        <Chip
          label={`Gate ${gateId || '—'}`}
          onClick={requestGateChange}
          color="primary"
          sx={{ fontSize: '1.1rem', py: 2.5, px: 3, cursor: 'pointer' }}
        />
      </Box>

      {/* STATUS BAR */}
      <StatusBox statuscolor={getStatusColor()}>
        <Typography variant="h3" fontWeight="bold" sx={{ letterSpacing: 1 }}>
          {isLoading ? (
            <Stack direction="row" spacing={2} alignItems="center" justifyContent="center">
              <CircularProgress color="inherit" size={40} />
              {message}
            </Stack>
          ) : (
            message || 'READY FOR INPUT'
          )}
        </Typography>
      </StatusBox>

      <Grid container spacing={3} sx={{ p: 3 }}>
        {/* LEFT: UID + KEYPAD */}
        <Grid item xs={12} md={5}>
          <Paper
            sx={{
              p: 4,
              background: '#0f172a',
              border: '1px solid rgba(255,255,255,0.08)',
            }}
            elevation={6}
          >
            <Typography variant="h6" gutterBottom>
              Enter UID / Token
            </Typography>

            <Box
              sx={{
                fontSize: '2.8rem',
                fontWeight: 'bold',
                letterSpacing: 4,
                minHeight: 80,
                mb: 4,
                color: uid ? '#60a5fa' : '#64748b',
                textAlign: 'center',
                borderBottom: '3px solid #334155',
                py: 1,
              }}
            >
              {uid || '——————'}
            </Box>

            <Grid container spacing={1.5}>
              {keys.map((k, i) => (
                <Grid item xs={4} key={i}>
                  <KeyButton
                    fullWidth
                    variant={k === 'OK' ? 'contained' : 'outlined'}
                    color={k === 'OK' ? 'success' : 'inherit'}
                    onClick={() => pressKey(k)}
                    disabled={isLoading}
                  >
                    {k}
                  </KeyButton>
                </Grid>
              ))}
            </Grid>
          </Paper>
        </Grid>

        {/* CENTER: CAMERA + PHOTOS */}
        <Grid item xs={12} md={4}>
          <Paper
            sx={{
              p: 3,
              background: '#0f172a',
              border: '1px solid rgba(255,255,255,0.08)',
              height: '100%',
            }}
            elevation={6}
          >
            <Typography variant="h6" gutterBottom>
              Live Camera
            </Typography>
            <Box
              sx={{
                position: 'relative',
                borderRadius: 3,
                overflow: 'hidden',
                background: '#000',
                aspectRatio: '4 / 3',
                mb: 3,
              }}
            >
              <video
                ref={videoRef}
                autoPlay
                playsInline
                muted
                style={{
                  width: '100%',
                  height: '100%',
                  objectFit: 'cover',
                }}
              />
              <Box
                sx={{
                  position: 'absolute',
                  top: 12,
                  left: 12,
                  bgcolor: 'rgba(0,0,0,0.6)',
                  px: 2,
                  py: 0.5,
                  borderRadius: 1,
                  fontSize: '0.9rem',
                }}
              >
                Face the camera
              </Box>
            </Box>

            {person && (
              <>
                <Typography variant="subtitle2" sx={{ mt: 3, mb: 1 }}>
                  Registered Photo
                </Typography>
                <Box sx={{ mb: 3 }}>
                  <img
                    src={person.photo_url}
                    alt="Registered"
                    style={{
                      width: '100%',
                      borderRadius: 12,
                      border: '2px solid #334155',
                    }}
                    onError={(e) => {
                      e.target.src = 'https://via.placeholder.com/400x300?text=No+Photo';
                    }}
                  />
                </Box>

                <Typography variant="subtitle2" sx={{ mb: 1 }}>
                  Live Capture
                </Typography>
                <img
                  src={person.livePhoto}
                  alt="Live"
                  style={{
                    width: '100%',
                    borderRadius: 12,
                    border: '2px solid #22c55e',
                  }}
                />
              </>
            )}
          </Paper>
        </Grid>

        {/* RIGHT: PERSON DETAILS */}
        <Grid item xs={12} md={3}>
          <Paper
            sx={{
              p: 4,
              background: '#0f172a',
              border: '1px solid rgba(255,255,255,0.08)',
              height: '100%',
            }}
            elevation={6}
          >
            <Typography variant="h6" gutterBottom>
              Details
            </Typography>

            {person ? (
              <Stack spacing={2.5}>
                <Box>
                  <Typography variant="caption" color="text.secondary">
                    NAME
                  </Typography>
                  <Typography variant="h6">
                    {person.full_name || person.name || '—'}
                  </Typography>
                </Box>

                <Box>
                  <Typography variant="caption" color="text.secondary">
                    TYPE
                  </Typography>
                  <Chip
                    label={person.type}
                    color={person.type === 'VISITOR' ? 'info' : 'warning'}
                    sx={{ fontSize: '1rem' }}
                  />
                </Box>

                <Box>
                  <Typography variant="caption" color="text.secondary">
                    COMPANY
                  </Typography>
                  <Typography>{person.company_name || '—'}</Typography>
                </Box>

                {person.supervisor_name && (
                  <Box>
                    <Typography variant="caption" color="text.secondary">
                      SUPERVISOR
                    </Typography>
                    <Typography>{person.supervisor_name}</Typography>
                  </Box>
                )}
              </Stack>
            ) : (
              <Box sx={{ textAlign: 'center', py: 8, color: '#64748b' }}>
                <Typography variant="body1">Scan / Enter UID to begin</Typography>
              </Box>
            )}
          </Paper>
        </Grid>
      </Grid>

      {/* GATE SELECTION DIALOG */}
      <Dialog
        open={openGateDialog}
        onClose={() => setOpenGateDialog(false)}
        maxWidth="sm"
        fullWidth
      >
        <DialogTitle>Select Active Gate</DialogTitle>
        <DialogContent>
          <TextField
            select
            fullWidth
            label="Gate"
            value={gateId || ''}
            onChange={(e) => setGateId(e.target.value)}
            margin="dense"
            variant="outlined"
          >
            {gates.map((g) => (
              <MenuItem key={g.id || g.gate_id} value={g.id || g.gate_id}>
                {g.gate_name || `Gate ${g.id || g.gate_id}`}
              </MenuItem>
            ))}
          </TextField>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenGateDialog(false)} variant="outlined">
            Close
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}