import db from "../config/db.js";
import * as encryption from "../utils/encryption.util.js";

// =====================================================
// LABOUR MANAGEMENT
// =====================================================

export const createLabour = async (supervisor_id, full_name, phone, aadhaar) => {
  const aadhaar_encrypted = encryption.encryptAadhaar(aadhaar);
  const aadhaar_last4 = aadhaar.slice(-4);

  const query = `
    INSERT INTO labours (supervisor_id, full_name, phone, aadhaar_encrypted, aadhaar_last4)
    VALUES ($1, $2, $3, $4, $5)
    RETURNING *;
  `;

  const result = await db.query(query, [
    supervisor_id,
    full_name,
    phone,
    aadhaar_encrypted,
    aadhaar_last4,
  ]);

  return result.rows[0];
};

export const getLabours = async (supervisor_id) => {
  const query = `
    SELECT l.*, lt.token_uid, lt.valid_until, lt.status AS token_status
    FROM labours l
    LEFT JOIN labour_tokens lt
      ON lt.labour_id = l.id AND lt.status = 'ACTIVE'
    WHERE l.supervisor_id = $1
    ORDER BY created_at DESC
  `;
  const result = await db.query(query, [supervisor_id]);
  return result.rows;
};

export const getLabourById = async (labour_id) => {
  const query = `SELECT * FROM labours WHERE id = $1`;
  const result = await db.query(query, [labour_id]);
  return result.rows[0];
};

// =====================================================
// RFID STOCK (TOKEN INVENTORY CONTROL)
// =====================================================

// Allocate next available token from stock
export const allocateAvailableToken = async () => {
  const query = `
    SELECT * FROM rfid_stock
    WHERE status = 'AVAILABLE'
    ORDER BY id
    LIMIT 1
  `;
  const result = await db.query(query);
  return result.rows[0];
};

// Get a specific token from stock
export const getStockTokenByUid = async (uid) => {
  const query = `
    SELECT * FROM rfid_stock
    WHERE uid = $1
    LIMIT 1
  `;
  const result = await db.query(query, [uid]);
  return result.rows[0];
};

// List available tokens for search
export const getAvailableTokens = async (search, limit = 20) => {
  const query = `
    SELECT uid
    FROM rfid_stock
    WHERE status = 'AVAILABLE'
      AND ($1::text IS NULL OR uid::text ILIKE $1)
    ORDER BY uid
    LIMIT $2
  `;
  const result = await db.query(query, [search, limit]);
  return result.rows;
};

// Mark token as assigned in stock
export const markTokenAssigned = async (uid) => {
  const query = `
    UPDATE rfid_stock
    SET status = 'ASSIGNED'
    WHERE uid = $1
  `;
  await db.query(query, [uid]);
};

// Release token back to available stock
export const markTokenAvailable = async (uid) => {
  const query = `
    UPDATE rfid_stock
    SET status = 'AVAILABLE'
    WHERE uid = $1
  `;
  await db.query(query, [uid]);
};

// =====================================================
// LABOUR TOKENS (LIFECYCLE)
// =====================================================

export const assignToken = async (labour_id, token_uid, assigned_date, valid_until) => {
  const query = `
    INSERT INTO labour_tokens (labour_id, token_uid, assigned_date, valid_until, status)
    VALUES ($1, $2, $3, $4, 'ACTIVE')
    RETURNING *;
  `;
  const result = await db.query(query, [
    labour_id,
    token_uid,
    assigned_date,
    valid_until,
  ]);
  return result.rows[0];
};

export const getActiveTokenByUID = async (token_uid) => {
  const query = `
    SELECT lt.*, l.supervisor_id, l.full_name
    FROM labour_tokens lt
    JOIN labours l ON lt.labour_id = l.id
    WHERE lt.token_uid = $1 AND lt.status = 'ACTIVE'
  `;
  const result = await db.query(query, [token_uid]);
  return result.rows[0];
};

export const deactivateToken = async (token_id) => {
  const query = `
    UPDATE labour_tokens
    SET status = 'INACTIVE'
    WHERE id = $1
  `;
  await db.query(query, [token_id]);
};

// Get token + manifest validation (for gate entry)
export const validateTokenForGateEntry = async (token_uid) => {
  const query = `
    SELECT lt.*, ml.manifest_id, m.signed
    FROM labour_tokens lt
    JOIN manifest_labours ml ON lt.labour_id = ml.labour_id
    JOIN labour_manifests m ON ml.manifest_id = m.id
    WHERE lt.token_uid = $1
      AND lt.status = 'ACTIVE'
      AND m.signed = TRUE
      AND (lt.valid_until IS NULL OR lt.valid_until >= NOW())
  `;
  const result = await db.query(query, [token_uid]);
  return result.rows[0];
};

// =====================================================
// LABOUR MANIFESTS
// =====================================================

export const createManifest = async (supervisor_id, manifest_date) => {
  const query = `
    INSERT INTO labour_manifests (supervisor_id, manifest_date)
    VALUES ($1, $2)
    RETURNING *;
  `;
  const result = await db.query(query, [supervisor_id, manifest_date]);
  return result.rows[0];
};

export const getManifestById = async (manifest_id) => {
  const query = `
    SELECT *
    FROM labour_manifests
    WHERE id = $1
  `;
  const result = await db.query(query, [manifest_id]);
  return result.rows[0];
};

export const addLabourToManifest = async (manifest_id, labour_id) => {
  const query = `
    INSERT INTO manifest_labours (manifest_id, labour_id)
    VALUES ($1, $2)
    RETURNING *;
  `;
  const result = await db.query(query, [manifest_id, labour_id]);
  return result.rows[0];
};

export const getManifest = async (manifest_id) => {
  const query = `
    SELECT m.*, 
           v.full_name AS supervisor_name,
           v.pass_no AS supervisor_pass_no,
           v.company_name,
           v.primary_phone,
           v.enrollment_photo_path,
           p.project_name
    FROM labour_manifests m
    JOIN visitors v ON m.supervisor_id = v.id
    LEFT JOIN projects p ON v.project_id = p.id
    WHERE m.id = $1
  `;
  const result = await db.query(query, [manifest_id]);
  return result.rows[0];
};

export const getManifestLabours = async (manifest_id) => {
  const query = `
    SELECT 
      l.id,
      l.full_name, 
      l.phone,
      l.aadhaar_encrypted,
      l.aadhaar_last4,
      l.supervisor_id,
      lt.token_uid,
      lt.assigned_date,
      CASE WHEN COUNT(CASE WHEN al.direction = 'IN' THEN 1 END) > 0 THEN TRUE ELSE FALSE END as is_checked_in,
      CASE WHEN COUNT(CASE WHEN al.direction = 'OUT' THEN 1 END) > 0 THEN TRUE ELSE FALSE END as is_checked_out,
      CASE WHEN lt.status IS NULL OR lt.status IN ('INACTIVE', 'RETURNED') THEN TRUE ELSE FALSE END as token_returned
    FROM labours l
    JOIN manifest_labours ml ON l.id = ml.labour_id
    LEFT JOIN labour_tokens lt ON lt.labour_id = l.id AND DATE(lt.assigned_date) = DATE((SELECT manifest_date FROM labour_manifests WHERE id = $1))
    LEFT JOIN access_logs al ON al.person_id = l.id AND al.person_type = 'LABOUR' AND DATE(al.scan_time) = DATE((SELECT manifest_date FROM labour_manifests WHERE id = $1))
    WHERE ml.manifest_id = $1
    GROUP BY l.id, lt.id, lt.token_uid, lt.assigned_date, lt.status, l.aadhaar_encrypted
    ORDER BY l.id
  `;
  const result = await db.query(query, [manifest_id]);
  return result.rows;
};

export const signManifest = async (manifest_id, pdf_path) => {
  const query = `
    UPDATE labour_manifests
    SET signed = TRUE,
        printed_at = NOW(),
        pdf_path = $1
    WHERE id = $2
    RETURNING *;
  `;
  const result = await db.query(query, [pdf_path, manifest_id]);
  return result.rows[0];
};

export const updateManifest = async (manifest_id, data) => {
  const query = `
    UPDATE labour_manifests
    SET signed = COALESCE($1, signed)
    WHERE id = $2
    RETURNING *;
  `;
  const result = await db.query(query, [data.signed, manifest_id]);
  return result.rows[0];
};

export const getManifestsBySupervisor = async (supervisor_id, date) => {
  if (!date) {
    const query = `
      SELECT *
      FROM labour_manifests
      WHERE supervisor_id = $1
      ORDER BY id DESC
    `;
    const result = await db.query(query, [supervisor_id]);
    return result.rows;
  }

  const query = `
    SELECT * FROM labour_manifests
    WHERE supervisor_id = $1 AND manifest_date = $2
    ORDER BY id DESC
  `;
  const result = await db.query(query, [supervisor_id, date]);
  return result.rows;
};

export const getManifestsByDate = async (date) => {
  const query = `
    SELECT 
      lm.id, 
      lm.supervisor_id,
      lm.manifest_date,
      v.full_name as supervisor_name,
      v.company_name,
      v.primary_phone as phone
    FROM labour_manifests lm
    LEFT JOIN visitors v ON lm.supervisor_id = v.id
    WHERE lm.manifest_date = $1
    ORDER BY lm.id DESC
  `;
  const result = await db.query(query, [date]);
  return result.rows;
};

// =====================================================
// NO-SHOW DETECTION
// =====================================================

export const checkNoShows = async () => {
  const query = `
    WITH latest_manifest AS (
      SELECT
        ml.labour_id,
        MAX(m.id) AS manifest_id
      FROM manifest_labours ml
      JOIN labour_manifests m ON m.id = ml.manifest_id
      WHERE m.signed = TRUE
      GROUP BY ml.labour_id
    )
    SELECT ml.labour_id, lt.token_uid, m.supervisor_id, m.printed_at
    FROM manifest_labours ml
    JOIN latest_manifest lm
      ON lm.labour_id = ml.labour_id
     AND lm.manifest_id = ml.manifest_id
    JOIN labour_tokens lt ON ml.labour_id = lt.labour_id
    JOIN labour_manifests m ON ml.manifest_id = m.id
    WHERE m.signed = TRUE
      AND lt.status = 'ACTIVE'
      AND m.printed_at < NOW() - INTERVAL '60 minutes'
      AND lt.labour_id NOT IN (
        SELECT person_id
        FROM access_logs
        WHERE person_type = 'LABOUR'
          AND direction = 'IN'
          AND scan_time > m.printed_at
      )
  `;
  const result = await db.query(query);
  return result.rows;
};

export const getActiveTokensBySupervisor = async (supervisor_id) => {
  const query = `
    SELECT lt.id, lt.token_uid, lt.labour_id, lt.assigned_date
    FROM labour_tokens lt
    JOIN labours l ON l.id = lt.labour_id
    WHERE l.supervisor_id = $1
      AND lt.status = 'ACTIVE'
  `;
  const result = await db.query(query, [supervisor_id]);
  return result.rows;
};

export const getActiveTokensByManifest = async (manifest_id) => {
  const query = `
    SELECT lt.id, lt.token_uid, lt.labour_id, lt.assigned_date
    FROM labour_tokens lt
    JOIN manifest_labours ml ON ml.labour_id = lt.labour_id
    WHERE ml.manifest_id = $1
      AND lt.status = 'ACTIVE'
  `;
  const result = await db.query(query, [manifest_id]);
  return result.rows;
};

export const getLabourAttendanceStatus = async (labour_id, from_date = null) => {
  const query = `
    WITH logs AS (
      SELECT direction, scan_time
      FROM access_logs
      WHERE person_type = 'LABOUR'
        AND person_id = $1
        AND scan_time >= COALESCE($2::timestamp, date_trunc('day', NOW()))
      ORDER BY scan_time DESC
    )
    SELECT
      EXISTS(SELECT 1 FROM logs WHERE direction = 'IN') AS has_checked_in,
      COALESCE((SELECT direction FROM logs LIMIT 1), '') AS last_direction
  `;
  const result = await db.query(query, [labour_id, from_date]);
  const row = result.rows[0] || { has_checked_in: false, last_direction: "" };
  return {
    has_checked_in: Boolean(row.has_checked_in),
    is_inside: row.last_direction === "IN",
  };
};

export const forceCheckoutLabour = async (labour_id) => {
  const query = `
    INSERT INTO access_logs (person_type, person_id, direction, scan_time, gate_id, status, manual_override)
    VALUES ('LABOUR', $1, 'OUT', NOW(), NULL, 'SUCCESS', TRUE)
    RETURNING *
  `;
  const result = await db.query(query, [labour_id]);
  return result.rows[0];
};

export const hasActiveTokensForSupervisor = async (supervisor_id) => {
  const query = `
    SELECT 1
    FROM labour_tokens lt
    JOIN labours l ON l.id = lt.labour_id
    WHERE l.supervisor_id = $1
      AND lt.status = 'ACTIVE'
    LIMIT 1
  `;
  const result = await db.query(query, [supervisor_id]);
  return result.rows.length > 0;
};
export const getAllLabours = async () => {
  const query = `
    SELECT 
      l.*,
      v.full_name AS supervisor_name,
      v.company_name,
      p.project_name
    FROM labours l
    LEFT JOIN visitors v ON l.supervisor_id = v.id
    LEFT JOIN projects p ON v.project_id = p.id
    ORDER BY l.created_at DESC
  `;
  const result = await db.query(query);
  return result.rows;
};
