import { promises as fs } from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const cachePath = path.join(__dirname, 'whitelist.json');

const ensureCache = async () => {
  try {
    await fs.access(cachePath);
  } catch {
    await fs.writeFile(cachePath, JSON.stringify({ entries: [], lastSync: null }, null, 2));
  }
};

export const readCache = async () => {
  await ensureCache();
  const data = JSON.parse(await fs.readFile(cachePath));
  return data;
};

export const updateCache = async (entries) => {
  const payload = { entries, lastSync: new Date().toISOString() };
  await fs.writeFile(cachePath, JSON.stringify(payload, null, 2));
  return payload;
};

export const cachePathAbsolute = cachePath;
