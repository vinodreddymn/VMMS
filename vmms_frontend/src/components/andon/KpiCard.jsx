import React from "react"
import { Box, Typography, Stack } from "@mui/material"

export default function KpiCard({
  label,
  value,
  color = "#e6ecff",
  icon = null
}) {

  return (
    <Box
      sx={{
        px: 1.6,
        py: 1.3,
        borderRadius: 2,
        minHeight: 70,

        display: "flex",
        alignItems: "center",
        justifyContent: "space-between",

        background: "rgba(15,23,42,0.65)",
        backdropFilter: "blur(6px)",

        border: "1px solid rgba(148,163,184,0.22)",

        position: "relative",
        overflow: "hidden",

        transition: "all 0.25s ease",

        "&:hover": {
          border: "1px solid rgba(212,175,55,0.45)",
          boxShadow: "0 0 12px rgba(212,175,55,0.25)"
        }
      }}
    >

      {/* LEFT STATUS BAR */}

      <Box
        sx={{
          position: "absolute",
          left: 0,
          top: 0,
          bottom: 0,
          width: 3,
          background: color,
          boxShadow: `0 0 10px ${color}`
        }}
      />

      {/* CONTENT */}

      <Stack spacing={0.3} sx={{ pl: 0.5 }}>

        {/* LABEL */}

        <Typography
          sx={{
            fontSize: 10.5,
            letterSpacing: 0.7,
            fontWeight: 500,
            color: "rgba(226,232,240,0.75)",
            textTransform: "uppercase"
          }}
        >
          {label}
        </Typography>

        {/* VALUE */}

        <Typography
          sx={{
            fontSize: 24,
            fontWeight: 900,
            color: color,
            lineHeight: 1.1,
            letterSpacing: 0.5,

            textShadow: `0 0 8px ${color}55`
          }}
        >
          {value}
        </Typography>

      </Stack>

      {/* OPTIONAL ICON */}

      {icon && (
        <Box
          sx={{
            opacity: 0.3,
            fontSize: 30,
            display: "flex",
            alignItems: "center",
            justifyContent: "center"
          }}
        >
          {icon}
        </Box>
      )}

    </Box>
  )
}