import axios from "axios";
import https from "https";
import pkg from "pg";

const { Pool } = pkg;

// ---------------- CONFIG ----------------
const API_BASE = "https://localhost:5000/api/";
const SCAN_INTERVAL = 30000;
const PARALLEL_REQUESTS = 1;

// HTTPS FIX
const httpsAgent = new https.Agent({
  rejectUnauthorized: false,
});

const api = axios.create({
  baseURL: API_BASE,
  httpsAgent,
  timeout: 5000,
});

// DB
const pool = new Pool({
  user: "svr_user",
  host: "localhost",
  database: "vmms_db",
  password: "india123",
  port: 5432,
});

// ---------------- FETCH ----------------

async function getRandomGate() {
  const res = await pool.query(`
    SELECT id FROM gates
    WHERE is_active = true
    ORDER BY RANDOM()
    LIMIT 1
  `);
  return res.rows[0]?.id;
}

async function getRandomRFID() {
  const res = await pool.query(`
    SELECT uid FROM (
      SELECT uid FROM rfid_stock WHERE status = 'ASSIGNED'
      UNION
      SELECT uid FROM rfid_cards_stock WHERE status = 'ASSIGNED'
    ) t
    ORDER BY RANDOM()
    LIMIT 1
  `);
  return res.rows[0]?.uid;
}

// ---------------- SIMULATION ----------------

async function simulateScan() {
  try {
    const gateId = await getRandomGate();
    const uid = await getRandomRFID();

    if (!gateId || !uid) {
      console.log("❌ No gate or RFID available");
      return;
    }

    console.log(`➡️ Gate ${gateId} | UID ${uid}`);

    const res = await api.post("/gate/authenticate", {
      card_uid: uid,   // backend handles both cases
      gate_id: gateId,
      photo: null,
    });

    console.log(
      `✔ SUCCESS | Gate ${gateId} | UID ${uid} → ${res.data.status}`
    );
  } catch (err) {
    console.log(
      `✖ ERROR →`,
      err.response?.data || err.message
    );
  }
}

// ---------------- RUN ----------------

function runSimulator() {
  console.log("🚀 Gate Simulator Started...\n");

  setInterval(() => {
    for (let i = 0; i < PARALLEL_REQUESTS; i++) {
      simulateScan();
    }
  }, SCAN_INTERVAL);
}

runSimulator();