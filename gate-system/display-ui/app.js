const params = new URLSearchParams(window.location.search);
const gateParam = params.get("gate");
const gateId = gateParam ? Number(gateParam) : null; // null means accept all gates
const serverHost = params.get("server") || "127.0.0.1:3200";
const wsUrl = `ws://${serverHost}/display`;

const toImgSrc = (val) => {
  if (!val) return null;
  if (val.startsWith("data:")) return val;
  if (val.startsWith("http://") || val.startsWith("https://")) return val;
  const normalizedHost = serverHost.replace(/^https?:\/\//, "");
  const trimmed = val.replace(/^\/+/, "");
  return `${window.location.protocol}//${normalizedHost}/${trimmed}`;
};

const formatDate = (val) => {
  if (!val) return "--";
  const d = typeof val === "number" ? new Date(val) : new Date(String(val));
  if (isNaN(d.getTime())) return "--";
  return d.toLocaleString();
};

const setPill = (el, allowed, label) => {
  el.classList.remove("ok", "no");
  let text = `${label}: --`;
  if (allowed === true) {
    el.classList.add("ok");
    text = `${label}: Allowed`;
  } else if (allowed === false) {
    el.classList.add("no");
    text = `${label}: Not Allowed`;
  }
  el.textContent = text;
};

const collectEls = () => ({
  gateName: document.getElementById("gateName"),
  gateChip: document.getElementById("gateChip"),
  direction: document.getElementById("direction"),
  lane: document.getElementById("lane"),
  passType: document.getElementById("passType"),
  lastSeen: document.getElementById("lastSeen"),
  status: document.getElementById("status"),
  clock: document.getElementById("clock"),
  registeredPhoto: document.getElementById("registeredPhoto"),
  livePhoto: document.getElementById("livePhoto"),
  visitorName: document.getElementById("visitorName"),
  visitorId: document.getElementById("visitorId"),
  company: document.getElementById("company"),
  passNo: document.getElementById("passNo"),
  passStatus: document.getElementById("passStatus"),
  validFrom: document.getElementById("validFrom"),
  validTo: document.getElementById("validTo"),
  matchScore: document.getElementById("matchScore"),
  matchBar: document.getElementById("matchBar"),
  smartphone: document.getElementById("smartphone"),
  laptop: document.getElementById("laptop"),
  opsArea: document.getElementById("opsArea"),
  lastSynced: document.getElementById("lastSynced"),
  remarks: document.getElementById("remarks"),
});

let els = collectEls();

const setText = (el, value) => {
  if (el) el.textContent = value;
};

const placeholder = (text) =>
  `data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='480' height='320'><rect width='100%' height='100%' fill='%23222'/><text x='50%' y='50%' dominant-baseline='middle' text-anchor='middle' fill='white' font-family='Arial' font-size='28'>${encodeURIComponent(
    text
  )}</text></svg>`;

const resetUi = () => {
  const gateLabel = gateId ? `Gate ${gateId}` : "All Gates";
  setText(els.gateName, gateLabel);
  setText(els.gateChip, gateLabel);
  setText(els.direction, "--");
  setText(els.lane, "--");
  setText(els.passType, "--");
  setText(els.lastSeen, "--");
  setText(els.status, "WAITING...");
  if (els.status) els.status.className = "status";
  if (els.registeredPhoto) els.registeredPhoto.src = placeholder("Registered");
  if (els.livePhoto) els.livePhoto.src = placeholder("Live");
  setText(els.visitorName, "--");
  setText(els.visitorId, "--");
  setText(els.company, "--");
  setText(els.passNo, "--");
  setText(els.passStatus, "--");
  setText(els.validFrom, "--");
  setText(els.validTo, "--");
  setText(els.matchScore, "--");
  if (els.matchBar) els.matchBar.style.width = "0%";
  setPill(els.smartphone, null, "Smartphone");
  setPill(els.laptop, null, "Laptop");
  setPill(els.opsArea, null, "Ops Area");
  setText(els.lastSynced, "--");
  setText(els.remarks, "--");
};

resetUi();
document.addEventListener("header:loaded", () => {
  els = collectEls();
  resetUi();
});

const applyEvent = (evt) => {
  const gateLabel =
    evt.gate_name ||
    (evt.gate_id ? `Gate ${evt.gate_id}` : gateId ? `Gate ${gateId}` : "All Gates");
  setText(els.gateName, gateLabel);
  setText(els.gateChip, gateLabel);
  setText(els.direction, evt.direction || evt.flow || "--");
  setText(els.lane, evt.lane || evt.lane_no || "--");
  setText(els.passType, evt.pass_type || evt.category || "--");
  setText(els.lastSeen, formatDate(evt.last_seen || evt.timestamp || evt.event_time));
  setText(els.status, evt.status);
  const statusUpper = (evt.status || "").toUpperCase();
  let statusClass = "status";
  if (statusUpper.includes("WAIT")) statusClass += " waiting";
  else if (statusUpper.includes("SUCCESS") || statusUpper.includes("APPROVED")) statusClass += " success";
  else if (statusUpper) statusClass += " denied";
  if (els.status) els.status.className = statusClass;

  const registered =
    toImgSrc(evt.registered_photo) ||
    toImgSrc(evt.enrollment_photo_path) ||
    toImgSrc(evt.registered_photo_base64) ||
    null;
  if (els.registeredPhoto) els.registeredPhoto.src = registered || placeholder("Registered");

  const live =
    toImgSrc(evt.live_photo) ||
    toImgSrc(evt.live_photo_base64) ||
    null;
  if (els.livePhoto) els.livePhoto.src = live || placeholder("Live");
  setText(els.visitorName, evt.visitor_name || "--");
  setText(els.visitorId, evt.visitor_id || "--");
  setText(els.company, evt.company || "--");
  setText(els.passNo, evt.pass_no || evt.pass || "--");
  setText(els.passStatus, evt.status_text || evt.pass_status || "--");
  setText(els.validFrom, formatDate(evt.valid_from));
  setText(els.validTo, formatDate(evt.valid_to));

  const score = Number(evt.match_score);
  if (!isNaN(score)) {
    const pct = Math.max(0, Math.min(100, score));
    setText(els.matchScore, `${pct}%`);
    if (els.matchBar) els.matchBar.style.width = `${pct}%`;
  } else {
    setText(els.matchScore, "--");
    if (els.matchBar) els.matchBar.style.width = "0%";
  }

  setPill(els.smartphone, evt.smartphone_allowed, "Smartphone");
  setPill(els.laptop, evt.laptop_allowed, "Laptop");
  setPill(els.opsArea, evt.ops_area_permitted, "Ops Area");
  setText(els.lastSynced, formatDate(evt.last_synced));

  setText(els.remarks, evt.remarks || evt.alert || "No alerts.");
};

const connectWs = () => {
  const ws = new WebSocket(wsUrl);
  ws.addEventListener("open", () => console.log("Display connected", wsUrl));
  ws.addEventListener("message", (msg) => {
    const evt = JSON.parse(msg.data);
    console.log("Display event", evt);
    applyEvent(evt); // accept all gates; UI shows gate label per event
  });
  ws.addEventListener("close", () => setTimeout(connectWs, 2000));
  ws.addEventListener("error", () => ws.close());
};

connectWs();

setInterval(() => {
  const now = new Date();
  els.clock.textContent = now.toLocaleTimeString();
}, 1000);

function updateDateTime() {
  const now = new Date();

  const dateOptions = { 
    weekday: 'short', 
    year: 'numeric', 
    month: 'short', 
    day: 'numeric' 
  };

  document.getElementById("date").innerText =
    now.toLocaleDateString("en-IN", dateOptions);

  document.getElementById("clock").innerText =
    now.toLocaleTimeString("en-IN");
}

setInterval(updateDateTime, 1000);
updateDateTime();
