import db from "../config/db.js";
export const run = async () => {
  await db.query(`
    UPDATE visitors
    SET status='SOFT_LOCK'
    WHERE id IN (
      SELECT visitor_id FROM visitor_documents
      WHERE expiry_date < CURRENT_DATE
    )
  `);
};