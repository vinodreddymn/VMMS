import { promises as fs } from "fs";
import path from "path";
import readline from "readline";
import fetch from "node-fetch";
import { exec } from "child_process";
import { readCache, updateCache, cachePathAbsolute } from "./whitelistCache.js";
import { createQueueStore } from "./shared/queueStore.js";
import { createSyncAgent } from "./shared/syncAgent.js";

global.fetch = global.fetch || fetch; // ensure fetch available on Node <18

const configPath = path.join(path.dirname(cachePathAbsolute), "config.json");
const gateConfig = JSON.parse(await fs.readFile(configPath));

// Allow self-signed certs when explicitly enabled in config
if (gateConfig.allow_self_signed) {
  process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";
}

const log = (...args) => console.log(`[Gate ${gateConfig.gate_id}]`, ...args);
const logCap = (...args) => console.log(`[Gate ${gateConfig.gate_id}][capture]`, ...args);

const queueStore = createQueueStore(path.dirname(cachePathAbsolute));
const syncAgent = createSyncAgent({ gateConfig, readCache, updateCache, queueStore });

// Track last direction per person (visitor_id) to alternate IN/OUT
const lastDirection = new Map();

const resolvePhotoUrl = (p) => {
  if (!p) return null;
  if (p.startsWith("http")) return p;
  const trimmed = p.replace(/^\/+/, "");
  return `${gateConfig.server_url}/${trimmed}`;
};

// Webcam capture (JPEG) - lazy load to avoid crashing if module missing
let webcam = null;

const getWebcam = () => {
  if (webcam) return webcam;
  try {
    const NodeWebcam = require("node-webcam");
    webcam = NodeWebcam.create({
      width: 640,
      height: 480,
      quality: 80,
      delay: 0,
      saveShots: true,
      output: "jpeg",
      device: gateConfig.camera_device || gateConfig.video || false, // default system camera or configured name
    });
  } catch {
    webcam = null;
  }
  return webcam;
};

const tryReadLocalLivePhoto = async () => {
  if (!gateConfig.live_photo_path) return null;
  try {
    const photoPath = path.isAbsolute(gateConfig.live_photo_path)
      ? gateConfig.live_photo_path
      : path.join(path.dirname(cachePathAbsolute), "..", gateConfig.live_photo_path);
    logCap("Using existing live_photo_path:", photoPath);
    const buf = await fs.readFile(photoPath);
    return `data:image/jpeg;base64,${buf.toString("base64")}`;
  } catch {
    logCap("live_photo_path not found/unreadable");
    return null;
  }
};

const captureWithFfmpeg = async () => {
  const deviceName = gateConfig.ffmpeg_device || gateConfig.video || "Integrated Webcam";
  const device = `video=${deviceName}`;
  const outPath = path.join(path.dirname(cachePathAbsolute), "ffmpeg_live_photo.jpg");
  return new Promise((resolve) => {
    logCap("Trying ffmpeg with device:", device);
    exec(
      `ffmpeg -y -f dshow -i ${JSON.stringify(device)} -frames:v 1 "${outPath}" -loglevel error`,
      { timeout: 7000 },
      async (err) => {
        if (err) {
          logCap("ffmpeg failed:", err.message);
          return resolve(null);
        }
        try {
          const buf = await fs.readFile(outPath);
          resolve(`data:image/jpeg;base64,${buf.toString("base64")}`);
        } catch {
          logCap("ffmpeg output missing");
          resolve(null);
        } finally {
          try { await fs.unlink(outPath); } catch {}
        }
      }
    );
  });
};

const readLatestCameraRollPhoto = async () => {
  const cameraRoll = path.join(process.env.USERPROFILE || "", "Pictures", "Camera Roll");
  try {
    const files = await fs.readdir(cameraRoll);
    const photos = await Promise.all(
      files
        .filter((f) => f.toLowerCase().match(/\.(jpg|jpeg|png)$/))
        .map(async (f) => {
          const full = path.join(cameraRoll, f);
          const stat = await fs.stat(full);
          return { full, mtime: stat.mtimeMs };
        })
    );
    if (!photos.length) return null;
    const latest = photos.sort((a, b) => b.mtime - a.mtime)[0];
    logCap("Using latest Camera Roll photo:", latest.full);
    const buf = await fs.readFile(latest.full);
    return `data:image/jpeg;base64,${buf.toString("base64")}`;
  } catch {
    return null;
  }
};

const captureWithWebcamLib = async () =>
  new Promise((resolve) => {
    const cam = getWebcam();
    if (!cam) {
      logCap("node-webcam not available");
      resolve(null);
      return;
    }
    logCap("Trying node-webcam capture");
    cam.capture("temp_live_photo", async (err, data) => {
      if (err || !data) {
        logCap("node-webcam capture failed", err?.message);
        resolve(null);
        return;
      }
      try {
        const filePath = data.endsWith(".jpg") ? data : `${data}.jpg`;
        const buf = await fs.readFile(filePath);
        resolve(`data:image/jpeg;base64,${buf.toString("base64")}`);
      } catch {
        logCap("node-webcam read failed");
        resolve(null);
      } finally {
        try {
          const filePath = data.endsWith(".jpg") ? data : `${data}.jpg`;
          await fs.unlink(filePath);
        } catch {}
      }
    });
  });

const captureLivePhoto = async () => {
  // Priority: existing live_photo_path (e.g., external capture), then ffmpeg, then node-webcam
  const localFile = await tryReadLocalLivePhoto();
  if (localFile) return localFile;

  const cameraRoll = await readLatestCameraRollPhoto();
  if (cameraRoll) return cameraRoll;

  const ffmpegPhoto = await captureWithFfmpeg();
  if (ffmpegPhoto) return ffmpegPhoto;

  return captureWithWebcamLib();
};

const postJson = async (path, body) => {
  const url = `${gateConfig.server_url.replace(/\/$/, "")}/api/gate/${path}`;
  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  if (!res.ok) {
    throw new Error(`HTTP ${res.status}`);
  }
  return res.json();
};

const sendDisplayUpdate = async (payload) => {
  const url = `${gateConfig.local_backend_url || "http://127.0.0.1:3200"}/api/local/display`;
  try {
    await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });
  } catch (err) {
    log("Display update failed", err.message);
  }
};

const handleScan = async (rfid_uid) => {
  const livePhotoBase64 = await captureLivePhoto();

  let payload = null;
  let status = "DENIED";
  let direction = "IN";

  // -------- TRY LIVE BACKEND (same as GateDisplay) --------
  try {
    const res = await postJson("authenticate", {
      card_uid: rfid_uid,
      gate_id: gateConfig.gate_id,
      photo: livePhotoBase64,
    });

    if ((res.status || "").toUpperCase() === "SUCCESS") {
      status = "SUCCESS";
      direction = res.direction || "IN";
      payload = {
        gate_id: res.gate_id || gateConfig.gate_id,
        gate_name: gateConfig.gate_name,
        status,
        direction,
        person_type: "VISITOR",
        visitor_name: res.name || res.full_name || rfid_uid,
        visitor_id: res.visitor_id || res.id || rfid_uid,
        company: res.company_name || "--",
        registered_photo: resolvePhotoUrl(res.enrollment_photo_path) || null,
        live_photo: livePhotoBase64,
        pass_no: res.pass_no,
        status_text: res.status,
        valid_from: res.valid_from,
        valid_to: res.valid_to,
        smartphone_allowed: res.smartphone_allowed,
        laptop_allowed: res.laptop_allowed,
        ops_area_permitted: res.ops_area_permitted,
        allowed_gates: res.allowed_gates,
      };
    } else if (res.error_code === "E105") {
      log(`Gate not permitted here. Allowed gates: ${res.allowed_gates?.join(", ") || "none"}`);
    }
  } catch (err) {
    log("Live visitor auth failed, will try labour + offline:", err.message);
  }

  // -------- TRY LABOUR PATH --------
  if (!payload) {
    try {
      const lab = await postJson("authenticate-labour", {
        token_uid: rfid_uid,
        gate_id: gateConfig.gate_id,
        photo: livePhotoBase64,
      });
      if ((lab.status || "").toUpperCase() === "SUCCESS") {
        status = "SUCCESS";
        direction = lab.direction || "IN";
        payload = {
          gate_id: lab.gate_id || gateConfig.gate_id,
          gate_name: gateConfig.gate_name,
          status,
          direction,
          person_type: "LABOUR",
          visitor_name: lab.name || "Labour",
          visitor_id: lab.labour_id || rfid_uid,
          company: lab.supervisor_name || "--",
          registered_photo: null,
          live_photo: livePhotoBase64,
          pass_no: lab.token_uid,
          status_text: lab.status,
          valid_to: lab.valid_until,
        };
      }
    } catch (err) {
      log("Live labour auth failed:", err.message);
    }
  }

  // -------- OFFLINE FALLBACK (cached whitelist) --------
  if (!payload) {
    const entry = await syncAgent.evaluateAccess(rfid_uid);
    status = entry ? "SUCCESS" : "DENIED";
    const personId = entry?.visitor_id || entry?.person_id || null;
    const prevDir = personId ? lastDirection.get(personId) : null;
    direction = prevDir === "IN" ? "OUT" : "IN";
    if (personId) lastDirection.set(personId, direction);
    payload = {
      gate_id: gateConfig.gate_id,
      gate_name: gateConfig.gate_name,
      status,
      direction,
      person_type: entry?.person_type || "VISITOR",
      visitor_name: entry?.full_name || entry?.visitor_name || rfid_uid,
      visitor_id: entry?.pass_no || entry?.visitor_id || rfid_uid,
      company: entry?.company_name || "--",
      registered_photo: resolvePhotoUrl(entry?.enrollment_photo_path) || null,
      live_photo: livePhotoBase64,
      pass_no: entry?.pass_no,
      status_text: entry?.status,
      valid_from: entry?.valid_from || entry?.validity_from,
      valid_to: entry?.valid_to || entry?.validity || entry?.valid_until,
      smartphone_allowed: entry?.smartphone_allowed,
      laptop_allowed: entry?.laptop_allowed,
      ops_area_permitted: entry?.ops_area_permitted,
      last_synced: entry?.last_synced,
      gate_ids: entry?.gate_ids,
    };

    // persist offline log for later sync
    const accessLog = {
      person_type: entry?.person_type || "VISITOR",
      person_id: personId,
      rfid_uid,
      gate_id: gateConfig.gate_id,
      gate_name: gateConfig.gate_name,
      direction,
      status,
      scan_time: new Date().toISOString(),
      registered_photo: entry?.enrollment_photo_path || null,
      live_photo_base64: livePhotoBase64,
    };
    await syncAgent.submitAccessLog(accessLog);
  }

  await sendDisplayUpdate(payload);
  log(`Scan ${rfid_uid}: ${status}`);
};

const startScanLoop = () => {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  const ask = () => rl.question("Scan UID (or 'exit'): ", async (ans) => {
    if (!ans) return ask();
    if (ans.toLowerCase() === "exit") {
      rl.close();
      process.exit(0);
    }
    await handleScan(ans.trim());
    ask();
  });
  ask();
};

const main = async () => {
  await syncAgent.start();
  log("Sync agent started");
  startScanLoop();
};

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
