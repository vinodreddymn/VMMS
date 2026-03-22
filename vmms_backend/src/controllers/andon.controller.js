import db from "../config/db.js";
import logger from "../utils/logger.util.js";

const todayISO = () => {
  const now = new Date();
  const yyyy = now.getFullYear();
  const mm = String(now.getMonth() + 1).padStart(2, "0");
  const dd = String(now.getDate()).padStart(2, "0");
  return `${yyyy}-${mm}-${dd}`;
};

export const getSummary = async (req, res) => {
  try {
    const date = req.query.date || todayISO();

    /* ---------------- VISITOR STATS ---------------- */

    const visitorStatsQuery = `
      WITH latest AS (
        SELECT person_id, MAX(scan_time) AS last_scan_time
        FROM access_logs
        WHERE person_type = 'VISITOR'
          AND scan_time::DATE = $1::DATE
          AND status = 'SUCCESS'
        GROUP BY person_id
      ),
      state AS (
        SELECT l.person_id, a.direction
        FROM latest l
        JOIN access_logs a
          ON a.person_id = l.person_id
         AND a.scan_time = l.last_scan_time
         AND a.person_type = 'VISITOR'
      )
      SELECT
        COUNT(*) FILTER (WHERE al.direction = 'IN') AS total_visitors,
        COUNT(DISTINCT CASE WHEN al.direction = 'IN' THEN al.person_id END) AS unique_visitors,
        COUNT(DISTINCT CASE WHEN al.direction = 'OUT' THEN al.person_id END) AS visitors_exited,
        COALESCE((SELECT COUNT(*) FROM state WHERE direction = 'IN'),0) AS visitors_inside
      FROM access_logs al
      WHERE al.person_type = 'VISITOR'
        AND al.scan_time::DATE = $1::DATE
        AND al.status = 'SUCCESS'
    `;

    /* ---------------- LABOUR STATS ---------------- */

    const labourStatsQuery = `
      WITH latest AS (
        SELECT person_id, MAX(scan_time) AS last_scan_time
        FROM access_logs
        WHERE person_type = 'LABOUR'
          AND scan_time::DATE = $1::DATE
          AND status = 'SUCCESS'
        GROUP BY person_id
      ),
      state AS (
        SELECT l.person_id, a.direction
        FROM latest l
        JOIN access_logs a
          ON a.person_id = l.person_id
         AND a.scan_time = l.last_scan_time
         AND a.person_type = 'LABOUR'
      )
      SELECT
        COALESCE((
          SELECT COUNT(DISTINCT ml.labour_id)
          FROM labour_manifests lm
          JOIN manifest_labours ml ON ml.manifest_id = lm.id
          WHERE lm.manifest_date = $1::DATE
        ),0) AS registered,

        COUNT(DISTINCT CASE WHEN al.direction = 'IN' THEN al.person_id END) AS checked_in,

        COUNT(DISTINCT CASE WHEN al.direction = 'OUT' THEN al.person_id END) AS checked_out,

        COALESCE((
          SELECT COUNT(*)
          FROM state
          WHERE direction = 'IN'
        ),0) AS labours_inside,

        COALESCE((
          SELECT COUNT(DISTINCT ml.labour_id)
          FROM labour_manifests lm
          JOIN manifest_labours ml ON ml.manifest_id = lm.id
          LEFT JOIN labour_tokens lt
            ON lt.labour_id = ml.labour_id
           AND DATE(lt.assigned_date) = lm.manifest_date
          WHERE lm.manifest_date = $1::DATE
            AND (lt.status IS NULL OR lt.status IN ('INACTIVE','RETURNED'))
        ),0) AS returned_tokens

      FROM access_logs al
      WHERE al.person_type = 'LABOUR'
        AND al.scan_time::DATE = $1::DATE
        AND al.status = 'SUCCESS'
    `;

    /* ---------------- EXECUTE ---------------- */

    const [visitorStatsRes, labourStatsRes, lastScanRes] = await Promise.all([
      db.query(visitorStatsQuery, [date]),
      db.query(labourStatsQuery, [date]),
      db.query(
        `SELECT MAX(scan_time) AS last_scan_time
         FROM access_logs
         WHERE scan_time::DATE = $1::DATE`,
        [date]
      ),
    ]);

    const v = visitorStatsRes.rows[0] || {};
    const l = labourStatsRes.rows[0] || {};

    const totalVisitors = Number(v.total_visitors || 0);
    const uniqueVisitors = Number(v.unique_visitors || 0);

    res.json({
      success: true,
      date,

      visitors: {
        total_visitors: totalVisitors,
        unique_visitors: uniqueVisitors,
        repeat_visitors: Math.max(totalVisitors - uniqueVisitors, 0),
        visitors_inside: Number(v.visitors_inside || 0),
        visitors_exited: Number(v.visitors_exited || 0),
      },

      labours: {
        registered: Number(l.registered || 0),
        checked_in: Number(l.checked_in || 0),
        checked_out: Number(l.checked_out || 0),

        /* NEW FIELD */
        labours_inside: Number(l.labours_inside || 0),

        returned_tokens: Number(l.returned_tokens || 0),
      },

      last_scan_time: lastScanRes.rows[0]?.last_scan_time || null,
    });
  } catch (error) {
    logger.error("Andon summary error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const getTransactions = async (req, res) => {
  try {
    const date = req.query.date || todayISO();
    const limit = Math.min(Number(req.query.limit) || 50, 200);

    const visitorQuery = `
      SELECT
        al.id AS access_log_id,
        al.scan_time,
        al.direction,
        al.status,
        al.live_photo_path,
        v.id AS visitor_id,
        v.pass_no,
        v.full_name,
        v.company_name,
        v.primary_phone,
        v.aadhaar_last4,
        v.enrollment_photo_path,
        p.project_name,
        d.department_name,
        h.host_name,
        g.gate_name
      FROM access_logs al
      LEFT JOIN visitors v ON al.person_id = v.id AND al.person_type = 'VISITOR'
      LEFT JOIN projects p ON v.project_id = p.id
      LEFT JOIN departments d ON v.department_id = d.id
      LEFT JOIN hosts h ON v.host_id = h.id
      LEFT JOIN gates g ON al.gate_id = g.id
      WHERE al.person_type = 'VISITOR'
        AND al.scan_time::DATE = $1::DATE
      ORDER BY al.scan_time DESC
      LIMIT $2
    `;

    const labourQuery = `
      SELECT
        al.id AS access_log_id,
        al.scan_time,
        al.direction,
        al.status,
        al.live_photo_path,
        l.id AS labour_id,
        l.full_name,
        l.phone,
        sup.full_name AS supervisor_name,
        sup.company_name AS supervisor_company,
        sup.enrollment_photo_path AS enrollment_photo_path,
        p.project_name,
        g.gate_name,
        lt.token_uid
      FROM access_logs al
      LEFT JOIN labours l ON al.person_id = l.id AND al.person_type = 'LABOUR'
      LEFT JOIN visitors sup ON l.supervisor_id = sup.id
      LEFT JOIN projects p ON sup.project_id = p.id
      LEFT JOIN gates g ON al.gate_id = g.id
      LEFT JOIN LATERAL (
        SELECT token_uid
        FROM labour_tokens t
        WHERE t.labour_id = l.id
          AND t.assigned_date = al.scan_time::DATE
        ORDER BY t.id DESC
        LIMIT 1
      ) lt ON TRUE
      WHERE al.person_type = 'LABOUR'
        AND al.scan_time::DATE = $1::DATE
      ORDER BY al.scan_time DESC
      LIMIT $2
    `;

    const [visitorsRes, laboursRes] = await Promise.all([
      db.query(visitorQuery, [date, limit]),
      db.query(labourQuery, [date, limit]),
    ]);

    res.json({
      success: true,
      date,
      visitors: visitorsRes.rows || [],
      labours: laboursRes.rows || [],
    });
  } catch (error) {
    logger.error("Andon transactions error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

export const getEvents = async (req, res) => {
  try {
    const date = req.query.date || todayISO();
    const limit = Math.min(Number(req.query.limit) || 20, 100);
    let since = req.query.since ? new Date(req.query.since) : null;
    if (since && Number.isNaN(since.getTime())) {
      since = null;
    }

    const query = `
      WITH visitor_events AS (
        SELECT
          al.id AS access_log_id,
          al.scan_time,
          al.direction,
          al.status,
          al.live_photo_path,
          'VISITOR' AS person_type,
          v.id AS person_id,
          v.pass_no,
        v.full_name,
        v.primary_phone AS phone,
        v.aadhaar_last4,
        v.enrollment_photo_path,
        v.designation,
        v.valid_from AS pass_valid_from,
        v.valid_to AS pass_valid_to,
        p.project_name,
        d.department_name,
        h.host_name,
        g.gate_name,
        v.company_name,
        perm.gate_permissions,
        v.work_order_expiry AS pass_valid_till,
        NULL::text AS supervisor_name,
        NULL::text AS token_uid
      FROM access_logs al
      LEFT JOIN visitors v ON al.person_id = v.id AND al.person_type = 'VISITOR'
      LEFT JOIN projects p ON v.project_id = p.id
      LEFT JOIN departments d ON v.department_id = d.id
      LEFT JOIN hosts h ON v.host_id = h.id
      LEFT JOIN gates g ON al.gate_id = g.id
      LEFT JOIN LATERAL (
        SELECT COALESCE(ARRAY_AGG(g2.gate_name ORDER BY g2.gate_name), '{}') AS gate_permissions
        FROM visitor_gate_permissions vgp
        JOIN gates g2 ON g2.id = vgp.gate_id
        WHERE vgp.visitor_id = v.id
      ) perm ON TRUE
      WHERE al.person_type = 'VISITOR'
        AND al.scan_time::DATE = $1::DATE
    ),
    labour_events AS (
      SELECT
          al.id AS access_log_id,
          al.scan_time,
          al.direction,
          al.status,
          al.live_photo_path,
          'LABOUR' AS person_type,
          l.id AS person_id,
          NULL::text AS pass_no,
        l.full_name,
        l.phone,
        NULL::text AS aadhaar_last4,
        sup.enrollment_photo_path AS enrollment_photo_path,
        sup.enrollment_photo_path AS supervisor_enrollment_photo_path,
        NULL::text AS designation,
        NULL::date AS pass_valid_from,
        NULL::date AS pass_valid_to,
        p.project_name,
        NULL::text AS department_name,
        NULL::text AS host_name,
        g.gate_name,
        sup.full_name AS supervisor_name,
        sup.company_name AS supervisor_company,
        lt.token_uid
      FROM access_logs al
      LEFT JOIN labours l ON al.person_id = l.id AND al.person_type = 'LABOUR'
      LEFT JOIN visitors sup ON l.supervisor_id = sup.id
      LEFT JOIN projects p ON sup.project_id = p.id
        LEFT JOIN gates g ON al.gate_id = g.id
        LEFT JOIN LATERAL (
          SELECT token_uid
          FROM labour_tokens t
          WHERE t.labour_id = l.id
            AND t.assigned_date = al.scan_time::DATE
          ORDER BY t.id DESC
          LIMIT 1
        ) lt ON TRUE
        WHERE al.person_type = 'LABOUR'
          AND al.scan_time::DATE = $1::DATE
      )
      SELECT *
      FROM (
        SELECT * FROM visitor_events
        UNION ALL
        SELECT * FROM labour_events
      ) e
      WHERE ($2::timestamp IS NULL OR e.scan_time > $2::timestamp)
        AND e.status = 'SUCCESS'
      ORDER BY e.scan_time ASC
      LIMIT $3
    `;

    const result = await db.query(query, [date, since, limit]);
    res.json({ success: true, date, events: result.rows || [] });
  } catch (error) {
    logger.error("Andon events error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};
