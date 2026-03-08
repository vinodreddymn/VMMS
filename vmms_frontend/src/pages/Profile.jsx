import React, { useEffect, useMemo, useState } from "react"
import {
  Box,
  Typography,
  Grid,
  Paper,
  Divider,
  TextField,
  Button,
  Alert,
  Chip,
  Stack,
  Collapse
} from "@mui/material"

import AccountCircleIcon from "@mui/icons-material/AccountCircle"
import LockResetIcon from "@mui/icons-material/LockReset"
import CancelIcon from "@mui/icons-material/Cancel"

import api from "../api/axios"
import useAuthStore from "../store/auth.store"

export default function Profile() {

  const storedUser = useAuthStore((s) => s.user)
  const setUser = useAuthStore((s) => s.setUser)

  const [profile, setProfile] = useState(storedUser)

  const [loading, setLoading] = useState(false)
  const [error, setError] = useState("")
  const [message, setMessage] = useState("")

  const [showPasswordForm, setShowPasswordForm] = useState(false)

  const [currentPassword, setCurrentPassword] = useState("")
  const [newPassword, setNewPassword] = useState("")
  const [confirmPassword, setConfirmPassword] = useState("")
  const [saving, setSaving] = useState(false)


  /* ========================
     LOAD PROFILE
  ======================== */

  useEffect(() => {

    let mounted = true

    const loadProfile = async () => {

      setLoading(true)

      try {

        const res = await api.get("/auth/me")

        if (mounted && res?.data?.user) {
          setProfile(res.data.user)
          setUser(res.data.user)
        }

      } catch (err) {

        if (mounted) {
          setError(
            err?.response?.data?.message ||
            err?.message ||
            "Failed to load profile"
          )
        }

      } finally {
        if (mounted) setLoading(false)
      }

    }

    loadProfile()

    return () => { mounted = false }

  }, [setUser])


  /* ========================
     PROFILE FIELDS
  ======================== */

  const fields = useMemo(() => {

    if (!profile) return []

    return [
      { label: "Username", value: profile.username },
      { label: "Full Name", value: profile.full_name },
      { label: "Phone Number", value: profile.phone },
      { label: "Role", value: profile.role_name || profile.role },
      { label: "Active Account", value: profile.is_active },
      { label: "PDF Export Permission", value: profile.can_export_pdf },
      { label: "Excel Export Permission", value: profile.can_export_excel }
    ]

  }, [profile])


  /* ========================
     PASSWORD CHANGE
  ======================== */

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
        new_password: newPassword
      })

      setMessage(res?.data?.message || "Password updated")

      setCurrentPassword("")
      setNewPassword("")
      setConfirmPassword("")
      setShowPasswordForm(false)

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


  return (
    <Box>

      {/* HEADER */}

      <Stack direction="row" spacing={2} alignItems="center" sx={{ mb: 3 }}>

        <AccountCircleIcon sx={{ fontSize: 30 }} />

        <Typography variant="h5" fontWeight={700}>
          My Profile
        </Typography>

        <Chip label={profile?.role_name || profile?.role || "USER"} />

      </Stack>


      {loading && (
        <Alert severity="info" sx={{ mb: 2 }}>
          Loading profile...
        </Alert>
      )}

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


      {/* PROFILE DETAILS */}

      <Paper sx={{ p: 3 }}>

        <Typography fontWeight={600} sx={{ mb: 2 }}>
          Account Details
        </Typography>

        <Divider sx={{ mb: 3 }} />

        <Grid container spacing={2}>

          {fields.map((field) => (

            <Grid item xs={12} key={field.label}>

              <TextField
                fullWidth
                label={field.label}
                value={field.value ?? "-"}
                InputProps={{ readOnly: true }}
              />

            </Grid>

          ))}

        </Grid>

        <Divider sx={{ my: 3 }} />

        <Button
          variant="contained"
          startIcon={<LockResetIcon />}
          onClick={() => setShowPasswordForm(!showPasswordForm)}
        >
          Change Password
        </Button>

      </Paper>


      {/* PASSWORD FORM */}

      <Collapse in={showPasswordForm}>

        <Paper sx={{ p: 3, mt: 3 }}>

          <Typography fontWeight={600} sx={{ mb: 2 }}>
            Change Password
          </Typography>

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

                <Button
                  type="submit"
                  variant="contained"
                  disabled={saving}
                >
                  {saving ? "Updating..." : "Update Password"}
                </Button>

                <Button
                  variant="outlined"
                  startIcon={<CancelIcon />}
                  onClick={() => setShowPasswordForm(false)}
                >
                  Cancel
                </Button>

              </Stack>

            </Stack>

          </form>

        </Paper>

      </Collapse>

    </Box>
  )
}