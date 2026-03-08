import React from "react"
import Grid from "@mui/material/Grid"
import { Box, Typography, Stack } from "@mui/material"

export default function KpiCard({ label, value, color }) {

  return (
    <Grid size={{ xs: 6, sm: 4, md: 4 }}>
      <Box
        sx={{
          px: 1.4,
          py: 1.2,
          borderRadius: 1.8,
          minHeight: 66,

          display: "flex",
          flexDirection: "column",
          justifyContent: "center",

          background: "rgba(15,23,42,0.65)",
          backdropFilter: "blur(6px)",

          border: "1px solid rgba(148,163,184,0.22)",

          transition: "all 0.2s ease",

          "&:hover": {
            border: "1px solid rgba(212,175,55,0.45)",
            boxShadow: "0 0 8px rgba(212,175,55,0.2)"
          }
        }}
      >

        <Stack spacing={0.3}>

          {/* LABEL */}

          <Typography
            sx={{
              fontSize: 10.5,
              letterSpacing: 0.6,
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
              fontSize: 22,
              fontWeight: 900,
              color: color || "#e6ecff",
              lineHeight: 1.1,

              textShadow: color
                ? `0 0 6px ${color}55`
                : "none"
            }}
          >
            {value}
          </Typography>

        </Stack>

      </Box>
    </Grid>
  )
}
