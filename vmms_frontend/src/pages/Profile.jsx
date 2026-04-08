import React, { useState } from "react"
import {
  Box,
  Typography,
  Paper,
  TextField,
  Button,
  Alert,
  Stack,
} from "@mui/material"

import LockResetIcon from "@mui/icons-material/LockReset"
import CancelIcon from "@mui/icons-material/Cancel"

import api from "../api/axios"

export default function Profile() {

  const [currentPassword, setCurrentPassword] = useState("")
  const [newPassword, setNewPassword] = useState("")
  const [confirmPassword, setConfirmPassword] = useState("")
  const [saving, setSaving] = useState(false)

  const [error, setError] = useState("")
  const [message, setMessage] = useState("")

  const handleChangePassword = async (e) => {
    e.preventDefault()

    setError("")
    setMessage("")

    if (!currentPassword || !newPassword || !confirmPassword) {
      setError("All password fields are required")
      return
    }

    if (newPassword !== confirmPassword) {
      setError("Passwords do not match")
      return
    }

    setSaving(true)

    try {
      const res = await api.post("/auth/change-password", {
        current_password: currentPassword,
        new_password: newPassword,
      })

      setMessage(res?.data?.message || "Password updated")
      setCurrentPassword("")
      setNewPassword("")
      setConfirmPassword("")
    } catch (err) {
      setError(
        err?.response?.data?.message ||
        err?.message ||
        "Password update failed"
      )
    } finally {
      setSaving(false)
    }
  }

  const handleClear = () => {
    setCurrentPassword("")
    setNewPassword("")
    setConfirmPassword("")
    setError("")
    setMessage("")
  }

  return (
    <Box>

      <Stack direction="row" spacing={1.5} alignItems="center" sx={{ mb: 3 }}>
        <LockResetIcon sx={{ fontSize: 28 }} />
        <Typography variant="h5" fontWeight={700}>
          Change Password
        </Typography>
      </Stack>

      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}

      {message && (
        <Alert severity="success" sx={{ mb: 2 }}>
          {message}
        </Alert>
      )}

      <Paper sx={{ p: 3 }}>
        <form onSubmit={handleChangePassword}>
          <Stack spacing={2}>
            <TextField
              fullWidth
              label="Current Password"
              type="password"
              value={currentPassword}
              onChange={(e) => setCurrentPassword(e.target.value)}
              required
            />

            <TextField
              fullWidth
              label="New Password"
              type="password"
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
              required
            />

            <TextField
              fullWidth
              label="Confirm Password"
              type="password"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              required
            />

            <Stack direction="row" spacing={2}>
              <Button type="submit" variant="contained" disabled={saving}>
                {saving ? "Updating..." : "Update Password"}
              </Button>

              <Button
                variant="outlined"
                startIcon={<CancelIcon />}
                onClick={handleClear}
              >
                Clear
              </Button>
            </Stack>
          </Stack>
        </form>
      </Paper>
    </Box>
  )
}
