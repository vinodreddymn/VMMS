import db from "../config/db.js";

export const run = async () => {

  // 1️⃣ Lock expired visitors
  const { rows: toLock } = await db.query(`
    WITH candidates AS (
      SELECT 
        v.id,
        CASE
          WHEN v.valid_to < CURRENT_DATE THEN 'Visitor validity expired'
          WHEN v.smartphone_expiry < CURRENT_DATE THEN 'Smartphone permission expired'
          WHEN v.laptop_expiry < CURRENT_DATE THEN 'Laptop permission expired'
          WHEN v.work_order_expiry < CURRENT_DATE THEN 'Work order expired'
          WHEN v.pvc_expiry < CURRENT_DATE THEN 'PVC expired'
          WHEN EXISTS (
            SELECT 1 FROM rfid_cards rc
            WHERE rc.visitor_id = v.id
              AND rc.card_status = 'ACTIVE'
              AND rc.expiry_date < CURRENT_DATE
          ) THEN 'RFID card expired'
          WHEN EXISTS (
            SELECT 1 FROM visitor_documents d
            WHERE d.visitor_id = v.id AND d.expiry_date < CURRENT_DATE
          ) THEN 'Visitor document expired'
          ELSE 'Unknown compliance issue'
        END AS reason
      FROM visitors v
      WHERE v.status != 'SOFT_LOCK'
        AND (
          v.valid_to < CURRENT_DATE
          OR v.smartphone_expiry < CURRENT_DATE
          OR v.laptop_expiry < CURRENT_DATE
          OR v.work_order_expiry < CURRENT_DATE
          OR v.pvc_expiry < CURRENT_DATE
          OR EXISTS (
            SELECT 1
            FROM rfid_cards rc
            WHERE rc.visitor_id = v.id
              AND rc.card_status = 'ACTIVE'
              AND rc.expiry_date < CURRENT_DATE
          )
          OR EXISTS (
            SELECT 1
            FROM visitor_documents d
            WHERE d.visitor_id = v.id
            AND d.expiry_date < CURRENT_DATE
          )
        )
    )
    UPDATE visitors v
    SET status = 'SOFT_LOCK'
    FROM candidates c
    WHERE v.id = c.id
    RETURNING v.id, c.reason
  `);

  if (toLock.length) {
    const values = toLock
      .map((_, i) => `($${i * 5 + 1},$${i * 5 + 2},$${i * 5 + 3},$${i * 5 + 4},$${i * 5 + 5})`)
      .join(",");

    const params = toLock.flatMap((row) => [
      row.id,
      'ACTIVE',
      'SOFT_LOCK',
      null,
      `Soft lock: ${row.reason}`,
    ]);

    await db.query(
      `
        INSERT INTO visitor_status_audit
          (visitor_id, old_status, new_status, changed_by, reason)
        VALUES ${values}
      `,
      params
    );
  }


  // 2️⃣ Unlock visitors if documents renewed
  const { rows: unlocked } = await db.query(`
    UPDATE visitors v
    SET status = 'ACTIVE'
    WHERE v.status = 'SOFT_LOCK'
    AND (
      (v.valid_to IS NULL OR v.valid_to >= CURRENT_DATE)
      AND (v.smartphone_expiry IS NULL OR v.smartphone_expiry >= CURRENT_DATE)
      AND (v.laptop_expiry IS NULL OR v.laptop_expiry >= CURRENT_DATE)
      AND (v.work_order_expiry IS NULL OR v.work_order_expiry >= CURRENT_DATE)
      AND (v.pvc_expiry IS NULL OR v.pvc_expiry >= CURRENT_DATE)
      AND NOT EXISTS (
        SELECT 1
        FROM rfid_cards rc
        WHERE rc.visitor_id = v.id
          AND rc.card_status = 'ACTIVE'
          AND rc.expiry_date < CURRENT_DATE
      )
      AND NOT EXISTS (
        SELECT 1
        FROM visitor_documents d
        WHERE d.visitor_id = v.id
        AND d.expiry_date < CURRENT_DATE
      )
    )
    RETURNING v.id
  `);

  if (unlocked.length) {
    const values = unlocked
      .map((_, i) => `($${i * 5 + 1},$${i * 5 + 2},$${i * 5 + 3},$${i * 5 + 4},$${i * 5 + 5})`)
      .join(",");

    const params = unlocked.flatMap((row) => [
      row.id,
      'SOFT_LOCK',
      'ACTIVE',
      null,
      'Auto-unlock: documents/expiry renewed',
    ]);

    await db.query(
      `
        INSERT INTO visitor_status_audit
          (visitor_id, old_status, new_status, changed_by, reason)
        VALUES ${values}
      `,
      params
    );
  }

};

// Evaluate a single visitor immediately (used after doc/expiry updates)
export const evaluateVisitorLock = async (visitorId) => {
  const { rows } = await db.query(
    `
    SELECT
      id,
      status,
      CASE
        WHEN valid_to < CURRENT_DATE THEN 'Visitor validity expired'
        WHEN smartphone_expiry < CURRENT_DATE THEN 'Smartphone permission expired'
        WHEN laptop_expiry < CURRENT_DATE THEN 'Laptop permission expired'
        WHEN work_order_expiry < CURRENT_DATE THEN 'Work order expired'
        WHEN pvc_expiry < CURRENT_DATE THEN 'PVC expired'
        WHEN EXISTS (
          SELECT 1 FROM rfid_cards rc
          WHERE rc.visitor_id = v.id
            AND rc.card_status = 'ACTIVE'
            AND rc.expiry_date < CURRENT_DATE
        ) THEN 'RFID card expired'
        WHEN EXISTS (
          SELECT 1 FROM visitor_documents d
          WHERE d.visitor_id = v.id AND d.expiry_date < CURRENT_DATE
        ) THEN 'Visitor document expired'
        ELSE NULL
      END AS reason
    FROM visitors v
    WHERE id = $1
    `,
    [visitorId]
  );

  if (!rows.length) return null;
  const visitor = rows[0];
  const hasIssue = Boolean(visitor.reason);

  if (hasIssue && visitor.status !== "SOFT_LOCK") {
    await db.query(`UPDATE visitors SET status = 'SOFT_LOCK' WHERE id = $1`, [visitorId]);
    await db.query(
      `INSERT INTO visitor_status_audit (visitor_id, old_status, new_status, changed_by, reason)
       VALUES ($1,$2,$3,$4,$5)`,
      [visitorId, visitor.status, 'SOFT_LOCK', null, `Soft lock: ${visitor.reason}`]
    );
    return { status: 'SOFT_LOCK', reason: visitor.reason };
  }

  if (!hasIssue && visitor.status === "SOFT_LOCK") {
    await db.query(`UPDATE visitors SET status = 'ACTIVE' WHERE id = $1`, [visitorId]);
    await db.query(
      `INSERT INTO visitor_status_audit (visitor_id, old_status, new_status, changed_by, reason)
       VALUES ($1,$2,$3,$4,$5)`,
      [visitorId, 'SOFT_LOCK', 'ACTIVE', null, 'Auto-unlock: documents/expiry renewed']
    );
    return { status: 'ACTIVE', reason: null };
  }

  return { status: visitor.status, reason: visitor.reason };
};

// Get current soft-lock reason (if any) for UI display
export const getSoftLockReason = async (visitorId) => {
  const { rows } = await db.query(
    `
    SELECT
      CASE
        WHEN status = 'SOFT_LOCK' THEN
          CASE
            WHEN valid_to < CURRENT_DATE THEN 'Visitor validity expired'
            WHEN smartphone_expiry < CURRENT_DATE THEN 'Smartphone permission expired'
            WHEN laptop_expiry < CURRENT_DATE THEN 'Laptop permission expired'
            WHEN work_order_expiry < CURRENT_DATE THEN 'Work order expired'
            WHEN pvc_expiry < CURRENT_DATE THEN 'PVC expired'
            WHEN EXISTS (
              SELECT 1 FROM rfid_cards rc
              WHERE rc.visitor_id = v.id
                AND rc.card_status = 'ACTIVE'
                AND rc.expiry_date < CURRENT_DATE
            ) THEN 'RFID card expired'
            WHEN EXISTS (
              SELECT 1 FROM visitor_documents d
              WHERE d.visitor_id = v.id AND d.expiry_date < CURRENT_DATE
            ) THEN 'Visitor document expired'
            ELSE NULL
          END
        ELSE NULL
      END AS reason,
      status
    FROM visitors v
    WHERE id = $1
    `,
    [visitorId]
  );

  const row = rows[0];
  const reason = row?.reason || null;

  // Defensive: if soft-locked but no remaining issue, auto-unlock
  if (row?.status === "SOFT_LOCK" && !reason) {
    await db.query(`UPDATE visitors SET status = 'ACTIVE' WHERE id = $1`, [visitorId]);
    await db.query(
      `INSERT INTO visitor_status_audit (visitor_id, old_status, new_status, changed_by, reason)
       VALUES ($1,$2,$3,$4,$5)`,
      [visitorId, 'SOFT_LOCK', 'ACTIVE', null, 'Auto-unlock: no compliance issues detected']
    );
    return null;
  }

  return reason;
};
