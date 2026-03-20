import React, { useState } from "react"
import api from "../api/axios"
import useAuthStore from "../store/auth.store"
import { useNavigate } from "react-router-dom"

import {
  Box,
  Typography,
  TextField,
  Button,
  Paper,
  Divider,
  Chip,
  InputAdornment,
  Avatar
} from "@mui/material"

import LockIcon from "@mui/icons-material/Lock"
import PersonIcon from "@mui/icons-material/Person"
import SecurityIcon from "@mui/icons-material/Security"

export default function Login() {

  const [username, setUsername] = useState("")
  const [password, setPassword] = useState("")
  const [loading, setLoading] = useState(false)

  const loginStore = useAuthStore()
  const navigate = useNavigate()

  async function handleSubmit(e) {
    e.preventDefault()
    setLoading(true)

    try {
      const res = await api.post("/auth/login", { username, password })

      const token = res?.data?.token
      const apiUser = res?.data?.user || null

      let user = apiUser

      if (!user && token) {
        const payload = JSON.parse(atob(token.split(".")[1]))
        user = { id: payload.id, role: payload.role, username }
      }

      if (!token || !user) {
        throw new Error("Invalid login response")
      }

      loginStore.login(token, user)
      navigate("/")

    } catch (err) {
      alert(err?.response?.data?.message || err?.message || "Login failed")
    } finally {
      setLoading(false)
    }
  }

  return (

    <Box
      sx={{
        height: "100%",
        width: "100%",
        display: "flex",
        backgroundColor: "#081a33"
      }}
    >

      {/* LEFT LOGIN PANEL */}

      <Box
        sx={{
          width: { xs: "100%", md: "38%" },
          height: "100%",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          padding: 4,
          background:
            "linear-gradient(135deg,#081a33 0%,#0f2a5a 60%,#1e3a8a 100%)"
        }}
      >

        <Paper
          elevation={12}
          sx={{
            width: "100%",
            maxWidth: 420,
            padding: 4,
            borderRadius: 3,
            background: "rgba(255,255,255,0.95)",
            backdropFilter: "blur(10px)"
          }}
        >

          {/* HEADER */}

          <Box sx={{ textAlign: "center", mb: 3 }}>

            <Avatar
              sx={{
                bgcolor: "#1e3a8a",
                width: 60,
                height: 60,
                margin: "auto",
                mb: 1
              }}
            >
              <SecurityIcon />
            </Avatar>

            <Typography variant="h5" sx={{ fontWeight: 800 }}>
              INS RAJALI
            </Typography>

            <Typography variant="subtitle2" color="text.secondary">
              Naval Airfield Visitor Management System
            </Typography>

          </Box>

          <Divider sx={{ mb: 3 }}>
            <Chip label="SECURE LOGIN" size="small" />
          </Divider>

          {/* FORM */}

          <form onSubmit={handleSubmit}>

            <TextField
              fullWidth
              label="Username"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              required
              margin="normal"
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <PersonIcon />
                  </InputAdornment>
                )
              }}
            />

            <TextField
              fullWidth
              label="Password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              margin="normal"
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <LockIcon />
                  </InputAdornment>
                )
              }}
            />

            <Button
              fullWidth
              type="submit"
              variant="contained"
              disabled={loading}
              sx={{
                mt: 3,
                py: 1.4,
                fontWeight: 700,
                letterSpacing: 0.5,
                background:
                  "linear-gradient(90deg,#1e3a8a,#2563eb)",
                boxShadow:
                  "0 8px 25px rgba(30,64,175,0.35)",
                transition: "0.3s",
                "&:hover": {
                  transform: "translateY(-2px)"
                }
              }}
            >
              {loading ? "Authenticating..." : "SECURE SIGN IN"}
            </Button>

          </form>

          <Typography
            variant="caption"
            sx={{
              display: "block",
              mt: 3,
              textAlign: "center",
              color: "text.secondary"
            }}
          >
            Authorized Naval Personnel Only • All access monitored
          </Typography>

        </Paper>

      </Box>

      {/* RIGHT HERO IMAGE */}

      <Box
        sx={{
          display: { xs: "none", md: "block" },
          width: "62%",
          height: "100%",
          position: "relative",
          backgroundImage: 'url("/assets/naval_airfield.jpg")',
          backgroundSize: "cover",
          backgroundPosition: "center"
        }}
      >

        {/* DARK OVERLAY */}

        <Box
          sx={{
            position: "absolute",
            inset: 0,
            background:
              "linear-gradient(90deg,rgba(8,26,51,0.95) 0%,rgba(8,26,51,0.5) 60%,rgba(8,26,51,0.9) 100%)"
          }}
        />

        {/* HERO TEXT */}

        <Box
          sx={{
            position: "absolute",
            bottom: 500,
            left: 80,
            maxWidth: 550,
            color: "#e6ecff"
          }}
        >

          <Typography
            variant="h3"
            sx={{ fontWeight: 900, mb: 2 }}
          >
            INS RAJALI
          </Typography>

          <Typography
            variant="h6"
            sx={{ lineHeight: 1.6, opacity: 0.9 }}
          >
            Secure Naval Airfield Access Control and Visitor
            Processing System designed for high-security
            maritime aviation operations.
          </Typography>

          <Typography
            variant="body2"
            sx={{ mt: 2, opacity: 0.8 }}
          >
            Real-time gate clearance • Personnel authentication
            • Operational security monitoring
          </Typography>

        </Box>

      </Box>

    </Box>
  )
}
