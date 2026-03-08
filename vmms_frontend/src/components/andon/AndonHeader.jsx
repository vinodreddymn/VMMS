import React from "react"
import { Box, Typography, Stack, Divider, Chip } from "@mui/material"
import SecurityIcon from "@mui/icons-material/Security"
import FiberManualRecordIcon from "@mui/icons-material/FiberManualRecord"

import { formatTime } from "../../utils/timeUtils"

export default function AndonHeader({ now, headerDate }) {

  const systemStatus = "OPERATIONAL"

  return (
    <Box sx={{ display: "flex", flexDirection: "column", gap: 0.5 }}>

      {/* MAIN HEADER */}

      <Box
        sx={{
          display: "grid",
          gridTemplateColumns: "auto 1fr auto",
          alignItems: "center",
          px: 2,
          py: 0.8,
          borderRadius: 1.5,

          background:
            "linear-gradient(135deg, rgba(6,18,45,0.95), rgba(15,42,90,0.9))",

          border: "1px solid rgba(212,175,55,0.35)",
          boxShadow: "0 0 10px rgba(0,0,0,0.35)"
        }}
      >

        {/* LEFT LOGOS */}

        <Stack direction="row" spacing={1.5} alignItems="center">

          <Box
            component="img"
            src="/logos/indian_navy.png"
            sx={{ height: 38 }}
          />

          <Divider
            orientation="vertical"
            flexItem
            sx={{ borderColor: "rgba(255,255,255,0.2)" }}
          />

          <Box
            component="img"
            src="/logos/india_flag.png"
            sx={{ height: 18 }}
          />

        </Stack>


        {/* CENTER TITLE */}

        <Stack alignItems="center" spacing={0.2}>

          <Typography
            sx={{
              fontWeight: 800,
              fontSize: 16,
              letterSpacing: 1.2,
              color: "#ffffff"
            }}
          >
            NAVAL AIRFIELD VISITOR MANAGEMENT SYSTEM
          </Typography>

          <Stack direction="row" spacing={1} alignItems="center">

            <Typography
              sx={{
                fontSize: 11,
                letterSpacing: 1.5,
                color: "#9fb3d9"
              }}
            >
              INS RAJALI • INDIAN NAVY
            </Typography>

            <Chip
              size="small"
              icon={<SecurityIcon sx={{ fontSize: 12 }} />}
              label={systemStatus}
              sx={{
                height: 18,
                fontSize: 9,
                color: "#d4af37",
                border: "1px solid rgba(212,175,55,0.35)",
                background: "rgba(0,0,0,0.25)"
              }}
            />

          </Stack>

        </Stack>


        {/* RIGHT TIME */}

        <Stack alignItems="flex-end" spacing={0}>

          <Stack direction="row" spacing={0.6} alignItems="center">

            <FiberManualRecordIcon
              sx={{
                fontSize: 10,
                color: "#00ff9c"
              }}
            />

            <Typography
              sx={{
                fontSize: 18,
                fontWeight: 800,
                fontFamily: "monospace",
                color: "#d4af37",
                letterSpacing: 1
              }}
            >
              {formatTime(now)}
            </Typography>

          </Stack>

          <Typography
            sx={{
              fontSize: 10,
              color: "#9fb3d9"
            }}
          >
            {headerDate}
          </Typography>

        </Stack>

      </Box>


      {/* COMPACT ALERT BAR */}

      <Box
        sx={{
          height: 22,
          display: "flex",
          alignItems: "center",
          px: 1.5,
          borderRadius: 1,

          background: "rgba(0,0,0,0.55)",
          border: "1px solid rgba(212,175,55,0.25)",
          overflow: "hidden"
        }}
      >

        <Typography
          sx={{
            fontSize: 11,
            whiteSpace: "nowrap",
            animation: "scrollText 18s linear infinite",
            color: "#d4af37",
            letterSpacing: 0.8
          }}
        >
          SECURITY NOTICE • VISITORS MUST BE ESCORTED WITH VALID PASS •
          UNAUTHORIZED ENTRY INTO AIRFIELD AREA IS STRICTLY PROHIBITED
        </Typography>

      </Box>


      {/* Animation */}

      <style>
        {`
        @keyframes scrollText {
          0% { transform: translateX(100%) }
          100% { transform: translateX(-100%) }
        }
        `}
      </style>

    </Box>
  )
}