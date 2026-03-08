import jwt from "jsonwebtoken";
import env from "../config/env.js";
import db from "../config/db.js";

const auth = async (req, res, next) => {
  const token = req.headers.authorization?.split(" ")[1];

  if (!token) {
    return res.status(401).json({ message: "Unauthorized" });
  }

  try {
    const decoded = jwt.verify(token, env.jwtSecret);

    // Fetch role permissions from database
    const roleResult = await db.query(
      "SELECT can_export_pdf, can_export_excel FROM roles WHERE role_name = $1",
      [decoded.role]
    );

    const rolePerms = roleResult.rows[0] || {};

    req.user = {
      ...decoded,
      can_export_pdf: rolePerms.can_export_pdf || false,
      can_export_excel: rolePerms.can_export_excel || false,
    };

    next();
  } catch (error) {
    return res.status(401).json({ message: "Invalid Token" });
  }
};

export default auth;