import React, { useEffect, useMemo, useState } from 'react'
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Button,
  Box,
  Typography,
  Divider,
  Autocomplete,
  MenuItem,
} from '@mui/material'
import visitorApi from '../api/visitor.api'
import labourApi from '../api/labour.api'
import blacklistApi from '../api/blacklist.api'

export default function LabourEnrollmentDialog({ open, onClose, onSaved }) {
  const [step, setStep] = useState(1)
  const [supervisorId, setSupervisorId] = useState('')
  const [supervisor, setSupervisor] = useState(null)

  const [labours, setLabours] = useState([
    { full_name: '', phone: '', aadhaar: '', token_uid: '', gender: '', age: '', photo: null },
  ])

  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const [tokenQuery, setTokenQuery] = useState('')
  const [tokenOptions, setTokenOptions] = useState([])
  const [tokenLoading, setTokenLoading] = useState(false)

  const handlePhotoUpload = (index, file) => {
    const reader = new FileReader();

    reader.onloadend = () => {
      handleLabourChange(index, 'photo', reader.result);
    };

    if (file) reader.readAsDataURL(file);
  };

  const handleCapturePhoto = async (index) => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ video: true });

      const video = document.createElement('video');
      video.srcObject = stream;
      await video.play();

      const canvas = document.createElement('canvas');
      canvas.width = 200;
      canvas.height = 200;

      const ctx = canvas.getContext('2d');
      ctx.drawImage(video, 0, 0, 200, 200);

      const imageData = canvas.toDataURL('image/jpeg');

      handleLabourChange(index, 'photo', imageData);

      // stop camera
      stream.getTracks().forEach(track => track.stop());

    } catch (err) {
      console.error(err);
      alert("Camera access denied or not available");
    }
  };

  const duplicateTokens = useMemo(() => {
    const counts = {}
    for (const row of labours) {
      const token = String(row.token_uid || '').trim()
      if (!token) continue
      counts[token] = (counts[token] || 0) + 1
    }
    return new Set(Object.keys(counts).filter((t) => counts[t] > 1))
  }, [labours])

  // ===============================
  // Validate Supervisor
  // ===============================
  const validateSupervisor = async () => {
    if (!supervisorId) return

    setLoading(true)
    setError(null)

    try {
      const res = await visitorApi.getVisitor(supervisorId)
      const data = res?.data?.visitor

      const canRegister = Boolean(data?.can_register_labours) || Boolean(data?.allows_labour)
      if (!data || !canRegister || String(data.status).toUpperCase() !== 'ACTIVE') {
        throw new Error('Supervisor not authorized or inactive')
      }

      setSupervisor(data)
      setStep(2)
    } catch (err) {
      console.error(err)
      setError('Invalid Supervisor ID or not authorized')
      setSupervisor(null)
    } finally {
      setLoading(false)
    }
  }

  // ===============================
  // Labour Input Handling
  // ===============================
  const handleLabourChange = (index, field, value) => {
    const updated = [...labours]
    updated[index][field] = value
    setLabours(updated)
  }

  const addRow = () => {
    setLabours([...labours, { full_name: '', phone: '', aadhaar: '', token_uid: '', gender: '', age: '' }])
  }

  const removeRow = (index) => {
    const updated = labours.filter((_, i) => i !== index)
    setLabours(updated)
  }

  // ===============================
  // Submit Labours + Create Manifest
  // ===============================
  const handleSubmit = async () => {
    const validRows = labours.filter((l) => l.full_name || l.aadhaar || l.token_uid)
    if (!validRows.length) {
      setError('Please add at least one labour')
      return
    }

    // Field validations
    for (const [idx, row] of validRows.entries()) {
      if (!row.full_name?.trim()) {
        setError(`Row ${idx + 1}: Full name is required`)
        return
      }
      if (!row.aadhaar?.trim() || !/^\d{12}$/.test(row.aadhaar.trim())) {
        setError(`Row ${idx + 1}: Aadhaar must be 12 digits`)
        return
      }
      if (!row.token_uid?.trim()) {
        setError(`Row ${idx + 1}: RFID token is required`)
        return
      }
      if (row.phone && !/^\d{10,15}$/.test(String(row.phone).trim())) {
        setError(`Row ${idx + 1}: Phone must be 10-15 digits`)
        return
      }
      if (row.age && (Number(row.age) < 15 || Number(row.age) > 75)) {
        setError(`Row ${idx + 1}: Age must be between 15 and 75`)
        return
      }
    }

    const duplicateToken = (() => {
      const seen = new Set()
      for (const row of validRows) {
        const token = String(row.token_uid || '').trim()
        if (!token) continue
        if (seen.has(token)) return token
        seen.add(token)
      }
      return null
    })()

    if (duplicateToken) {
      setError(`Duplicate RFID token entered: ${duplicateToken}. Each labour must have a unique token.`)
      return
    }

    // blacklist check by Aadhaar / phone
    const blacklistHits = []
    try {
      // Backend expects single aadhaar or phone; check each row individually
      for (const row of validRows) {
        const payload = {}
        if (row.aadhaar) payload.aadhaar = row.aadhaar
        if (!payload.aadhaar && row.phone) payload.phone = row.phone
        if (!payload.aadhaar && !payload.phone) continue

        const res = await blacklistApi.checkBlacklist(payload)
        if (res?.data?.isBlacklisted) {
          const entry = res.data.entry || {}
          blacklistHits.push({
            row,
            payload,
            reason: entry.reason || 'N/A',
            block_type: entry.block_type || 'N/A',
          })
        }
      }
    } catch (err) {
      console.error('Blacklist check failed', err)
      setError('Could not verify blacklist. Please retry.')
      return
    }

    if (blacklistHits.length) {
      const first = blacklistHits[0]
      const msg =
        `Blacklisted entry detected. Registration aborted.\n` +
        `${first.payload.aadhaar ? `Aadhaar: ${first.payload.aadhaar}` : `Phone: ${first.payload.phone}`}\n` +
        `Reason: ${first.reason}\nType: ${first.block_type}`
      alert(msg)

      // Trigger backend flow once to ensure SMS is queued, then abort.
      try {
        await labourApi.createLabour({
          supervisor_id: supervisor.id,
          full_name: first.row.full_name || 'Blacklisted Labour',
          phone: first.payload.phone || '',
          aadhaar: first.payload.aadhaar || '',
          gender: first.row.gender || null,
          age: first.row.age ? Number(first.row.age) : null,
          token_uid: first.row.token_uid || 'BLK-PLACEHOLDER',
        })
      } catch {
        // Ignore; backend will have queued SMS if blacklist matched
      }
      return
    }

    const confirmed = window.confirm(
      `Confirm registration of ${validRows.length} labour(s) under supervisor ${supervisor?.full_name || supervisor?.id}?`
    )
    if (!confirmed) return

    try {
      setLoading(true)
      setError(null)
      const createdLabourIds = []

      for (const labour of validRows) {
        if (!labour.full_name || !labour.aadhaar || !labour.token_uid) {
          throw new Error('Name, Aadhaar, and RFID Token are required')
        }

        const res = await labourApi.createLabour({
          supervisor_id: supervisor.id,
          full_name: labour.full_name,
          phone: labour.phone,
          aadhaar: labour.aadhaar,
          gender: labour.gender || null,
          age: labour.age ? Number(labour.age) : null,
          token_uid: labour.token_uid,
        })

        const id = res?.data?.labour?.id
        if (id) createdLabourIds.push(id)
      }

      let manifest = null
      if (createdLabourIds.length) {
        const photosPayload = validRows.map((labour, idx) => ({
          labour_id: createdLabourIds[idx],
          image: labour.photo
        })).filter(p => p.image);

        const manifestRes = await labourApi.createManifest({
          supervisor_id: supervisor.id,
          labour_ids: createdLabourIds,
          photos: photosPayload
        });
        manifest = manifestRes?.data?.manifest || null
      }

      onSaved?.(manifest)
      handleClose()
    } catch (err) {
      console.error(err)
      const backendError =
        err?.response?.data?.error ||
        err?.response?.data?.message ||
        err?.message
      setError(backendError || 'Failed to enroll labours')
    } finally {
      setLoading(false)
    }
  }

  const handleClose = () => {
    setStep(1)
    setSupervisorId('')
    setSupervisor(null)
    setLabours([{ full_name: '', phone: '', aadhaar: '', token_uid: '', gender: '', age: '' }])
    setError(null)
    onClose()
  }

  useEffect(() => {
    let active = true
    if (!tokenQuery) {
      setTokenOptions([])
      return undefined
    }

    setTokenLoading(true)
    const t = setTimeout(async () => {
      try {
        const res = await labourApi.getAvailableTokens(tokenQuery, 20)
        const rows = res?.data?.tokens || []
        if (active) {
          setTokenOptions(rows.map((r) => r.uid))
        }
      } catch (err) {
        if (active) setTokenOptions([])
      } finally {
        if (active) setTokenLoading(false)
      }
    }, 300)

    return () => {
      active = false
      clearTimeout(t)
    }
  }, [tokenQuery])

  return (
    <Dialog open={open} onClose={handleClose} maxWidth="lg" fullWidth>

      {/* ================= HEADER ================= */}
      <DialogTitle sx={{ fontWeight: 600 }}>
        Labour Enrollment
      </DialogTitle>

      <DialogContent dividers>

        {/* ================= STEP 1 ================= */}
        {step === 1 && (
          <Box maxWidth={500} mx="auto">
            <Typography variant="subtitle1" gutterBottom>
              Enter Supervisor ID / Pass Number
            </Typography>

            <TextField
              fullWidth
              label="Supervisor ID"
              value={supervisorId}
              onChange={(e) => setSupervisorId(e.target.value)}
              margin="normal"
            />

            {error && (
              <Typography color="error" variant="body2">
                {error}
              </Typography>
            )}

            <Button
              fullWidth
              variant="contained"
              onClick={validateSupervisor}
              disabled={loading}
              sx={{ mt: 2 }}
            >
              Validate Supervisor
            </Button>
          </Box>
        )}

        {/* ================= STEP 2 ================= */}
        {step === 2 && supervisor && (
          <Box>

            {/* ===== Supervisor Card ===== */}
            <Box
              p={2}
              mb={3}
              border="1px solid #e0e0e0"
              borderRadius={2}
              bgcolor="#fafafa"
            >
              <Typography variant="h6" gutterBottom>
                Supervisor Details
              </Typography>

              <Typography><b>Name:</b> {supervisor.full_name}</Typography>
              <Typography><b>Company:</b> {supervisor.company_name || '-'}</Typography>
              <Typography><b>Phone:</b> {supervisor.primary_phone}</Typography>
            </Box>

            {/* ===== Labour Section ===== */}
            <Typography variant="h6" gutterBottom>
              Register Labours
            </Typography>

            <Typography variant="body2" color="text.secondary" mb={2}>
              RFID token is mandatory and valid only for today.
            </Typography>

            {labours.map((labour, index) => {
              const tokenValue = String(labour.token_uid || '').trim();

              const usedTokens = new Set(
                labours
                  .map((l, i) =>
                    i === index ? '' : String(l.token_uid || '').trim()
                  )
                  .filter(Boolean)
              );

              const isDuplicate = tokenValue && usedTokens.has(tokenValue);

              const availableOptions = tokenOptions.filter(
                (t) => !usedTokens.has(t) || t === tokenValue
              );

              return (
                <Box
                  key={index}
                  p={2}
                  mb={2}
                  border="1px solid #ddd"
                  borderRadius={2}
                >

                  {/* ===== ROW 1 ===== */}
                  <Box
                    display="flex"
                    flexWrap="wrap"
                    gap={2}
                    alignItems="center"
                  >

                    <TextField
                      label="Full Name"
                      value={labour.full_name}
                      onChange={(e) =>
                        handleLabourChange(index, 'full_name', e.target.value)
                      }
                      sx={{ minWidth: 200, flex: 1 }}
                    />

                    <TextField
                      select
                      label="Gender"
                      value={labour.gender}
                      onChange={(e) =>
                        handleLabourChange(index, 'gender', e.target.value)
                      }
                      sx={{ width: 120 }}
                    >
                      <MenuItem value="">Select</MenuItem>
                      <MenuItem value="Male">Male</MenuItem>
                      <MenuItem value="Female">Female</MenuItem>
                      <MenuItem value="Other">Other</MenuItem>
                    </TextField>

                    <TextField
                      label="Age"
                      type="number"
                      value={labour.age}
                      onChange={(e) =>
                        handleLabourChange(index, 'age', e.target.value)
                      }
                      inputProps={{ min: 15, max: 75 }}
                      sx={{ width: 90 }}
                    />

                    <TextField
                      label="Phone"
                      value={labour.phone}
                      onChange={(e) =>
                        handleLabourChange(index, 'phone', e.target.value)
                      }
                      sx={{ minWidth: 150 }}
                    />

                    <TextField
                      label="Aadhaar"
                      value={labour.aadhaar}
                      onChange={(e) =>
                        handleLabourChange(index, 'aadhaar', e.target.value)
                      }
                      sx={{ minWidth: 180 }}
                    />
                  </Box>

                  {/* ===== ROW 2 ===== */}
                  <Box
                    mt={2}
                    display="flex"
                    flexWrap="wrap"
                    gap={2}
                    alignItems="center"
                  >

                    {/* RFID */}
                    <Autocomplete
                      freeSolo
                      options={availableOptions}
                      loading={tokenLoading}
                      value={labour.token_uid || ''}
                      onInputChange={(_, value) => {
                        handleLabourChange(index, 'token_uid', value);
                        setTokenQuery(value);
                      }}
                      sx={{ minWidth: 250, flex: 1 }}
                      renderInput={(params) => (
                        <TextField
                          {...params}
                          label="RFID Token"
                          error={Boolean(isDuplicate)}
                          helperText={
                            isDuplicate
                              ? "Token already used in another row"
                              : ""
                          }
                        />
                      )}
                    />

                    {/* Photo Section */}
                    <Box display="flex" alignItems="center" gap={1}>

                      <Button
                        variant="outlined"
                        component="label"
                        size="small"
                      >
                        Upload
                        <input
                          type="file"
                          hidden
                          accept="image/*"
                          onChange={(e) =>
                            handlePhotoUpload(index, e.target.files[0])
                          }
                        />
                      </Button>

                      <Button
                        variant="outlined"
                        size="small"
                        onClick={() => handleCapturePhoto(index)}
                      >
                        Camera
                      </Button>

                      {labour.photo && (
                        <Box
                          component="img"
                          src={labour.photo}
                          alt="preview"
                          sx={{
                            width: 50,
                            height: 50,
                            objectFit: "cover",
                            borderRadius: 1,
                            border: "1px solid #ccc"
                          }}
                        />
                      )}
                    </Box>

                    {/* Remove */}
                    <Button
                      color="error"
                      onClick={() => removeRow(index)}
                    >
                      Remove
                    </Button>

                  </Box>
                </Box>
              );
            })}

            {/* Add Row */}
            <Button onClick={addRow} sx={{ mt: 1 }}>
              + Add Another Labour
            </Button>

            {error && (
              <Typography color="error" variant="body2" mt={2}>
                {error}
              </Typography>
            )}
          </Box>
        )}
      </DialogContent>

      {/* ================= FOOTER ================= */}
      <DialogActions>
        <Button onClick={handleClose}>Cancel</Button>

        {step === 2 && (
          <Button
            variant="contained"
            onClick={handleSubmit}
            disabled={loading}
          >
            Submit Labours
          </Button>
        )}
      </DialogActions>

    </Dialog>
  );
}
