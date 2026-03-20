import React, { useEffect, useState } from "react"
import {
  Card,
  CardContent,
  CardHeader,
  Box,
  CircularProgress,
  Alert,
  Typography,
  Chip,
  LinearProgress,
  Stack,
  IconButton,
  Tooltip,
  Divider
} from "@mui/material"
import RefreshIcon from "@mui/icons-material/Refresh"
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
    setError("")

    try {
      const today = new Date().toISOString().split("T")[0]

      const res = await api.get(
        `/analytics/gate-stats?from_date=${today}&to_date=${today}`
      )

      setGateStats(res?.data?.gateStats || [])
    } catch (err) {
      setError(err?.response?.data?.error || "Failed to fetch gate stats")
    } finally {
      setLoading(false)
    }
  }

  const getLoadMeta = (scans) => {
    if (scans > 200) return { label: "HIGH", color: "error", value: 100 }
    if (scans > 100) return { label: "MEDIUM", color: "warning", value: 60 }
    return { label: "LOW", color: "success", value: 30 }
  }

  const totalTraffic = (gateStats || []).reduce(
    (sum, g) => sum + Number(g.total_scans || 0),
    0
  )

  return (
    <Card
      elevation={0}
      sx={{
        borderRadius: 3,
        border: "1px solid #e5e7eb",
        height: "100%",
        background: "#ffffff"
      }}
    >
      {/* HEADER */}
      <CardHeader
        title="Gate Traffic Control"
        subheader={`Total Movement Today: ${totalTraffic}`}
        titleTypographyProps={{ fontWeight: 700 }}
        action={
          <Tooltip title="Refresh">
            <IconButton onClick={fetchGateLoad}>
              <RefreshIcon />
            </IconButton>
          </Tooltip>
        }
        sx={{ borderBottom: "1px solid #eee" }}
      />

      <CardContent>
        {error && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {error}
          </Alert>
        )}

        {loading ? (
          <Box sx={{ display: "flex", justifyContent: "center", py: 6 }}>
            <CircularProgress />
          </Box>
        ) : gateStats.length === 0 ? (
          <Alert severity="info">No gate activity today</Alert>
        ) : (
          <Box
            sx={{
              display: "flex",
              gap: 2,
              overflowX: "auto",
              pb: 1,
              "&::-webkit-scrollbar": { height: 6 },
              "&::-webkit-scrollbar-thumb": {
                background: "#cbd5f5",
                borderRadius: 10
              }
            }}
          >
            {gateStats.map((gate) => {
              const load = getLoadMeta(gate.total_scans)

              return (
                <Card
                  key={gate.id}
                  sx={{
                    minWidth: 260,
                    borderRadius: 3,
                    border: "1px solid #f1f5f9",
                    transition: "0.25s",
                    background: "#ffffff",
                    "&:hover": {
                      boxShadow: "0 10px 25px rgba(0,0,0,0.08)",
                      transform: "translateY(-3px)"
                    }
                  }}
                >
                  <CardContent>
                    {/* HEADER */}
                    <Stack spacing={0.5} mb={1}>
                      <Typography fontWeight={700}>
                        {gate.gate_name}
                      </Typography>
                      <Typography variant="caption" color="text.secondary">
                        {gate.entrance_name || "No entrance"}
                      </Typography>
                    </Stack>

                    <Divider sx={{ my: 1 }} />

                    {/* STATS */}
                    <Stack
                      direction="row"
                      justifyContent="space-between"
                      mb={1}
                    >
                      <Box>
                        <Typography variant="caption">Entries</Typography>
                        <Typography fontWeight={700} color="success.main">
                          {gate.entries}
                        </Typography>
                      </Box>

                      <Box>
                        <Typography variant="caption">Exits</Typography>
                        <Typography fontWeight={700} color="info.main">
                          {gate.exits}
                        </Typography>
                      </Box>

                      <Box>
                        <Typography variant="caption">Total</Typography>
                        <Typography fontWeight={700}>
                          {gate.total_scans}
                        </Typography>
                      </Box>
                    </Stack>


                  </CardContent>
                </Card>
              )
            })}
          </Box>
        )}
      </CardContent>
    </Card>
  )
}