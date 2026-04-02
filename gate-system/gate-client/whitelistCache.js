import { promises as fs } from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
export const cachePathAbsolute = path.join(__dirname, "whitelist.json");

const ensureCache = async () => {
  try {
    await fs.access(cachePathAbsolute);
  } catch {
    await fs.mkdir(path.dirname(cachePathAbsolute), { recursive: true });
    await fs.writeFile(
      cachePathAbsolute,
      JSON.stringify({ entries: [], lastSync: null }, null, 2)
    );
  }
};

export const readCache = async () => {
  await ensureCache();
  return JSON.parse(await fs.readFile(cachePathAbsolute));
};

export const updateCache = async (entries) => {
  const payload = { entries, lastSync: new Date().toISOString() };
  await fs.writeFile(cachePathAbsolute, JSON.stringify(payload, null, 2));
  return payload;
};
