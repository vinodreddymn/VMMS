import { error, log } from '../utils/logger.js';
import pkg from 'pg';

const { Pool } = pkg;
let pool;

try {
  pool = new Pool({
    connectionString: process.env.DATABASE_URL,
  });
  pool.on('error', (err) => error('Unexpected DB error', err));
} catch (err) {
  error('PostgreSQL client not configured, falling back to in-memory store');
}

// In-memory fallback stores
export const memory = {
  whitelist: [
    {
      id: 1,
      visitor_name: 'John Smith',
      visitor_id: 'V001',
      company: 'ABC Ltd',
      rfid_uid: 'RFID12345',
      registered_photo: '/photos/john.jpg',
      updated_at: new Date(Date.now() - 1000 * 60 * 60).toISOString(),
    },
    {
      id: 2,
      visitor_name: 'Jane Doe',
      visitor_id: 'V002',
      company: 'XYZ Corp',
      rfid_uid: 'RFID67890',
      registered_photo: '/photos/jane.jpg',
      updated_at: new Date(Date.now() - 1000 * 60 * 30).toISOString(),
    },
  ],
  access_logs: [],
};

export const getPool = () => pool;

export const insertAccessLog = async (logEntry) => {
  if (!pool) {
    memory.access_logs.push(logEntry);
    return;
  }
  const query = `INSERT INTO access_logs(gate_id, rfid_uid, status, visitor_name, visitor_id, company, registered_photo, live_photo, scan_time)
                 VALUES($1,$2,$3,$4,$5,$6,$7,$8,$9)`;
  const values = [
    logEntry.gate_id,
    logEntry.rfid_uid,
    logEntry.status,
    logEntry.visitor_name,
    logEntry.visitor_id,
    logEntry.company,
    logEntry.registered_photo,
    logEntry.live_photo,
    logEntry.scan_time,
  ];
  await pool.query(query, values);
};
