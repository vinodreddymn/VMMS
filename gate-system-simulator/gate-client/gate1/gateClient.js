import { promises as fs } from 'fs';
import path from 'path';
import WebSocket from 'ws';
import { readCache, updateCache, cachePathAbsolute } from './whitelistCache.js';
import { startScanLoop } from './scanSimulator.js';

const configPath = path.join(path.dirname(cachePathAbsolute), 'config.json');
const gateConfig = JSON.parse(await fs.readFile(configPath));

const log = (...args) => console.log(`[Gate ${gateConfig.gate_id}]`, ...args);

const mergeWhitelist = (existing, updates) => {
  const map = new Map(existing.map((e) => [e.rfid_uid, e]));
  updates.forEach((u) => map.set(u.rfid_uid, u));
  return Array.from(map.values());
};

const syncWhitelist = async () => {
  try {
    const cache = await readCache();
    const sinceParam = cache.lastSync ? `?since=${encodeURIComponent(cache.lastSync)}` : '';
    const res = await fetch(`${gateConfig.server_url}/api/sync/whitelist${sinceParam}`);
    const data = await res.json();
    const merged = mergeWhitelist(cache.entries, data.entries);
    await updateCache(merged);
    log('Whitelist synced', merged.length, 'entries');
  } catch (err) {
    log('Whitelist sync failed', err.message);
  }
};

const evaluateAccess = async (rfid_uid) => {
  const cache = await readCache();
  return cache.entries.find((e) => e.rfid_uid === rfid_uid) || null;
};

const sendScan = async (scanPayload) => {
  try {
    const res = await fetch(`${gateConfig.server_url}/api/gate/scan`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(scanPayload),
    });
    const data = await res.json();
    log('Scan response', data.status, data.visitor_name);
  } catch (err) {
    log('Failed to send scan', err.message);
  }
};

const startDisplayListener = () => {
  const ws = new WebSocket(gateConfig.display_ws);
  ws.on('open', () => log('Connected to display channel'));
  ws.on('message', (msg) => {
    const evt = JSON.parse(msg.toString());
    if (evt.gate_id === gateConfig.gate_id) {
      log('Display update', evt.status, evt.visitor_name);
    }
  });
  ws.on('close', () => setTimeout(startDisplayListener, 2000));
  ws.on('error', () => ws.close());
};

const run = async () => {
  await syncWhitelist();
  setInterval(syncWhitelist, 5 * 60 * 1000);
  startDisplayListener();
  startScanLoop(gateConfig, async (scan) => {
    const whitelistEntry = await evaluateAccess(scan.rfid_uid);
    await sendScan({ ...scan, ...whitelistEntry });
  });
};

run();
