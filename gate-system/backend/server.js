import express from "express";
import http from "http";
import { WebSocketServer } from "ws";

const app = express();
app.use(express.json());

// simple CORS for local devices
app.use((_, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  next();
});

// WebSocket for display panels
const server = http.createServer(app);
const wss = new WebSocketServer({ server, path: "/display" });
const clients = new Set();

wss.on("connection", (ws) => {
  clients.add(ws);
  ws.on("close", () => clients.delete(ws));
});

const broadcastDisplay = (payload) => {
  const data = JSON.stringify(payload);
  for (const client of clients) {
    if (client.readyState === 1) client.send(data);
  }
};

// Health
app.get("/health", (_req, res) => {
  res.json({ ok: true, uptime: process.uptime() });
});

// Local display push
app.post("/api/local/display", (req, res) => {
  broadcastDisplay(req.body || {});
  res.json({ ok: true, delivered: clients.size });
});

const PORT = process.env.PORT || 3200;
server.listen(PORT, () => {
  console.log(`Gate local backend running on http://127.0.0.1:${PORT}`);
});
