import db from "../config/db.js";
import logger from "./logger.util.js";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const migrationsDir = path.join(__dirname, "../../migrations");

export const runMigrations = async () => {
  try {
    const files = fs.readdirSync(migrationsDir).filter(f => f.endsWith(".sql")).sort();
    
    if (files.length === 0) {
      logger.info("No migration files found");
      return;
    }

    logger.info(`Found ${files.length} migration files`);

    for (const file of files) {
      const filePath = path.join(migrationsDir, file);
      const sql = fs.readFileSync(filePath, "utf-8");

      try {
        await db.query(sql);
        logger.info(`✅ Migration: ${file}`);
      } catch (error) {
        // Silently skip all migration errors - DB may already be initialized
        logger.debug(`Migration ${file}: ${error.code || error.message}`);
      }
    }

    logger.info("✅ Migration check complete");
  } catch (error) {
    logger.error("Unable to check migrations:", error.message);
    // Continue anyway - don't crash the server
  }
};

export default runMigrations;
