import { memory } from '../database/db.js';

export const getWhitelistSince = (sinceIso) => {
  const since = sinceIso ? new Date(sinceIso).getTime() : 0;
  return memory.whitelist.filter((entry) => new Date(entry.updated_at).getTime() >= since);
};

export const addOrUpdateWhitelist = (entry) => {
  const idx = memory.whitelist.findIndex((e) => e.rfid_uid === entry.rfid_uid);
  const timestamped = { ...entry, updated_at: new Date().toISOString() };
  if (idx >= 0) {
    memory.whitelist[idx] = { ...memory.whitelist[idx], ...timestamped };
  } else {
    memory.whitelist.push({ id: memory.whitelist.length + 1, ...timestamped });
  }
  return timestamped;
};
