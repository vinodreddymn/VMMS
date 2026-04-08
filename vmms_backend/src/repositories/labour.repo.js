import db from "../config/db.js";
import * as encryption from "../utils/encryption.util.js";

// =====================================================
// LABOUR MANAGEMENT
// =====================================================

export const createLabour = async (
  supervisor_id,
  full_name,
  phone,
  aadhaar,
  gender = null,
  age = null
) => {
  const aadhaar_encrypted = encryption.encryptAadhaar(aadhaar);
  const aadhaar_last4 = aadhaar.slice(-4);

  const query = `
    INSERT INTO labours (supervisor_id, full_name, phone, aadhaar_encrypted, aadhaar_last4, gender, age)
    VALUES ($1, $2, $3, $4, $5, $6, $7)
    RETURNING *;
  `;

  const result = await db.query(query, [
    supervisor_id,
    full_name,
    phone,
    aadhaar_encrypted,
    aadhaar_last4,
    gender,
    age,
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
    WITH inserted AS (
      INSERT INTO labour_manifests (supervisor_id, manifest_date)
      VALUES ($1, $2)
      RETURNING *
    )
    SELECT i.*,
           (
             SELECT COUNT(*)
             FROM labour_manifests lm
             WHERE lm.manifest_date = i.manifest_date
               AND lm.id <= i.id
           ) AS daily_sequence
    FROM inserted i;
  `;
  const result = await db.query(query, [supervisor_id, manifest_date]);
  return result.rows[0];
};

export const getManifestById = async (manifest_id) => {
  const query = `
    SELECT lm.*,
           (
             SELECT COUNT(*)
             FROM labour_manifests x
             WHERE x.manifest_date = lm.manifest_date
               AND x.id <= lm.id
           ) AS daily_sequence
    FROM labour_manifests lm
    WHERE lm.id = $1
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
           (
             SELECT COUNT(*)
             FROM labour_manifests lm
             WHERE lm.manifest_date = m.manifest_date
               AND lm.id <= m.id
           ) AS daily_sequence,
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
        l.gender,
        l.age,
        l.supervisor_id,
        lt.token_uid,
        lt.assigned_date,
        ml.photo_path AS registered_photo_path,
        CASE WHEN COUNT(CASE WHEN al.direction = 'IN' THEN 1 END) > 0 THEN TRUE ELSE FALSE END as is_checked_in,
        CASE WHEN COUNT(CASE WHEN al.direction = 'OUT' THEN 1 END) > 0 THEN TRUE ELSE FALSE END as is_checked_out,
        CASE WHEN lt.status IS NULL OR lt.status IN ('INACTIVE', 'RETURNED') THEN TRUE ELSE FALSE END as token_returned,
        MIN(CASE WHEN al.direction = 'IN' THEN al.scan_time END) AS first_check_in,
        MAX(CASE WHEN al.direction = 'OUT' THEN al.scan_time END) AS last_check_out,
        MIN(CASE WHEN al.direction = 'IN' THEN al.live_photo_path END) AS live_photo_path
      FROM labours l
      JOIN manifest_labours ml ON l.id = ml.labour_id
      LEFT JOIN labour_tokens lt ON lt.labour_id = l.id AND DATE(lt.assigned_date) = DATE((SELECT manifest_date FROM labour_manifests WHERE id = $1))
      LEFT JOIN access_logs al ON al.person_id = l.id AND al.person_type = 'LABOUR' AND DATE(al.scan_time) = DATE((SELECT manifest_date FROM labour_manifests WHERE id = $1))
      WHERE ml.manifest_id = $1
      GROUP BY l.id, lt.id, lt.token_uid, lt.assigned_date, lt.status, l.aadhaar_encrypted, ml.photo_path
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
    RETURNING *,
      (
        SELECT COUNT(*)
        FROM labour_manifests lm
        WHERE lm.manifest_date = labour_manifests.manifest_date
          AND lm.id <= labour_manifests.id
      ) AS daily_sequence;
  `;
  const result = await db.query(query, [pdf_path, manifest_id]);
  return result.rows[0];
};

export const updateManifest = async (manifest_id, data) => {
  const query = `
    UPDATE labour_manifests
    SET signed = COALESCE($1, signed)
    WHERE id = $2
    RETURNING *,
      (
        SELECT COUNT(*)
        FROM labour_manifests lm
        WHERE lm.manifest_date = labour_manifests.manifest_date
          AND lm.id <= labour_manifests.id
      ) AS daily_sequence;
  `;
  const result = await db.query(query, [data.signed, manifest_id]);
  return result.rows[0];
};

export const getManifestsBySupervisor = async (supervisor_id, date = null) => {
  try {
    let query = `
      SELECT 
        m.id,
        m.supervisor_id,
        m.manifest_date,
        m.signed,
        m.printed_at,
        m.pdf_path,
        (
          SELECT COUNT(*)
          FROM labour_manifests lm
          WHERE lm.manifest_date = m.manifest_date
            AND lm.id <= m.id
        ) AS daily_sequence,

        -- ???? LABOUR COUNT
        COUNT(ml.labour_id) AS labour_count

      FROM labour_manifests m

      LEFT JOIN manifest_labours ml 
        ON ml.manifest_id = m.id

      WHERE m.supervisor_id = $1
    `;

    const params = [supervisor_id];

    // 🔹 DATE FILTER (SAFE FOR TIMESTAMP)
    if (date) {
      query += ` AND DATE(m.manifest_date) = $2`;
      params.push(date);
    }

    query += `
      GROUP BY 
        m.id,
        m.supervisor_id,
        m.manifest_date,
        m.signed,
        m.printed_at,
        m.pdf_path

      ORDER BY m.manifest_date DESC;
    `;

    const result = await db.query(query, params);

    return result.rows;

  } catch (error) {
    console.error("Error fetching manifests:", error);
    throw error;
  }
};

export const getManifestsByDate = async (date) => {
  const query = `
    SELECT 
      lm.id, 
      lm.supervisor_id,
      lm.manifest_date,
      COALESCE(lm.printed_at, lm.manifest_date::timestamp) AS created_at,
      (
        SELECT COUNT(*)
        FROM labour_manifests m2
        WHERE m2.manifest_date = lm.manifest_date
          AND m2.id <= lm.id
      ) AS daily_sequence,
      v.full_name as supervisor_name,
      v.company_name,
      v.primary_phone as phone,
      p.project_name AS project_name,
      p.id AS project_id
    FROM labour_manifests lm
    LEFT JOIN visitors v ON lm.supervisor_id = v.id
    LEFT JOIN projects p ON v.project_id = p.id
    WHERE lm.manifest_date = $1
      ORDER BY COALESCE(lm.printed_at, lm.manifest_date::timestamp) DESC, lm.id DESC
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
export const checkAlerts = async (req, res) => {
  try {
    // ===============================
    // 1. NO-SHOW ALERTS
    // ===============================
    const noShows = await labourRepo.getNoShowLabours();

    for (const row of noShows) {
      const labour = await labourRepo.getLabourById(row.labour_id);
      const supervisor = await visitorRepo.findById(row.supervisor_id);

      if (!supervisor?.host_id) continue;

      const hostRes = await db.query(
        `SELECT host_name, phone FROM hosts WHERE id = $1 AND is_active = true`,
        [supervisor.host_id]
      );

      const host = hostRes.rows[0];
      if (!host?.phone) continue;

      await smsService.sendNoShowAlertSMS(
        host.phone,
        labour.full_name
      );
    }

    // ===============================
    // 2. TOKEN NOT RETURNED ALERTS
    // ===============================
    const pendingReturns = await labourRepo.getUnreturnedTokensAfterCheckout();

    for (const row of pendingReturns) {
      const labour = await labourRepo.getLabourById(row.labour_id);
      const supervisor = await visitorRepo.findById(row.supervisor_id);

      if (!supervisor?.host_id) continue;

      const hostRes = await db.query(
        `SELECT host_name, phone FROM hosts WHERE id = $1 AND is_active = true`,
        [supervisor.host_id]
      );

      const host = hostRes.rows[0];
      if (!host?.phone) continue;

      await smsService.sendTokenNotReturnedAlertSMS(
        host.phone,
        labour.full_name
      );
    }

    res.json({
      success: true,
      noShowCount: noShows.length,
      tokenNotReturnedCount: pendingReturns.length,
    });

  } catch (error) {
    logger.error("Check alerts error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const markNoShowAlertSent = async (labour_id) => {
  await db.query(
    `UPDATE labour_tokens 
     SET no_show_alert_sent = true 
     WHERE labour_id = $1 AND status = 'ACTIVE'`,
    [labour_id]
  );
};

export const markReturnAlertSent = async (labour_id) => {
  await db.query(
    `UPDATE labour_tokens SET return_alert_sent = true WHERE labour_id = $1 AND status = 'ACTIVE'`,
    [labour_id]
  );
};
export const getNoShowLabours = async () => {
  const result = await db.query(`
    SELECT 
      lt.labour_id,
      l.full_name AS labour_name,
      m.supervisor_id,
      v.host_id,
      v.full_name AS supervisor_name,
      v.company_name AS company,
      m.id AS manifest_id,
      m.manifest_date,
      (
        SELECT COUNT(*)
        FROM labour_manifests x
        WHERE x.manifest_date = m.manifest_date
          AND x.id <= m.id
      ) AS daily_sequence,
      m.printed_at
    FROM labour_tokens lt
    JOIN labours l ON l.id = lt.labour_id
    JOIN manifest_labours ml ON lt.labour_id = ml.labour_id
    JOIN labour_manifests m ON ml.manifest_id = m.id
    JOIN visitors v ON m.supervisor_id = v.id
    WHERE lt.status = 'ACTIVE'
      AND m.signed = TRUE
      AND m.printed_at < NOW() - INTERVAL '1 minutes'
      AND lt.no_show_alert_sent = false
      AND NOT EXISTS (
        SELECT 1
        FROM access_logs al
        WHERE al.person_id = lt.labour_id
          AND al.person_type = 'LABOUR'
          AND al.direction = 'IN'
          AND al.scan_time > m.printed_at
      )
  `);

  return result.rows;
};

export const getUnreturnedTokensAfterCheckout = async () => {
  const result = await db.query(`
    SELECT 
      lt.labour_id,
      l.full_name AS labour_name,
      m.supervisor_id,
      MIN(v.host_id) AS host_id,
      v.full_name AS supervisor_name,
      v.company_name AS company,
      m.id AS manifest_id,
      m.manifest_date,
      (
        SELECT COUNT(*)
        FROM labour_manifests x
        WHERE x.manifest_date = m.manifest_date
          AND x.id <= m.id
      ) AS daily_sequence,
      lt.token_uid,
      MAX(al.scan_time) AS last_out_time
    FROM labour_tokens lt
    JOIN labours l ON l.id = lt.labour_id
    JOIN manifest_labours ml ON lt.labour_id = ml.labour_id
    JOIN labour_manifests m ON ml.manifest_id = m.id
    JOIN visitors v ON m.supervisor_id = v.id
    JOIN access_logs al 
      ON al.person_id = lt.labour_id
     AND al.person_type = 'LABOUR'
     AND al.direction = 'OUT'
    WHERE lt.status = 'ACTIVE'
      AND lt.return_alert_sent = false
    GROUP BY 
      lt.labour_id,
      l.full_name,
      m.supervisor_id,
      v.full_name,
      v.company_name,
      m.id,
      m.manifest_date,
      (
        SELECT COUNT(*)
        FROM labour_manifests x
        WHERE x.manifest_date = m.manifest_date
          AND x.id <= m.id
      ),
      lt.token_uid
    HAVING MAX(al.scan_time) < NOW() - INTERVAL '1 minutes'
  `);

  return result.rows;
};
