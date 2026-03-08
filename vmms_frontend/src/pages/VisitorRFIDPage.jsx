import React, { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import {
  Box,
  Typography,
  Paper,
  Button,
  TextField,
  Divider,
  Chip,
  CircularProgress,
  Alert,
  Autocomplete
} from '@mui/material'
import {
  getVisitor,
  getRFIDCard,
  getAvailableRFIDCards,
  issueRFIDCard,
  updateRFIDCard,
  deleteRFIDCard,
} from '../api/visitor.api'
import useAuthStore from '../store/auth.store'
import { normalizeRole, canEditVisitor } from '../utils/visitorPermissions'

export default function VisitorRFIDPage() {
  const { id } = useParams()
  const navigate = useNavigate()
  const user = useAuthStore((s) => s.user)
  const allowEdit = canEditVisitor(normalizeRole(user))

  const [loading, setLoading] = useState(true)
  const [submitting, setSubmitting] = useState(false)
  const [visitor, setVisitor] = useState(null)
  const [rfidCard, setRfidCard] = useState(null)
  const [issueDate, setIssueDate] = useState(new Date().toISOString().split('T')[0])
  const [expiryDate, setExpiryDate] = useState('')
  const [selectedCardUid, setSelectedCardUid] = useState('')
  const [cardOptions, setCardOptions] = useState([])
  const [cardQuery, setCardQuery] = useState('')
  const [cardLoading, setCardLoading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')

  if (!allowEdit) {
    return (
      <Paper sx={{ p: 3, maxWidth: 720, mx: 'auto' }}>
        <Alert severity="warning" sx={{ mb: 2 }}>
          RFID management is restricted to ADMIN, SUPER_ADMIN, or REGULATING_PETTY_OFFICER.
        </Alert>
        <Button variant="contained" onClick={() => navigate(-1)}>
          Back
        </Button>
      </Paper>
    )
  }

  useEffect(() => {
    let mounted = true
    setLoading(true)

    Promise.all([getVisitor(id), getRFIDCard(id)])
      .then(([visitorRes, rfidRes]) => {
        if (!mounted) return
        const profile = visitorRes?.data?.visitor || null
        const card = rfidRes?.data?.rfidCard || null
        setVisitor(profile)
        setRfidCard(card)
        if (card?.issue_date) setIssueDate(new Date(card.issue_date).toISOString().split('T')[0])
        if (card?.expiry_date) setExpiryDate(new Date(card.expiry_date).toISOString().split('T')[0])
      })
      .finally(() => mounted && setLoading(false))

    return () => (mounted = false)
  }, [id])

  useEffect(() => {
    let active = true
    if (!cardQuery) {
      setCardOptions([])
      return undefined
    }

    setCardLoading(true)
    const timer = setTimeout(async () => {
      try {
        const res = await getAvailableRFIDCards(cardQuery, 20)
        const rows = res?.data?.cards || []
        if (active) setCardOptions(rows.map((r) => r.uid))
      } catch {
        if (active) setCardOptions([])
      } finally {
        if (active) setCardLoading(false)
      }
    }, 300)

    return () => {
      active = false
      clearTimeout(timer)
    }
  }, [cardQuery, rfidCard])

  const handleSaveCard = async () => {
    if (!expiryDate) {
      alert('Please select expiry date')
      return
    }

    try {
      setSubmitting(true)
      setError('')
      setSuccess('')

      if (selectedCardUid) {
        // Re-assignment path: backend deactivates old active card and assigns selected new card.
        await issueRFIDCard(id, {
          visitor_id: id,
          card_uid: selectedCardUid,
          issue_date: issueDate,
          expiry_date: expiryDate
        })
      } else if (rfidCard) {
        // Metadata update for current active card.
        await updateRFIDCard(id, {
          issue_date: issueDate,
          expiry_date: expiryDate,
          card_status: 'ACTIVE',
        })
      } else {
        setError('Please select an available RFID card UID')
        return
      }

      const latest = await getRFIDCard(id)
      setRfidCard(latest?.data?.rfidCard || null)
      setSelectedCardUid('')
      setCardQuery('')
      setSuccess(
        selectedCardUid
          ? 'New RFID assigned successfully. Previous active RFID was replaced.'
          : rfidCard
            ? 'RFID card updated successfully'
            : 'RFID card issued successfully'
      )
    } catch (err) {
      console.error(err)
      setError(err?.response?.data?.error || 'Failed to save RFID card')
    } finally {
      setSubmitting(false)
    }
  }

  const handleDeleteCard = async () => {
    const ok = window.confirm('Delete RFID card for this visitor?')
    if (!ok) return

    try {
      setSubmitting(true)
      setError('')
      setSuccess('')
      await deleteRFIDCard(id)
      setRfidCard(null)
      setSelectedCardUid('')
      setSuccess('RFID card deleted successfully')
    } catch (err) {
      console.error(err)
      setError(err?.response?.data?.error || 'Failed to delete RFID card')
    } finally {
      setSubmitting(false)
    }
  }

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" mt={5}>
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Box>
      {/* Header */}
      <Paper sx={{ p: 3, mb: 2 }}>
        <Typography variant="h5" fontWeight={600}>
          RFID Card Management
        </Typography>
        <Typography color="text.secondary">
          Visitor: {visitor?.full_name} (Pass: {visitor?.pass_no})
        </Typography>
      </Paper>

      {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
      {success && <Alert severity="success" sx={{ mb: 2 }}>{success}</Alert>}

      {/* Existing Card */}
      <Paper sx={{ p: 3, mb: 3 }}>
        <Typography variant="h6">Current Active RFID Card</Typography>
        <Divider sx={{ my: 2 }} />

        {!rfidCard ? (
          <Typography color="text.secondary">No active RFID card</Typography>
        ) : (
          <Box display="flex" gap={2} flexWrap="wrap">
            <Chip
              label={`UID: ${rfidCard.card_uid}`}
              color={rfidCard.card_status === 'ACTIVE' ? 'success' : 'default'}
            />
          </Box>
        )}
      </Paper>

      {/* Issue / Reissue Form */}
      <Paper sx={{ p: 3 }}>
        <Typography variant="h6">
          {rfidCard ? 'Update RFID Card' : 'Issue New RFID Card'}
        </Typography>
        <Divider sx={{ mb: 2 }} />

        <Box sx={{ mb: 2 }}>
          <Autocomplete
            freeSolo={false}
            options={cardOptions}
            loading={cardLoading}
            value={selectedCardUid}
            onInputChange={(_, value) => {
              setCardQuery(value)
            }}
            onChange={(_, value) => setSelectedCardUid(value || '')}
            renderInput={(params) => (
              <TextField
                {...params}
                label={rfidCard ? 'Assign New RFID UID (from stock)' : 'RFID UID (from stock)'}
                placeholder="Search available RFID card UID"
                fullWidth
              />
            )}
          />
        </Box>

        <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', md: '1fr 1fr' }, gap: 2 }}>
          <Box>
            <TextField
              type="date"
              fullWidth
              label="Issue Date"
              value={issueDate}
              onChange={(e) => setIssueDate(e.target.value)}
              InputLabelProps={{ shrink: true }}
            />
          </Box>

          <Box>
            <TextField
              type="date"
              fullWidth
              label="Expiry Date"
              value={expiryDate}
              onChange={(e) => setExpiryDate(e.target.value)}
              InputLabelProps={{ shrink: true }}
            />
          </Box>
        </Box>

        <Divider sx={{ my: 3 }} />

        <Box display="flex" justifyContent="flex-end" gap={2}>
          <Button variant="outlined" onClick={() => navigate(-1)}>
            Cancel
          </Button>
          {rfidCard && (
            <Button
              variant="outlined"
              color="error"
              onClick={handleDeleteCard}
              disabled={submitting}
            >
              Delete RFID
            </Button>
          )}
          <Button
            variant="contained"
            onClick={handleSaveCard}
            disabled={submitting}
          >
            {submitting ? <CircularProgress size={20} /> : selectedCardUid ? 'Assign Selected RFID' : (rfidCard ? 'Update Current RFID' : 'Issue RFID')}
          </Button>
        </Box>
      </Paper>
    </Box>
  )
}
