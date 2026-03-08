import db from "../config/db.js";
import * as encryption from "../utils/encryption.util.js";
// =====================================================
// BLACKLIST OPERATIONS
// =====================================================

export const check = async (visitor) => {
  const result = await db.query(
    `SELECT * FROM blacklist
     WHERE aadhaar_hash=$1 OR phone=$2`,
    [visitor.aadhaar_encrypted, visitor.primary_phone]
  );

  return result.rows.length > 0;
};

export const checkByAadhaar = async (aadhaar) => {
  const aadhaar_hash = encryption.hashAadhaarForBlacklist(aadhaar);
  const query = "SELECT * FROM blacklist WHERE aadhaar_hash = $1";
  const result = await db.query(query, [aadhaar_hash]);
  return result.rows[0];
};

export const checkByPhone = async (phone) => {
  const query = "SELECT * FROM blacklist WHERE phone = $1";
  const result = await db.query(query, [phone]);
  return result.rows[0];
};

export const checkByBiometric = async (biometric_hash) => {
  const query = "SELECT * FROM blacklist WHERE biometric_hash = $1";
  const result = await db.query(query, [biometric_hash]);
  return result.rows[0];
};

export const addToBlacklist = async (aadhaar, phone, biometric_hash, reason, block_type) => {
  const aadhaar_hash = aadhaar ? encryption.hashAadhaarForBlacklist(aadhaar) : null;

  const query = `
    INSERT INTO blacklist (aadhaar_hash, phone, biometric_hash, reason, block_type)
    VALUES ($1, $2, $3, $4, $5) RETURNING *;
  `;
  const result = await db.query(query, [aadhaar_hash, phone, biometric_hash, reason, block_type]);
  return result.rows[0];
};

export const removeFromBlacklist = async (blacklist_id) => {
  const query = "DELETE FROM blacklist WHERE id = $1";
  await db.query(query, [blacklist_id]);
};

export const getBlacklist = async () => {
  const query = "SELECT * FROM blacklist ORDER BY created_at DESC";
  const result = await db.query(query);
  return result.rows;
};

export const getBlacklistById = async (id) => {
  const query = "SELECT * FROM blacklist WHERE id = $1";
  const result = await db.query(query, [id]);
  return result.rows[0];
};