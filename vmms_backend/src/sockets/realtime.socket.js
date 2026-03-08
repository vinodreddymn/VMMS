import { Server } from "socket.io"

let io = null

/* ================= LIVE DASHBOARD STATS ================= */

let liveStats = {
  totalInside: 0,
  gateLoad: {},
  lastEntries: [],
}

/* ================= INITIALIZE SOCKET ================= */

export default function initSocket(server) {

  if (io) return io

  io = new Server(server, {
    cors: {
      origin: "*",
    },
  })

  io.on("connection", (socket) => {

    console.log("Andon/Dashboard Connected:", socket.id)

    /* SEND INITIAL STATE */

    socket.emit("INITIAL_STATS", liveStats)

    socket.on("disconnect", () => {
      console.log("Dashboard Disconnected:", socket.id)
    })

  })

  return io
}

/* ================= EMIT REALTIME EVENT ================= */

export const emitEvent = (event, data) => {

  if (!io) return

  io.emit(event, data)

}

/* ================= UPDATE DASHBOARD STATS ================= */

export const updateStats = (updateFn) => {

  updateFn(liveStats)

  if (io) {
    io.emit("STATS_UPDATE", liveStats)
  }

}

/* ================= ACCESS EVENT (IMPORTANT FOR ANDON) ================= */

export const emitAccessEvent = (eventData) => {

  if (!io) return

  io.emit("ANDON_EVENT", eventData)

}
