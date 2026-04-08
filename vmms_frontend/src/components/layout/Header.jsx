import React, { useEffect, useState } from "react"
import {
  AppBar,
  Toolbar,
  IconButton,
  Typography,
  Box,
  Menu,
  MenuItem,
} from "@mui/material"

import MenuIcon from "@mui/icons-material/Menu"
import LogoutRoundedIcon from "@mui/icons-material/LogoutRounded"
import PowerSettingsNewRoundedIcon from "@mui/icons-material/PowerSettingsNewRounded"
import AccountCircleIcon from "@mui/icons-material/AccountCircle"
import Tooltip from "@mui/material/Tooltip"

import useAuthStore from "../../store/auth.store"
import { useNavigate } from "react-router-dom"

export default function Header({ onMenuClick }) {

  const logout = useAuthStore((s) => s.logout)
  const navigate = useNavigate()

  const [currentTime, setCurrentTime] = useState(new Date())
  const [menuAnchor, setMenuAnchor] = useState(null)

  /* =============================
     REAL TIME CLOCK
  ============================== */

  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentTime(new Date())
    }, 1000)

    return () => clearInterval(timer)
  }, [])

  /* =============================
     LOGOUT HANDLER
  ============================== */

  const handleLogout = () => {
    setMenuAnchor(null)
    logout()
    navigate("/login")
  }

  const handleProfile = () => {
    setMenuAnchor(null)
    navigate("/profile")
  }

  /* =============================
     DATE & TIME FORMAT
  ============================== */

  const formattedDate = currentTime.toLocaleDateString("en-IN", {
    weekday: "short",
    day: "2-digit",
    month: "long",
    year: "numeric",
  })

  const formattedTime = currentTime.toLocaleTimeString("en-IN", {
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hour12: true,
  })

  return (
    <AppBar
      position="static"
      elevation={0}
      sx={{
        background: "#0b1d2e",
        borderBottom: "3px solid #d4af37",
      }}
    >

      <Toolbar
        sx={{
          minHeight: 70,
          px: 3,
          display: "flex",
          alignItems: "center",
        }}
      >

        {/* MENU BUTTON */}

        <IconButton
          onClick={onMenuClick}
          sx={{
            color: "#ffffff",
            mr: 2,
          }}
        >
          <MenuIcon />
        </IconButton>


        {/* LEFT LOGO */}

        <Box
          sx={{
            display: "flex",
            alignItems: "center",
            mr: 2,
          }}
        >

          <Box
            component="img"
            src="/logos/indian_navy.png"
            alt="Indian Navy"
            sx={{ height: 42 }}
          />

        </Box>


        {/* SYSTEM TITLE */}

        <Box sx={{ flexGrow: 1 }}>

          <Typography
            sx={{
              fontWeight: 700,
              letterSpacing: 1.2,
              fontSize: { xs: 14, md: 18 },
              color: "#ffffff",
            }}
          >
            NAVAL AIRFIELD VISITOR MANAGEMENT SYSTEM
          </Typography>

          <Typography
            sx={{
              fontSize: 12,
              letterSpacing: 1,
              color: "#9fb3d9",
            }}
          >
            INS RAJALI • INDIAN NAVY
          </Typography>

        </Box>


        {/* RIGHT SECTION */}

        <Box
          sx={{
            display: "flex",
            alignItems: "center",
            gap: 4,
          }}
        >

          {/* DATE TIME */}

          <Box sx={{ textAlign: "right" }}>

            <Typography
              sx={{
                fontSize: 12,
                color: "#9fb3d9",
                letterSpacing: 0.5,
              }}
            >
              {formattedDate}
            </Typography>

            <Typography
              sx={{
                fontSize: 20,
                fontWeight: 700,
                color: "#ffffff",
                fontFamily: "monospace",
                letterSpacing: 1,
              }}
            >
              {formattedTime}
            </Typography>

          </Box>


          {/* NATIONAL / MAKE IN INDIA */}

          <Box
            sx={{
              display: { xs: "none", md: "flex" },
              alignItems: "center",
              gap: 2,
            }}
          >

            <Box
              component="img"
              src="/logos/india_flag.png"
              alt="India"
              sx={{ height: 20 }}
            />

            <Box
              component="img"
              src="/logos/make_in_india.png"
              alt="Make in India"
              sx={{ height: 26 }}
            />

          </Box>


          {/* LOGOUT POWER BUTTON */}

          <Tooltip title="Account" arrow>
            <IconButton
              onClick={(e) => setMenuAnchor(e.currentTarget)}
              size="small"
              sx={{
                width: 36,
                height: 36,
                borderRadius: "50%",
                color: "#ff7a7a",
                border: "1px solid rgba(255,255,255,0.2)",
                transition: "all 0.2s ease",
                "&:hover": {
                  backgroundColor: "rgba(255,0,0,0.08)",
                  borderColor: "#ff7a7a",
                  transform: "scale(1.05)",
                },
              }}
            >
              <PowerSettingsNewRoundedIcon sx={{ fontSize: 20 }} />
            </IconButton>
          </Tooltip>

          <Menu
            anchorEl={menuAnchor}
            open={Boolean(menuAnchor)}
            onClose={() => setMenuAnchor(null)}
            anchorOrigin={{ vertical: "bottom", horizontal: "right" }}
            transformOrigin={{ vertical: "top", horizontal: "right" }}
          >
            <MenuItem onClick={handleProfile}>
              <AccountCircleIcon fontSize="small" style={{ marginRight: 8 }} />
              Chnage Password
            </MenuItem>
            <MenuItem onClick={handleLogout}>
              <LogoutRoundedIcon fontSize="small" style={{ marginRight: 8 }} />
              Logout
            </MenuItem>
          </Menu>

        </Box>

      </Toolbar>

    </AppBar>
  )
}
