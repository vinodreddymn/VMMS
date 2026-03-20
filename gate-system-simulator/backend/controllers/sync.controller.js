import { getWhitelistSince } from '../services/sync.service.js';
import { insertAccessLog } from '../database/db.js';
import { log } from '../utils/logger.js';

export const getWhitelist = (req, res) => {
  const { since } = req.query;
  const data = getWhitelistSince(since);
  log('Whitelist sync request', { since, count: data.length });
  res.json({ entries: data });
};

export const acceptOfflineLogs = async (req, res) => {
  const { logs = [] } = req.body || {};
  for (const entry of logs) {
    await insertAccessLog(entry);
  }
  log('Offline logs accepted', logs.length);
  res.json({ stored: logs.length });
};
