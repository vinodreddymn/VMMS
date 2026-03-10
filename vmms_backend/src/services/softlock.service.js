import db from "../config/db.js";

export const run = async () => {

  // 1️⃣ Lock expired visitors
  await db.query(`
    UPDATE visitors v
    SET status = 'SOFT_LOCK'
    WHERE v.status != 'SOFT_LOCK'
    AND (
      v.valid_to < CURRENT_DATE
      OR v.smartphone_expiry < CURRENT_DATE
      OR v.laptop_expiry < CURRENT_DATE
      OR v.work_order_expiry < CURRENT_DATE
      OR v.pvc_expiry < CURRENT_DATE
      OR EXISTS (
        SELECT 1
        FROM visitor_documents d
        WHERE d.visitor_id = v.id
        AND d.expiry_date < CURRENT_DATE
      )
    )
  `);


  // 2️⃣ Unlock visitors if documents renewed
  await db.query(`
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
        FROM visitor_documents d
        WHERE d.visitor_id = v.id
        AND d.expiry_date < CURRENT_DATE
      )
    )
  `);

};