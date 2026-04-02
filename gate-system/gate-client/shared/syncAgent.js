const DEFAULTS = {
  whitelistIntervalMs: 5 * 60 * 1000,
  queueFlushIntervalMs: 10 * 1000,
  heartbeatIntervalMs: 60 * 1000,
  batchSize: 50,
};

const nowIso = () => new Date().toISOString();

const mergeWhitelist = (existing, updates) => {
  const map = new Map(existing.map((e) => [e.rfid_uid, e]));
  (updates || []).forEach((u) => map.set(u.rfid_uid, u));
  return Array.from(map.values());
};

export const createSyncAgent = ({ gateConfig, readCache, updateCache, queueStore }) => {
  const cfg = {
    whitelistIntervalMs: gateConfig.whitelist_interval_ms || DEFAULTS.whitelistIntervalMs,
    queueFlushIntervalMs: gateConfig.queue_flush_interval_ms || DEFAULTS.queueFlushIntervalMs,
    heartbeatIntervalMs: gateConfig.heartbeat_interval_ms || DEFAULTS.heartbeatIntervalMs,
    batchSize: gateConfig.queue_batch_size || DEFAULTS.batchSize,
  };

  const fetchJson = async (url, options = {}) => {
    const res = await fetch(url, {
      ...options,
      headers: { "Content-Type": "application/json", ...(options.headers || {}) },
    });
    if (!res.ok) {
      throw new Error(`HTTP ${res.status}`);
    }
    return res.json();
  };

  const syncWhitelist = async () => {
    const cache = await readCache();
    const params = new URLSearchParams();
    if (cache.lastSync) params.set("last_sync", cache.lastSync);
    // NOTE: gate_id omitted to allow full whitelist unless server enforces gate scoping
    const suffix = params.toString() ? `?${params.toString()}` : "";
    try {
      const data = await fetchJson(`${gateConfig.server_url}/api/sync/whitelist${suffix}`);
      const incoming = data.whitelist || data.entries || [];
      if (!Array.isArray(incoming) || !incoming.length) {
        console.warn("Whitelist sync returned 0 entries; keeping existing cache");
        return cache.entries.length;
      }
      const merged = mergeWhitelist(cache.entries, incoming);
      await updateCache(merged);
      console.log(`Whitelist synced: ${merged.length} entries`);
      return merged.length;
    } catch (err) {
      console.warn("Whitelist sync failed; using cached list", err.message);
      return cache.entries.length;
    }
  };

  const evaluateAccess = async (rfid_uid) => {
    const cache = await readCache();
    return cache.entries.find((e) => e.rfid_uid === rfid_uid) || null;
  };

  const postQueue = async (payloads) => {
    return fetchJson(`${gateConfig.server_url}/api/sync/queue`, {
      method: "POST",
      body: JSON.stringify({ gate_id: gateConfig.gate_id, payloads }),
    });
  };

  const enqueuePayloads = async (payloads) => queueStore.pushMany(payloads);

  const flushQueue = async () => {
    const batch = await queueStore.shiftBatch(cfg.batchSize);
    if (!batch.length) return { sent: 0 };
    try {
      await postQueue(batch);
      return { sent: batch.length };
    } catch (err) {
      await enqueuePayloads(batch); // push back
      return { sent: 0, error: err.message };
    }
  };

  const submitAccessLog = async (logEntry) => {
    const payload = { access_logs: [logEntry], created_at: nowIso() };
    try {
      await postQueue([payload]);
      return { queued: false };
    } catch (err) {
      await enqueuePayloads([payload]);
      console.warn("Post queue failed, enqueued locally:", err.message);
      return { queued: true, error: err.message };
    }
  };

  const heartbeat = async () => {
    const queueDepth = await queueStore.size();
    const healthBody = {
      gate_id: gateConfig.gate_id,
      is_online: true,
      cpu_usage: 0,
      memory_usage: 0,
      storage_usage: 0,
      camera_status: true,
      rfid_status: true,
      biometric_status: true,
    };
    try {
      await fetchJson(`${gateConfig.server_url}/api/gate/health`, {
        method: "POST",
        body: JSON.stringify(healthBody),
      });
    } catch (err) {
      // fallback: record as queue payload so it can be inspected later
      await enqueuePayloads([
        {
          type: "health",
          gate_id: gateConfig.gate_id,
          created_at: nowIso(),
          metrics: { queue_depth: queueDepth },
        },
      ]);
      console.warn("Heartbeat send failed, queued locally:", err.message);
    }
  };

  const start = async () => {
    await syncWhitelist();
    setInterval(syncWhitelist, cfg.whitelistIntervalMs);
    setInterval(flushQueue, cfg.queueFlushIntervalMs);
    setInterval(heartbeat, cfg.heartbeatIntervalMs);
  };

  return { start, syncWhitelist, evaluateAccess, submitAccessLog, flushQueue, heartbeat };
};
