import db from "../config/db.js";

/* =====================================================
   GATE MANAGEMENT
===================================================== */

export const getGate = async (gate_id) => {
  const query = `
    SELECT g.*, e.entrance_name
    FROM gates g
    LEFT JOIN entrances e ON g.entrance_id = e.id
    WHERE g.id = $1
  `;

  const { rows } = await db.query(query, [gate_id]);
  return rows[0];
};

export const getGateByIP = async (ip_address) => {
  const query = `
    SELECT g.*, e.entrance_name
    FROM gates g
    LEFT JOIN entrances e ON g.entrance_id = e.id
    WHERE g.ip_address = $1
  `;

  const { rows } = await db.query(query, [ip_address]);
  return rows[0];
};

export const getAllGates = async () => {
  const query = `
    SELECT g.*, e.entrance_name
    FROM gates g
    LEFT JOIN entrances e ON g.entrance_id = e.id
    WHERE g.is_active = TRUE
    ORDER BY g.gate_name
  `;

  const { rows } = await db.query(query);
  return rows;
};


/* =====================================================
   ACCESS LOG MANAGEMENT
===================================================== */

export const getLastLog = async (person_type, person_id) => {
  const query = `
    SELECT direction
    FROM access_logs
    WHERE person_type = $1
      AND person_id = $2
    ORDER BY scan_time DESC
    LIMIT 1
  `;

  const { rows } = await db.query(query, [person_type, person_id]);
  return rows[0];
};

export const insertAccessLog = async (
  person_type,
  person_id,
  gate_id,
  direction,
  status,
  error_code,
  live_photo_path,
  manual_override = false
) => {
  const query = `
    INSERT INTO access_logs
      (person_type, person_id, gate_id, direction,
       scan_time, status, error_code, live_photo_path, manual_override)
    VALUES
      ($1, $2, $3, $4, NOW(), $5, $6, $7, $8)
    RETURNING *
  `;

  const { rows } = await db.query(query, [
    person_type,
    person_id,
    gate_id,
    direction,
    status,
    error_code,
    live_photo_path,
    manual_override,
  ]);

  return rows[0];
};

export const getAccessLogs = async (filters = {}) => {

  let query = `SELECT * FROM access_logs WHERE 1=1`;
  const values = [];
  let index = 1;

  if (filters.person_id) {
    query += ` AND person_id = $${index++}`;
    values.push(filters.person_id);
  }

  if (filters.gate_id) {
    query += ` AND gate_id = $${index++}`;
    values.push(filters.gate_id);
  }

  if (filters.from_date) {
    query += ` AND scan_time >= $${index++}`;
    values.push(filters.from_date);
  }

  if (filters.to_date) {
    query += ` AND scan_time <= $${index++}`;
    values.push(filters.to_date);
  }

  query += ` ORDER BY scan_time DESC LIMIT 1000`;

  const { rows } = await db.query(query, values);
  return rows;
};


/* =====================================================
   GATE HEALTH MONITORING
===================================================== */

export const updateGateHealth = async (
  gate_id,
  is_online,
  cpu_usage,
  memory_usage,
  storage_usage,
  camera_status,
  rfid_status,
  biometric_status
) => {

  const query = `
    INSERT INTO gate_health (
      gate_id,
      last_heartbeat,
      is_online,
      cpu_usage,
      memory_usage,
      storage_usage,
      camera_status,
      rfid_status,
      biometric_status,
      updated_at
    )
    VALUES ($1, NOW(), $2, $3, $4, $5, $6, $7, $8, NOW())

    ON CONFLICT (gate_id)
    DO UPDATE SET
      last_heartbeat = NOW(),
      is_online = $2,
      cpu_usage = $3,
      memory_usage = $4,
      storage_usage = $5,
      camera_status = $6,
      rfid_status = $7,
      biometric_status = $8,
      updated_at = NOW()

    RETURNING *
  `;

  const { rows } = await db.query(query, [
    gate_id,
    is_online,
    cpu_usage,
    memory_usage,
    storage_usage,
    camera_status,
    rfid_status,
    biometric_status,
  ]);

  return rows[0];
};

export const logGateHealth = async (
  gate_id,
  cpu_usage,
  memory_usage,
  storage_usage,
  camera_status,
  rfid_status,
  biometric_status
) => {

  const query = `
    INSERT INTO gate_health_logs
      (gate_id, cpu_usage, memory_usage, storage_usage,
       camera_status, rfid_status, biometric_status)
    VALUES ($1,$2,$3,$4,$5,$6,$7)
    RETURNING *
  `;

  const { rows } = await db.query(query, [
    gate_id,
    cpu_usage,
    memory_usage,
    storage_usage,
    camera_status,
    rfid_status,
    biometric_status,
  ]);

  return rows[0];
};

export const getGateHealth = async (gate_id) => {
  const query = `SELECT * FROM gate_health WHERE gate_id = $1`;

  const { rows } = await db.query(query, [gate_id]);
  return rows[0];
};

export const getGateHealthLogs = async (gate_id, limit = 100) => {
  const query = `
    SELECT *
    FROM gate_health_logs
    WHERE gate_id = $1
    ORDER BY heartbeat_time DESC
    LIMIT $2
  `;

  const { rows } = await db.query(query, [gate_id, limit]);
  return rows;
};


/* =====================================================
   PERSON SEARCH (VISITOR / LABOUR)
===================================================== */

export const searchPerson = async (query) => {

  /* ---------- VISITOR SEARCH ---------- */

  const visitorQuery = `
    SELECT
      v.id,
      v.pass_no,
      v.full_name,
      v.primary_phone,
      v.aadhaar_last4,
      v.company_name,
      h.host_name,
      'VISITOR' AS person_type
    FROM visitors v
    LEFT JOIN hosts h ON v.host_id = h.id
    WHERE
         v.pass_no = $1
      OR v.primary_phone = $1
      OR v.aadhaar_last4 = $1
      OR v.full_name ILIKE '%' || $1 || '%'
    LIMIT 1
  `;

  const visitor = await db.query(visitorQuery, [query]);

  if (visitor.rows.length) {
    return visitor.rows[0];
  }


  /* ---------- LABOUR SEARCH ---------- */

  const labourQuery = `
    SELECT
      l.id,
      l.full_name,
      l.token_uid,
      l.supervisor_name,
      'LABOUR' AS person_type
    FROM labours l
    WHERE
         l.token_uid = $1
      OR l.full_name ILIKE '%' || $1 || '%'
    LIMIT 1
  `;

  const labour = await db.query(labourQuery, [query]);

  if (labour.rows.length) {
    return labour.rows[0];
  }

  return null;
};