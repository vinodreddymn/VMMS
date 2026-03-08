import React, { useEffect, useMemo, useRef, useState, useCallback } from "react"
import { Box, Typography, Paper } from "@mui/material"
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
/* CONFIG                                           */
/* ------------------------------------------------ */

const REFRESH = {
  SUMMARY: 10000,
  TX: 10000,
  EVENTS: 10000
}

const EVENT_POPUP_DURATION = 6000
const todayISO = () => new Date().toLocaleDateString("en-CA")

/* ------------------------------------------------ */
/* MAIN COMPONENT                                   */
/* ------------------------------------------------ */

export default function AndonDisplay() {

  /* ---------------- CLOCK ---------------- */

  const [now, setNow] = useState(new Date())

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

  const seenEvents = useRef(new Set())

  /* ---------------- SOCKET ---------------- */

  const [socketConnected, setSocketConnected] = useState(false)
  const socketRef = useRef(null)

  /* ---------------- AUTO SCROLL ---------------- */

  const visitorScrollRef = useRef(null)
  const labourScrollRef = useRef(null)

  useAutoScroll(visitorScrollRef, [visitorTx.length])
  useAutoScroll(labourScrollRef, [labourTx.length])

  /* ------------------------------------------------ */
  /* API CALLS                                        */
  /* ------------------------------------------------ */

  const fetchSummary = useCallback(async () => {
    try {
      const { data } = await api.get(`/public/andon/summary?date=${todayISO()}`)
      setSummary(data || {})
    } catch (err) {
      console.error("Summary error:", err)
    }
  }, [])

  const fetchTransactions = useCallback(async () => {
    try {
      const { data } = await api.get(`/public/andon/transactions?limit=80&date=${todayISO()}`)
      setVisitorTx(data?.visitors || [])
      setLabourTx(data?.labours || [])
    } catch (err) {
      console.error("Transaction error:", err)
    }
  }, [])

  const fetchEvents = useCallback(async () => {

    if (!lastEventTime) return

    try {

      const { data } = await api.get(
        `/public/andon/events?date=${todayISO()}&since=${encodeURIComponent(lastEventTime)}`
      )

      const events = data?.events || []

      const accepted = events.filter(event =>
        acceptEvent(event, lastEventTime, seenEvents)
      )

      if (!accepted.length) return

      const latest = accepted[accepted.length - 1]?.scan_time
      if (latest) setLastEventTime(latest)

      setEventQueue(prev => [...prev, ...accepted])

    } catch (err) {
      console.error("Events error:", err)
    }

  }, [lastEventTime])

  /* ------------------------------------------------ */
  /* INITIAL LOAD                                      */
  /* ------------------------------------------------ */

  useEffect(() => {
    fetchSummary()
    fetchTransactions()

    if (!lastEventTime) {
      setLastEventTime(new Date().toISOString())
    }
  }, [])

  /* ------------------------------------------------ */
  /* AUTO REFRESH                                      */
  /* ------------------------------------------------ */

  useEffect(() => {

    const summaryTimer = setInterval(fetchSummary, REFRESH.SUMMARY)
    const txTimer = setInterval(fetchTransactions, REFRESH.TX)

    const eventTimer = socketConnected
      ? null
      : setInterval(fetchEvents, REFRESH.EVENTS)

    return () => {
      clearInterval(summaryTimer)
      clearInterval(txTimer)
      if (eventTimer) clearInterval(eventTimer)
    }

  }, [socketConnected, fetchSummary, fetchTransactions, fetchEvents])

  /* ------------------------------------------------ */
  /* EVENT QUEUE                                       */
  /* ------------------------------------------------ */

  useEffect(() => {

    if (activeEvent || eventQueue.length === 0) return

    const [next, ...rest] = eventQueue

    setActiveEvent(next)
    setEventQueue(rest)

  }, [eventQueue, activeEvent])

  useEffect(() => {

    if (!activeEvent) return

    const timer = setTimeout(() => setActiveEvent(null), EVENT_POPUP_DURATION)

    return () => clearTimeout(timer)

  }, [activeEvent])

  /* ------------------------------------------------ */
  /* SOCKET                                            */
  /* ------------------------------------------------ */

  useEffect(() => {

    const enabled =
      import.meta.env.VITE_ENABLE_SOCKET === "true" ||
      Boolean(import.meta.env.VITE_SOCKET_URL)

    if (!enabled) return

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

    socket.on("ANDON_EVENT", event => {

      if (!acceptEvent(event, lastEventTime, seenEvents)) return

      if (event.scan_time) setLastEventTime(event.scan_time)

      setEventQueue(prev => [...prev, event])

      fetchSummary()
      fetchTransactions()

    })

    socketRef.current = socket

    return () => socket.disconnect()

  }, [lastEventTime, fetchSummary, fetchTransactions])

  /* ------------------------------------------------ */
  /* DATE FORMAT                                       */
  /* ------------------------------------------------ */

  const headerDate = now.toLocaleDateString("en-IN", {
    weekday: "short",
    day: "2-digit",
    month: "long",
    year: "numeric"
  })

  /* ------------------------------------------------ */
  /* FILE PATH                                         */
  /* ------------------------------------------------ */

  const fileBase = useMemo(() => {

    return (
      import.meta.env.VITE_FILE_BASE_URL ||
      (import.meta.env.VITE_API_BASE_URL
        ? import.meta.env.VITE_API_BASE_URL.replace(/\/api\/?$/, "")
        : "http://localhost:5000")
    )

  }, [])

  const resolvePhoto = path => {
    if (!path) return null
    if (path.startsWith("http")) return path
    return `${fileBase}/${path}`
  }

  /* ------------------------------------------------ */
  /* UI                                                */
  /* ------------------------------------------------ */

  return (

    <Box sx={styles.root}>

      <AndonHeader now={now} headerDate={headerDate} />

      

      {/* KPI SECTION */}

      <Grid container spacing={2} sx={{ mt: 2 }}>

        <Grid size={{ xs: 12, md: 6 }}>
          <SectionPanel icon={<PeopleIcon sx={{ color: "#60a5fa" }} />} title="VISITOR STATUS">

            <Grid container spacing={1.2}>

              <Grid size={2.4}><KpiCard label="Total Visitors" value={visitors.total_visitors || 0} /></Grid>
              <Grid size={2.4}><KpiCard label="Unique Visitors" value={visitors.unique_visitors || 0} /></Grid>
              <Grid size={2.4}><KpiCard label="Repeat Visitors" value={visitors.repeat_visitors || 0} /></Grid>
              <Grid size={2.4}><KpiCard label="Inside" value={visitors.visitors_inside || 0} color="#22c55e" /></Grid>
              <Grid size={2.4}><KpiCard label="Exited" value={visitors.visitors_exited || 0} color="#f97316" /></Grid>

            </Grid>

          </SectionPanel>
        </Grid>

        <Grid size={{ xs: 12, md: 6 }}>
          <SectionPanel icon={<EngineeringIcon sx={{ color: "#f59e0b" }} />} title="LABOUR STATUS">

            <Grid container spacing={1.2}>

              <Grid size={2.4}><KpiCard label="Registered" value={labours.registered || 0} /></Grid>
              <Grid size={2.4}><KpiCard label="Checked In" value={labours.checked_in || 0} color="#22c55e" /></Grid>
              <Grid size={2.4}><KpiCard label="Checked Out" value={labours.checked_out || 0} color="#f97316" /></Grid>
              <Grid size={2.4}><KpiCard label="Inside" value={labours.labours_inside || 0} color="#3b82f6" /></Grid>
              <Grid size={2.4}><KpiCard label="Returned Tokens" value={labours.returned_tokens || 0} /></Grid>

            </Grid>

          </SectionPanel>
        </Grid>

      </Grid>

      {/* TRANSACTIONS */}

      <Grid container spacing={2} sx={{ mt: 2 }}>

        <Grid size={{ xs: 12, md: 6 }}>
          <VisitorTransactions rows={visitorTx} scrollRef={visitorScrollRef} />
        </Grid>

        <Grid size={{ xs: 12, md: 6 }}>
          <LabourTransactions rows={labourTx} scrollRef={labourScrollRef} />
        </Grid>

      </Grid>

      <EventPopup event={activeEvent} resolvePhoto={resolvePhoto} />

    </Box>
  )
}



/* ------------------------------------------------ */
/* SECTION PANEL                                     */
/* ------------------------------------------------ */

function SectionPanel({ icon, title, children }) {

  return (
    <Paper sx={styles.panel}>

      <Box sx={styles.panelHeader}>
        {icon}
        <Typography sx={styles.panelTitle}>{title}</Typography>
      </Box>

      {children}

    </Paper>
  )
}

/* ------------------------------------------------ */
/* EVENT FILTER                                      */
/* ------------------------------------------------ */

function acceptEvent(event, lastEventTime, seenEvents) {

  if (!event) return false

  const id =
    event.access_log_id ||
    `${event.person_type}-${event.person_id}-${event.scan_time}`

  if (id && seenEvents.current.has(id)) return false

  if (event.scan_time && lastEventTime) {

    const eventTs = new Date(event.scan_time).getTime()
    const lastTs = new Date(lastEventTime).getTime()

    if (!Number.isNaN(eventTs) && !Number.isNaN(lastTs) && eventTs <= lastTs) {
      return false
    }
  }

  if (id) seenEvents.current.add(id)

  return true
}

/* ------------------------------------------------ */
/* STYLES                                            */
/* ------------------------------------------------ */

const styles = {

  root: {
    height: "100vh",
    width: "100vw",
    overflow: "hidden",
    p: 2.5,
    backgroundImage: [
      "radial-gradient(1200px 700px at 15% -10%, rgba(59,130,246,0.25), transparent 60%)",
      "radial-gradient(900px 500px at 90% 15%, rgba(16,185,129,0.18), transparent 55%)",
      "linear-gradient(180deg,#071628 0%,#0b2138 40%,#0f2a45 100%)"
    ].join(","),
    color: "#e6ecff",
    fontFamily: '"Rajdhani","Teko","Segoe UI",sans-serif'
  },

  panel: {
    p: 2,
    borderRadius: 3,
    background: "linear-gradient(135deg, rgba(255,255,255,0.1), rgba(255,255,255,0.02))",
    border: "1px solid rgba(148,163,184,0.18)",
    backdropFilter: "blur(10px)",
    boxShadow: "0 18px 40px rgba(3,10,23,0.45)"
  },

  panelHeader: {
    display: "flex",
    alignItems: "center",
    gap: 1,
    mb: 1.2
  },

  panelTitle: {
    fontWeight: 800,
    letterSpacing: 1.4,
    textTransform: "uppercase",
    fontSize: 14
  },



  dot: {
    height: 8,
    width: 8,
    borderRadius: "50%"
  }
}