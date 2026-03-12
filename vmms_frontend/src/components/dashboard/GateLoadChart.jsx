import React, { useEffect, useState } from "react"
import {
  Card,
  CardContent,
  CardHeader,
  Box,
  CircularProgress,
  Alert,
  Typography,
  Grid,
  Paper,
  Chip,
  LinearProgress,
  Divider
} from "@mui/material"
import api from "../../api/axios"

export default function GateLoadChart() {

  const [gateStats, setGateStats] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState("")

  useEffect(() => {
    fetchGateLoad()
  }, [])

  const fetchGateLoad = async () => {
    setLoading(true)

    try {
      const today = new Date().toISOString().split("T")[0]

      const res = await api.get(
        `/analytics/gate-stats?from_date=${today}&to_date=${today}`
      )

      setGateStats(res?.data?.gateStats || [])
      setError("")
    } catch (err) {
      setError(err?.response?.data?.error || "Failed to fetch gate load")
    } finally {
      setLoading(false)
    }
  }

  const getLoadStatus = (scans) => {
    if (scans > 200) return { label: "HIGH LOAD", color: "error" }
    if (scans > 100) return { label: "MEDIUM LOAD", color: "warning" }
    return { label: "LOW LOAD", color: "success" }
  }

  const getProgressColor = (color) => {
    if (color === "error") return "#ef5350"
    if (color === "warning") return "#fb8c00"
    return "#43a047"
  }

  return (
    <Card
      elevation={0}
      sx={{
        borderRadius: 3,
        border: "1px solid #e5e7eb",
        height: "100%"
      }}
    >
      <CardHeader
        title="Gate Load Distribution"
        subheader="Today's gate traffic analytics"
        titleTypographyProps={{ fontWeight: 700 }}
        sx={{ borderBottom: "1px solid #eee" }}
      />

      <CardContent>

        {/* Error State */}
        {error && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {error}
          </Alert>
        )}

        {/* Loading */}
        {loading ? (
          <Box sx={{ display: "flex", justifyContent: "center", py: 6 }}>
            <CircularProgress size={34} />
          </Box>
        ) : gateStats.length === 0 ? (
          <Alert severity="info">No gate activity recorded today</Alert>
        ) : (

          <Grid container spacing={2}>

            {gateStats.map((gate) => {

              const status = getLoadStatus(gate.total_scans)

              const capacity =
                Math.min((gate.total_scans / 300) * 100, 100)

              const failureRate = gate.total_scans
                ? ((gate.failed_scans / gate.total_scans) * 100).toFixed(1)
                : 0

              return (

                <Grid item xs={12} md={6} key={gate.id}>

                  <Paper
                    elevation={0}
                    sx={{
                      p: 2.5,
                      borderRadius: 2,
                      border: "1px solid #e5e7eb",
                      transition: "all 0.25s",
                      "&:hover": {
                        boxShadow: "0 6px 18px rgba(0,0,0,0.06)",
                        transform: "translateY(-2px)"
                      }
                    }}
                  >

                    {/* Header */}
                    <Box
                      sx={{
                        display: "flex",
                        justifyContent: "space-between",
                        alignItems: "center",
                        mb: 1
                      }}
                    >
                      <Typography fontWeight={700}>
                        {gate.gate_name}
                      </Typography>

                      <Chip
                        label={status.label}
                        size="small"
                        color={status.color}
                      />
                    </Box>

                    <Typography
                      variant="caption"
                      color="text.secondary"
                    >
                      {gate.entrance_name || "No entrance assigned"}
                    </Typography>

                    <Divider sx={{ my: 1.5 }} />

                    {/* Stats */}
                    <Grid container spacing={1}>

                      <Grid item xs={6}>
                        <Typography variant="caption" color="text.secondary">
                          Total Scans
                        </Typography>
                        <Typography variant="h5" fontWeight={700}>
                          {gate.total_scans}
                        </Typography>
                      </Grid>

                      <Grid item xs={6}>
                        <Typography variant="caption" color="text.secondary">
                          Failed
                        </Typography>
                        <Typography
                          variant="h6"
                          fontWeight={700}
                          color="error"
                        >
                          {gate.failed_scans} ({failureRate}%)
                        </Typography>
                      </Grid>

                      <Grid item xs={6}>
                        <Typography variant="caption" color="text.secondary">
                          Entries
                        </Typography>
                        <Typography
                          variant="h6"
                          fontWeight={600}
                          color="success.main"
                        >
                          {gate.entries}
                        </Typography>
                      </Grid>

                      <Grid item xs={6}>
                        <Typography variant="caption" color="text.secondary">
                          Exits
                        </Typography>
                        <Typography
                          variant="h6"
                          fontWeight={600}
                          color="info.main"
                        >
                          {gate.exits}
                        </Typography>
                      </Grid>

                    </Grid>

                    {/* Capacity Bar */}
                    <Box sx={{ mt: 2 }}>

                      <LinearProgress
                        variant="determinate"
                        value={capacity}
                        sx={{
                          height: 8,
                          borderRadius: 5,
                          background: "#f1f5f9",
                          "& .MuiLinearProgress-bar": {
                            backgroundColor: getProgressColor(status.color)
                          }
                        }}
                      />

                      <Box
                        sx={{
                          display: "flex",
                          justifyContent: "space-between",
                          mt: 0.5
                        }}
                      >
                        <Typography
                          variant="caption"
                          color="text.secondary"
                        >
                          Gate Capacity
                        </Typography>

                        <Typography
                          variant="caption"
                          fontWeight={600}
                        >
                          {capacity.toFixed(0)}%
                        </Typography>
                      </Box>

                    </Box>

                  </Paper>
                </Grid>

              )
            })}
          </Grid>
        )}
      </CardContent>
    </Card>
  )
}