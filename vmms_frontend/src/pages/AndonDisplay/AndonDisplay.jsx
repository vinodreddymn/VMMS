import React, { useEffect, useMemo, useRef, useState } from "react"
import { Box, Paper, Typography } from "@mui/material"
import Grid from "@mui/material/Grid"

import PeopleIcon from "@mui/icons-material/People"
import EngineeringIcon from "@mui/icons-material/Engineering"

import { io } from "socket.io-client"
import api from "../../api/axios"

import AndonHeader from "../../components/andon/AndonHeader"
import KpiCard from "../../components/andon/KpiCard"
import VisitorTransactions from "../../components/andon/VisitorTransactions"
import LabourTransactions from "../../components/andon/LabourTransactions"
import EventPopup from "../../components/andon/EventPopup"

import useAutoScroll from "../../hooks/useAutoScroll"

/* ------------------------------------------------ */
/* CONFIGURATION                                    */
/* ------------------------------------------------ */

const REFRESH_INTERVAL = {
  summary: 10000,
  transactions: 10000,
  events: 10000
}

const EVENT_DISPLAY_DURATION = 6000
const todayLocalISO = () => new Date().toLocaleDateString("en-CA")

/* ------------------------------------------------ */
/* COMPONENT                                        */
/* ------------------------------------------------ */

export default function AndonDisplay() {

  /* ---------------- TIME ---------------- */

  const [now, setNow] = useState(() => new Date())

  useEffect(() => {
    const timer = setInterval(() => setNow(new Date()), 1000)
    return () => clearInterval(timer)
  }, [])

  /* ---------------- DATA ---------------- */

  const [summary, setSummary] = useState({})
  const [visitorTx, setVisitorTx] = useState([])
  const [labourTx, setLabourTx] = useState([])

  const visitors = summary?.visitors || {}
  const labours = summary?.labours || {}

  /* ---------------- EVENTS ---------------- */

  const [eventQueue, setEventQueue] = useState([])
  const [activeEvent, setActiveEvent] = useState(null)
  const [lastEventTime, setLastEventTime] = useState(null)

  /* ---------------- SOCKET ---------------- */

  const [socketConnected, setSocketConnected] = useState(false)
  const socketRef = useRef(null)

  /* ---------------- SCROLL REFS ---------------- */

  const visitorScrollRef = useRef(null)
  const labourScrollRef = useRef(null)

  useAutoScroll(visitorScrollRef, [visitorTx.length])
  useAutoScroll(labourScrollRef, [labourTx.length])

  /* ---------------- EVENT DEDUP ---------------- */

  const seenEventIdsRef = useRef(new Set())

  /* ------------------------------------------------ */
  /* API FUNCTIONS                                    */
  /* ------------------------------------------------ */

  const fetchSummary = async () => {
    try {
      const { data } = await api.get(`/public/andon/summary?date=${todayLocalISO()}`)
      setSummary(data || {})
    } catch (err) {
      console.error("Summary fetch failed:", err)
    }
  }

  const fetchTransactions = async () => {
    try {
      const { data } = await api.get(
        `/public/andon/transactions?limit=80&date=${todayLocalISO()}`
      )
      setVisitorTx(data?.visitors || [])
      setLabourTx(data?.labours || [])
    } catch (err) {
      console.error("Transactions fetch failed:", err)
    }
  }

  const fetchEvents = async () => {
    try {

      if (!lastEventTime) return

      const since = lastEventTime
        ? `&since=${encodeURIComponent(lastEventTime)}`
        : ""

      const { data } = await api.get(
        `/public/andon/events?limit=10&date=${todayLocalISO()}${since}`
      )
      const events = data?.events || []

      const accepted = events.filter(event =>
        shouldAcceptEvent(event, lastEventTime, seenEventIdsRef)
      )

      if (accepted.length > 0) {

        const latestTime = accepted[accepted.length - 1]?.scan_time
        if (latestTime) setLastEventTime(latestTime)

        setEventQueue(prev => [...prev, ...accepted])
      }

    } catch (err) {
      console.error("Events fetch failed:", err)
    }
  }

  /* ------------------------------------------------ */
  /* INITIAL DATA LOAD                                */
  /* ------------------------------------------------ */

  useEffect(() => {
    fetchSummary()
    fetchTransactions()
    if (!lastEventTime) {
      setLastEventTime(new Date().toISOString())
    }
  }, [])

  /* ------------------------------------------------ */
  /* AUTO REFRESH                                     */
  /* ------------------------------------------------ */

  useEffect(() => {

    const summaryTimer = setInterval(fetchSummary, REFRESH_INTERVAL.summary)
    const txTimer = setInterval(fetchTransactions, REFRESH_INTERVAL.transactions)

    const eventsTimer = socketConnected
      ? null
      : setInterval(fetchEvents, REFRESH_INTERVAL.events)

    return () => {
      clearInterval(summaryTimer)
      clearInterval(txTimer)
      if (eventsTimer) clearInterval(eventsTimer)
    }

  }, [socketConnected, lastEventTime])

  /* ------------------------------------------------ */
  /* EVENT QUEUE PROCESSOR                            */
  /* ------------------------------------------------ */

  useEffect(() => {

    if (activeEvent || eventQueue.length === 0) return

    const [nextEvent, ...rest] = eventQueue

    setActiveEvent(nextEvent)
    setEventQueue(rest)

  }, [eventQueue, activeEvent])

  useEffect(() => {

    if (!activeEvent) return

    const timer = setTimeout(() => {
      setActiveEvent(null)
    }, EVENT_DISPLAY_DURATION)

    return () => clearTimeout(timer)

  }, [activeEvent])

  /* ------------------------------------------------ */
  /* SOCKET CONNECTION                                */
  /* ------------------------------------------------ */

  useEffect(() => {

    const socketEnabled =
      import.meta.env.VITE_ENABLE_SOCKET === "true" ||
      Boolean(import.meta.env.VITE_SOCKET_URL)

    if (!socketEnabled) return

    const baseUrl =
      import.meta.env.VITE_SOCKET_URL ||
      (import.meta.env.VITE_API_BASE_URL
        ? import.meta.env.VITE_API_BASE_URL.replace(/\/api\/?$/, "")
        : window.location.origin)

    const socket = io(baseUrl, {
      transports: ["websocket", "polling"],
      reconnection: true
    })

    socket.on("connect", () => setSocketConnected(true))
    socket.on("disconnect", () => setSocketConnected(false))

    socket.on("ANDON_EVENT", (event) => {

      if (!shouldAcceptEvent(event, lastEventTime, seenEventIdsRef)) return

      if (event.scan_time) setLastEventTime(event.scan_time)

      setEventQueue(prev => [...prev, event])

      fetchSummary()
      fetchTransactions()
    })

    socketRef.current = socket

    return () => socket.disconnect()

  }, [])

  /* ------------------------------------------------ */
  /* DATE FORMAT                                      */
  /* ------------------------------------------------ */

  const headerDate = now.toLocaleDateString("en-IN", {
    weekday: "short",
    day: "2-digit",
    month: "long",
    year: "numeric"
  })

  /* ------------------------------------------------ */
  /* FILE PATH RESOLUTION                             */
  /* ------------------------------------------------ */

  const fileBase = useMemo(() => {

    return (
      import.meta.env.VITE_FILE_BASE_URL ||
      (import.meta.env.VITE_API_BASE_URL
        ? import.meta.env.VITE_API_BASE_URL.replace(/\/api\/?$/, "")
        : "http://localhost:5000")
    )

  }, [])

  const resolvePhoto = (path) => {
    if (!path) return null
    if (path.startsWith("http")) return path
    return `${fileBase}/${path}`
  }

  /* ------------------------------------------------ */
  /* UI                                               */
  /* ------------------------------------------------ */

  return (

    <Box
      sx={{
        height: "100vh",
        width: "100vw",
        overflow: "hidden",
        position: "relative",
        backgroundImage: [
          "radial-gradient(1200px 700px at 15% -10%, rgba(59,130,246,0.25), transparent 60%)",
          "radial-gradient(900px 500px at 90% 15%, rgba(16,185,129,0.18), transparent 55%)",
          "radial-gradient(800px 600px at 35% 85%, rgba(244,114,182,0.12), transparent 55%)",
          "linear-gradient(180deg,#071628 0%,#0b2138 40%,#0f2a45 100%)"
        ].join(","),
        color: "#e6ecff",
        p: 2.5,
        boxSizing: "border-box",
        pointerEvents: "none",
        fontFamily: '"Rajdhani","Teko","Segoe UI",sans-serif',
        "@keyframes pulseGlow": {
          "0%": { transform: "scale(1)", opacity: 0.6 },
          "70%": { transform: "scale(1.7)", opacity: 0 },
          "100%": { transform: "scale(1.7)", opacity: 0 }
        }
      }}
    >

      {/* HEADER */}
      <AndonHeader now={now} headerDate={headerDate} />

      <Box
        sx={{
          mt: 1,
          display: "inline-flex",
          alignItems: "center",
          gap: 1,
          px: 1.5,
          py: 0.6,
          borderRadius: 999,
          background: "rgba(15,42,69,0.75)",
          border: "1px solid rgba(148,163,184,0.25)",
          boxShadow: "0 10px 24px rgba(6,15,28,0.35)",
          textTransform: "uppercase",
          letterSpacing: 1.1,
          fontSize: 12,
          fontWeight: 700,
          width: "fit-content"
        }}
      >
        <Box
          sx={{
            height: 8,
            width: 8,
            borderRadius: "50%",
            background: socketConnected ? "#22c55e" : "#f97316",
            boxShadow: socketConnected
              ? "0 0 12px rgba(34,197,94,0.8)"
              : "0 0 12px rgba(249,115,22,0.8)",
            position: "relative",
            "&::after": {
              content: '""',
              position: "absolute",
              inset: -6,
              borderRadius: "50%",
              border: `1px solid ${
                socketConnected ? "rgba(34,197,94,0.7)" : "rgba(249,115,22,0.7)"
              }`,
              animation: "pulseGlow 1.6s ease-out infinite"
            }
          }}
        />
        <Typography sx={{ fontSize: 12, fontWeight: 700 }}>
          Live Updates: {socketConnected ? "Connected" : "Polling"}
        </Typography>
      </Box>

      {/* KPI SECTION */}

      <Grid container spacing={2} sx={{ mt: 2 }}>

        {/* VISITOR PANEL */}

        <Grid size={{ xs: 12, md: 6 }}>

          <SectionPanel
            icon={<PeopleIcon sx={{ color: "#60a5fa" }} />}
            title="VISITOR STATUS"
          >

            <Grid container spacing={1.2}>

              <Grid size={2.4}>
                <KpiCard label="Total Visitors" value={visitors.total_visitors || 0} />
              </Grid>

              <Grid size={2.4}>
                <KpiCard label="Unique Visitors" value={visitors.unique_visitors || 0} />
              </Grid>

              <Grid size={2.4}>
                <KpiCard label="Repeat Visitors" value={visitors.repeat_visitors || 0} />
              </Grid>

              <Grid size={2.4}>
                <KpiCard label="Currently Inside" value={visitors.visitors_inside || 0} color="#22c55e" />
              </Grid>

              <Grid size={2.4}>
                <KpiCard label="Exited" value={visitors.visitors_exited || 0} color="#f97316" />
              </Grid>

            </Grid>

          </SectionPanel>

        </Grid>

        {/* LABOUR PANEL */}

        <Grid size={{ xs: 12, md: 6 }}>

          <SectionPanel
            icon={<EngineeringIcon sx={{ color: "#f59e0b" }} />}
            title="LABOUR STATUS"
          >

            <Grid container spacing={1.2}>

              <Grid size={2.4}>
                <KpiCard
                  label="Registered Today"
                  value={labours.registered || 0}
                />
              </Grid>

              <Grid size={2.4}>
                <KpiCard
                  label="Checked In"
                  value={labours.checked_in || 0}
                  color="#22c55e"
                />
              </Grid>

              <Grid size={2.4}>
                <KpiCard
                  label="Checked Out"
                  value={labours.checked_out || 0}
                  color="#f97316"
                />
              </Grid>

              <Grid size={2.4}>
                <KpiCard
                  label="Currently Inside"
                  value={labours.labours_inside || 0}
                  color="#3b82f6"
                />
              </Grid>

              <Grid size={2.4}>
                <KpiCard
                  label="Returned Tokens"
                  value={labours.returned_tokens || 0}
                />
              </Grid>

            </Grid>

          </SectionPanel>

        </Grid>

      </Grid>

      {/* TRANSACTION TABLES */}

      <Grid container spacing={2} sx={{ mt: 2 }}>

        <Grid size={{ xs: 12, md: 6 }}>
          <VisitorTransactions rows={visitorTx} scrollRef={visitorScrollRef} />
        </Grid>

        <Grid size={{ xs: 12, md: 6 }}>
          <LabourTransactions rows={labourTx} scrollRef={labourScrollRef} />
        </Grid>

      </Grid>

      {/* EVENT POPUP */}

      <EventPopup event={activeEvent} resolvePhoto={resolvePhoto} />

    </Box>
  )
}

/* ------------------------------------------------ */
/* REUSABLE PANEL                                   */
/* ------------------------------------------------ */

function SectionPanel({ icon, title, children }) {

  return (
    <Paper
      sx={{
        p: 2,
        minHeight: 130,
        borderRadius: 3,
        position: "relative",
        overflow: "hidden",
        background:
          "linear-gradient(135deg, rgba(255,255,255,0.10), rgba(255,255,255,0.02))",
        border: "1px solid rgba(148,163,184,0.18)",
        boxShadow: "0 18px 40px rgba(3,10,23,0.45)",
        backdropFilter: "blur(10px)",
        "&::after": {
          content: '""',
          position: "absolute",
          inset: 0,
          background:
            "linear-gradient(120deg, rgba(56,189,248,0.15), transparent 40%)",
          opacity: 0.6,
          pointerEvents: "none"
        }
      }}
    >

      <Box
        sx={{
          display: "flex",
          alignItems: "center",
          gap: 1,
          mb: 1.2,
          position: "relative",
          zIndex: 1
        }}
      >
        {icon}
        <Typography
          sx={{
            fontWeight: 800,
            letterSpacing: 1.4,
            textTransform: "uppercase",
            fontSize: 14
          }}
        >
          {title}
        </Typography>
      </Box>

      <Box sx={{ position: "relative", zIndex: 1 }}>{children}</Box>

    </Paper>
  )
}

/* ------------------------------------------------ */
/* EVENT FILTER                                     */
/* ------------------------------------------------ */

function shouldAcceptEvent(event, lastEventTime, seenEventIdsRef) {

  if (!event) return false

  const id =
    event.access_log_id ||
    `${event.person_type}-${event.person_id}-${event.scan_time}`

  if (id && seenEventIdsRef.current.has(id)) return false

  if (event.scan_time && lastEventTime) {

    const eventTs = new Date(event.scan_time).getTime()
    const lastTs = new Date(lastEventTime).getTime()

    if (!Number.isNaN(eventTs) &&
        !Number.isNaN(lastTs) &&
        eventTs <= lastTs) {
      return false
    }
  }

  if (id) seenEventIdsRef.current.add(id)

  return true
}
