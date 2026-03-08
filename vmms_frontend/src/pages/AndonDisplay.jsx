import React, { useEffect, useMemo, useRef, useState } from "react"
import {
  Box,
  Typography,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  Chip,
  Stack,
} from "@mui/material"
import Grid from "@mui/material/Grid"
import PeopleIcon from "@mui/icons-material/People"
import EngineeringIcon from "@mui/icons-material/Engineering"
import LoginIcon from "@mui/icons-material/Login"
import LogoutIcon from "@mui/icons-material/Logout"
import api from "../api/axios"

const REFRESH_SUMMARY_MS = 10000
const REFRESH_TRANSACTIONS_MS = 10000
const REFRESH_EVENTS_MS = 3000

const formatTime = (value) => {
  if (!value) return "-"
  const d = new Date(value)
  if (Number.isNaN(d.getTime())) return "-"
  return d.toLocaleTimeString("en-IN", {
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
  })
}

const formatDateTime = (value) => {
  if (!value) return "-"
  const d = new Date(value)
  if (Number.isNaN(d.getTime())) return "-"
  return d.toLocaleString("en-IN")
}

const useAutoScroll = (ref, deps) => {
  useEffect(() => {
    const el = ref.current
    if (!el) return

    let rafId = null
    let lastTs = 0

    const step = (ts) => {
      if (!el) return
      if (ts - lastTs > 30) {
        if (el.scrollHeight > el.clientHeight) {
          el.scrollTop += 1
          if (el.scrollTop + el.clientHeight >= el.scrollHeight - 2) {
            el.scrollTop = 0
          }
        }
        lastTs = ts
      }
      rafId = requestAnimationFrame(step)
    }

    rafId = requestAnimationFrame(step)
    return () => {
      if (rafId) cancelAnimationFrame(rafId)
    }
  }, deps)
}

export default function AndonDisplay() {
  const [now, setNow] = useState(new Date())
  const [summary, setSummary] = useState(null)
  const [visitorTx, setVisitorTx] = useState([])
  const [labourTx, setLabourTx] = useState([])
  const [lastEventTime, setLastEventTime] = useState(null)
  const [eventQueue, setEventQueue] = useState([])
  const [activeEvent, setActiveEvent] = useState(null)

  const visitorScrollRef = useRef(null)
  const labourScrollRef = useRef(null)

  useAutoScroll(visitorScrollRef, [visitorTx.length])
  useAutoScroll(labourScrollRef, [labourTx.length])

  useEffect(() => {
    const timer = setInterval(() => setNow(new Date()), 1000)
    return () => clearInterval(timer)
  }, [])

  const fetchSummary = async () => {
    const res = await api.get("/public/andon/summary")
    setSummary(res?.data || null)
  }

  const fetchTransactions = async () => {
    const res = await api.get("/public/andon/transactions?limit=80")
    setVisitorTx(res?.data?.visitors || [])
    setLabourTx(res?.data?.labours || [])
  }

  const fetchEvents = async () => {
    const sinceParam = lastEventTime
      ? `&since=${encodeURIComponent(lastEventTime)}`
      : ""
    const res = await api.get(`/public/andon/events?limit=10${sinceParam}`)
    const events = res?.data?.events || []
    if (events.length) {
      const latest = events[events.length - 1]?.scan_time
      if (latest) setLastEventTime(latest)
      setEventQueue((prev) => [...prev, ...events])
    }
  }

  useEffect(() => {
    fetchSummary()
    fetchTransactions()
  }, [])

  useEffect(() => {
    const summaryTimer = setInterval(fetchSummary, REFRESH_SUMMARY_MS)
    const txTimer = setInterval(fetchTransactions, REFRESH_TRANSACTIONS_MS)
    return () => {
      clearInterval(summaryTimer)
      clearInterval(txTimer)
    }
  }, [])

  useEffect(() => {
    const eventTimer = setInterval(fetchEvents, REFRESH_EVENTS_MS)
    return () => clearInterval(eventTimer)
  }, [lastEventTime])

  useEffect(() => {
    if (activeEvent || eventQueue.length === 0) return
    const [next, ...rest] = eventQueue
    setActiveEvent(next)
    setEventQueue(rest)
  }, [eventQueue, activeEvent])

  useEffect(() => {
    if (!activeEvent) return
    const timer = setTimeout(() => setActiveEvent(null), 6000)
    return () => clearTimeout(timer)
  }, [activeEvent])

  const fileBase =
    import.meta.env.VITE_FILE_BASE_URL ||
    (import.meta.env.VITE_API_BASE_URL
      ? import.meta.env.VITE_API_BASE_URL.replace(/\/api\/?$/, "")
      : "http://localhost:5000")

  const resolvePhoto = (p) => {
    if (!p) return null
    if (p.startsWith("http://") || p.startsWith("https://")) return p
    return `${fileBase}/${p}`
  }

  const visitors = summary?.visitors || {}
  const labours = summary?.labours || {}

  const headerDate = now.toLocaleDateString("en-IN", {
    weekday: "short",
    day: "2-digit",
    month: "long",
    year: "numeric",
  })

  return (
    <Box
      sx={{
        height: "100vh",
        width: "100vw",
        overflow: "hidden",
        background:
          "linear-gradient(180deg, #071628 0%, #0b2138 40%, #0f2a45 100%)",
        color: "#e6ecff",
        p: 2,
        boxSizing: "border-box",
        pointerEvents: "none",
      }}
    >
      {/* BRANDING HEADER */}
      <Box
        sx={{
          display: "grid",
          gridTemplateColumns: "1fr 2fr 1fr",
          alignItems: "center",
          gap: 2,
          px: 2,
          py: 1.5,
          borderRadius: 2,
          background: "rgba(15,42,90,0.65)",
          border: "1px solid rgba(212,175,55,0.35)",
          boxShadow: "0 10px 24px rgba(0,0,0,0.35)",
        }}
      >
        <Stack direction="row" spacing={2} alignItems="center">
          <Box
            component="img"
            src="/logos/indian_navy.png"
            alt="Indian Navy"
            sx={{ height: 46 }}
          />
          <Box
            component="img"
            src="/logos/india_flag.png"
            alt="India"
            sx={{ height: 22 }}
          />
        </Stack>

        <Box sx={{ textAlign: "center" }}>
          <Typography sx={{ fontWeight: 800, letterSpacing: 1.2 }}>
            NAVAL AIRFIELD VISITOR MANAGEMENT SYSTEM
          </Typography>
          <Typography sx={{ fontSize: 12, letterSpacing: 1, color: "#9fb3d9" }}>
            INS RAJALI • INDIAN NAVY
          </Typography>
        </Box>

        <Box sx={{ textAlign: "right" }}>
          <Typography sx={{ fontSize: 12, color: "#9fb3d9" }}>
            {headerDate}
          </Typography>
          <Typography sx={{ fontSize: 20, fontWeight: 700, fontFamily: "monospace" }}>
            {formatTime(now)}
          </Typography>
        </Box>
      </Box>

      {/* BANNERS */}
      <Grid container spacing={2} sx={{ mt: 1.5 }}>
        <Grid size={{ xs: 12, md: 6 }}>
          <Paper
            sx={{
              p: 2,
              borderRadius: 2,
              background:
                "linear-gradient(135deg, rgba(37,99,235,0.18), rgba(30,64,175,0.08))",
              border: "1px solid rgba(59,130,246,0.3)",
              boxShadow: "0 10px 22px rgba(0,0,0,0.25)",
              height: 210,
            }}
          >
            <Box sx={{ display: "flex", alignItems: "center", gap: 1, mb: 1 }}>
              <PeopleIcon sx={{ color: "#60a5fa" }} />
              <Typography sx={{ fontWeight: 800, letterSpacing: 1 }}>
                VISITORS
              </Typography>
            </Box>
            <Grid container spacing={1.2}>
              <Kpi label="Total Visitors" value={visitors.total_visitors || 0} />
              <Kpi label="Unique Visitors" value={visitors.unique_visitors || 0} />
              <Kpi label="Repeat Visitors" value={visitors.repeat_visitors || 0} />
              <Kpi label="Currently Inside" value={visitors.visitors_inside || 0} color="#22c55e" />
              <Kpi label="Exited" value={visitors.visitors_exited || 0} color="#f97316" />
            </Grid>
          </Paper>
        </Grid>

        <Grid size={{ xs: 12, md: 6 }}>
          <Paper
            sx={{
              p: 2,
              borderRadius: 2,
              background:
                "linear-gradient(135deg, rgba(245,158,11,0.18), rgba(180,83,9,0.08))",
              border: "1px solid rgba(245,158,11,0.3)",
              boxShadow: "0 10px 22px rgba(0,0,0,0.25)",
              height: 210,
            }}
          >
            <Box sx={{ display: "flex", alignItems: "center", gap: 1, mb: 1 }}>
              <EngineeringIcon sx={{ color: "#f59e0b" }} />
              <Typography sx={{ fontWeight: 800, letterSpacing: 1 }}>
                LABOURS
              </Typography>
            </Box>
            <Grid container spacing={1.2}>
              <Kpi label="Registered Today" value={labours.registered || 0} />
              <Kpi label="Checked In" value={labours.checked_in || 0} color="#22c55e" />
              <Kpi label="Checked Out" value={labours.checked_out || 0} color="#f97316" />
              <Kpi label="Returned Tokens" value={labours.returned_tokens || 0} />
            </Grid>
          </Paper>
        </Grid>
      </Grid>

      {/* TABLES */}
      <Grid container spacing={2} sx={{ mt: 1.5 }}>
        <Grid size={{ xs: 12, md: 6 }}>
          <Paper
            sx={{
              p: 1.5,
              borderRadius: 2,
              background: "rgba(8,23,42,0.75)",
              border: "1px solid rgba(59,130,246,0.2)",
              height: "calc(100vh - 370px)",
              display: "flex",
              flexDirection: "column",
            }}
          >
            <Typography sx={{ fontWeight: 800, letterSpacing: 1, mb: 1 }}>
              VISITOR TRANSACTIONS (TODAY)
            </Typography>
            <Box
              ref={visitorScrollRef}
              sx={{
                flex: 1,
                overflow: "auto",
                borderRadius: 1,
                border: "1px solid rgba(148,163,184,0.15)",
                scrollbarWidth: "none",
                "&::-webkit-scrollbar": { display: "none" },
              }}
            >
              <Table stickyHeader size="small" sx={{ minWidth: 650 }}>
                <TableHead>
                  <TableRow>
                    <TableCell sx={headerCell}>Time</TableCell>
                    <TableCell sx={headerCell}>Name</TableCell>
                    <TableCell sx={headerCell}>Project</TableCell>
                    <TableCell sx={headerCell}>Gate</TableCell>
                    <TableCell sx={headerCell}>Dir</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {visitorTx.map((row) => (
                    <TableRow key={`v-${row.access_log_id}`}>
                      <TableCell sx={bodyCell}>{formatTime(row.scan_time)}</TableCell>
                      <TableCell sx={bodyCell}>{row.full_name || "-"}</TableCell>
                      <TableCell sx={bodyCell}>{row.project_name || "-"}</TableCell>
                      <TableCell sx={bodyCell}>{row.gate_name || "-"}</TableCell>
                      <TableCell sx={bodyCell}>
                        <Chip
                          label={row.direction || "-"}
                          size="small"
                          color={row.direction === "IN" ? "success" : "warning"}
                        />
                      </TableCell>
                    </TableRow>
                  ))}
                  {!visitorTx.length && (
                    <TableRow>
                      <TableCell colSpan={5} sx={emptyCell}>
                        No visitor transactions yet
                      </TableCell>
                    </TableRow>
                  )}
                </TableBody>
              </Table>
            </Box>
          </Paper>
        </Grid>

        <Grid size={{ xs: 12, md: 6 }}>
          <Paper
            sx={{
              p: 1.5,
              borderRadius: 2,
              background: "rgba(8,23,42,0.75)",
              border: "1px solid rgba(245,158,11,0.25)",
              height: "calc(100vh - 370px)",
              display: "flex",
              flexDirection: "column",
            }}
          >
            <Typography sx={{ fontWeight: 800, letterSpacing: 1, mb: 1 }}>
              LABOUR TRANSACTIONS (TODAY)
            </Typography>
            <Box
              ref={labourScrollRef}
              sx={{
                flex: 1,
                overflow: "auto",
                borderRadius: 1,
                border: "1px solid rgba(148,163,184,0.15)",
                scrollbarWidth: "none",
                "&::-webkit-scrollbar": { display: "none" },
              }}
            >
              <Table stickyHeader size="small" sx={{ minWidth: 650 }}>
                <TableHead>
                  <TableRow>
                    <TableCell sx={headerCell}>Time</TableCell>
                    <TableCell sx={headerCell}>Name</TableCell>
                    <TableCell sx={headerCell}>Supervisor</TableCell>
                    <TableCell sx={headerCell}>Gate</TableCell>
                    <TableCell sx={headerCell}>Dir</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {labourTx.map((row) => (
                    <TableRow key={`l-${row.access_log_id}`}>
                      <TableCell sx={bodyCell}>{formatTime(row.scan_time)}</TableCell>
                      <TableCell sx={bodyCell}>{row.full_name || "-"}</TableCell>
                      <TableCell sx={bodyCell}>{row.supervisor_name || "-"}</TableCell>
                      <TableCell sx={bodyCell}>{row.gate_name || "-"}</TableCell>
                      <TableCell sx={bodyCell}>
                        <Chip
                          label={row.direction || "-"}
                          size="small"
                          color={row.direction === "IN" ? "success" : "warning"}
                        />
                      </TableCell>
                    </TableRow>
                  ))}
                  {!labourTx.length && (
                    <TableRow>
                      <TableCell colSpan={5} sx={emptyCell}>
                        No labour transactions yet
                      </TableCell>
                    </TableRow>
                  )}
                </TableBody>
              </Table>
            </Box>
          </Paper>
        </Grid>
      </Grid>

      {/* EVENT POPUP */}
      {activeEvent && (
        <EventPopup event={activeEvent} resolvePhoto={resolvePhoto} />
      )}
    </Box>
  )
}

const headerCell = {
  background: "rgba(15,42,90,0.9)",
  color: "#e6ecff",
  fontWeight: 700,
  borderBottom: "1px solid rgba(148,163,184,0.2)",
  position: "sticky",
  top: 0,
  zIndex: 1,
}

const bodyCell = {
  color: "#e6ecff",
  borderBottom: "1px solid rgba(148,163,184,0.12)",
  fontSize: 12,
}

const emptyCell = {
  color: "rgba(226,232,240,0.7)",
  textAlign: "center",
  py: 6,
}

const Kpi = ({ label, value, color }) => (
  <Grid size={{ xs: 6, sm: 4, md: 4 }}>
    <Box
      sx={{
        p: 1.2,
        borderRadius: 1.5,
        background: "rgba(15,23,42,0.6)",
        border: "1px solid rgba(148,163,184,0.2)",
        minHeight: 62,
      }}
    >
      <Typography sx={{ fontSize: 11, color: "rgba(226,232,240,0.8)" }}>
        {label}
      </Typography>
      <Typography sx={{ fontSize: 20, fontWeight: 800, color: color || "#e6ecff" }}>
        {value}
      </Typography>
    </Box>
  </Grid>
)

const EventPopup = ({ event, resolvePhoto }) => {
  const isEntry = event.direction === "IN"
  const bannerColor = isEntry ? "#16a34a" : "#dc2626"
  const dbPhoto = resolvePhoto(event.enrollment_photo_path)
  const livePhoto = resolvePhoto(event.live_photo_path)

  return (
    <Box
      sx={{
        position: "fixed",
        inset: 0,
        background: "rgba(3,7,18,0.78)",
        backdropFilter: "blur(6px)",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        zIndex: 2000,
      }}
    >
      <Paper
        sx={{
          width: "80%",
          maxWidth: 1200,
          borderRadius: 3,
          overflow: "hidden",
          border: `2px solid ${bannerColor}`,
          boxShadow: "0 20px 60px rgba(0,0,0,0.5)",
        }}
      >
        <Box
          sx={{
            background: bannerColor,
            color: "#ffffff",
            px: 3,
            py: 1.5,
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
          }}
        >
          <Typography sx={{ fontSize: 24, fontWeight: 800, letterSpacing: 1 }}>
            {event.person_type} {isEntry ? "ENTRY" : "EXIT"}
          </Typography>
          <Typography sx={{ fontSize: 14 }}>{formatDateTime(event.scan_time)}</Typography>
        </Box>

        <Grid container spacing={0}>
          <Grid size={{ xs: 12, md: 5 }} sx={{ p: 3, background: "#0b1d2e" }}>
            <Typography sx={{ fontWeight: 700, mb: 1 }}>DB Photo</Typography>
            <Box
              component="img"
              src={dbPhoto || "/logos/india_flag.png"}
              alt="DB"
              sx={{
                width: "100%",
                height: 240,
                objectFit: "cover",
                borderRadius: 2,
                border: "1px solid rgba(255,255,255,0.15)",
                background: "#0f172a",
              }}
            />
            <Typography sx={{ fontWeight: 700, mt: 2, mb: 1 }}>Captured Photo</Typography>
            <Box
              component="img"
              src={livePhoto || "/logos/india_flag.png"}
              alt="Captured"
              sx={{
                width: "100%",
                height: 240,
                objectFit: "cover",
                borderRadius: 2,
                border: "1px solid rgba(255,255,255,0.15)",
                background: "#0f172a",
              }}
            />
          </Grid>

          <Grid size={{ xs: 12, md: 7 }} sx={{ p: 3, background: "#f8fafc" }}>
            <Typography sx={{ fontSize: 26, fontWeight: 800, mb: 1 }}>
              {event.full_name || "UNKNOWN"}
            </Typography>
            <Typography sx={{ color: "#475569", mb: 2 }}>
              {event.project_name || "PROJECT -"} • {event.gate_name || "GATE -"}
            </Typography>

            <Grid container spacing={1.5}>
              <Detail label="Type" value={event.person_type} />
              <Detail label="Direction" value={event.direction} />
              <Detail label="Phone" value={event.phone || "-"} />
              <Detail label="Pass No" value={event.pass_no || "-"} />
              <Detail label="Aadhaar" value={event.aadhaar_last4 || "-"} />
              <Detail label="Supervisor" value={event.supervisor_name || "-"} />
              <Detail label="Token UID" value={event.token_uid || "-"} />
              <Detail label="Department" value={event.department_name || "-"} />
              <Detail label="Host" value={event.host_name || "-"} />
            </Grid>
          </Grid>
        </Grid>
      </Paper>
    </Box>
  )
}

const Detail = ({ label, value }) => (
  <Grid size={6}>
    <Box
      sx={{
        p: 1.2,
        borderRadius: 1.5,
        background: "#ffffff",
        border: "1px solid rgba(15,23,42,0.08)",
      }}
    >
      <Typography sx={{ fontSize: 11, color: "#64748b" }}>{label}</Typography>
      <Typography sx={{ fontWeight: 700 }}>{value}</Typography>
    </Box>
  </Grid>
)
