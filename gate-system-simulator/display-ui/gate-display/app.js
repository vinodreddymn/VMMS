const params = new URLSearchParams(window.location.search);
const gateId = Number(params.get('gate') || 1);
const serverHost = params.get('server') || '127.0.0.1:3000';
const wsUrl = `ws://${serverHost}/display`;

const els = {
  gateName: document.getElementById('gateName'),
  status: document.getElementById('status'),
  clock: document.getElementById('clock'),
  registeredPhoto: document.getElementById('registeredPhoto'),
  livePhoto: document.getElementById('livePhoto'),
  visitorName: document.getElementById('visitorName'),
  visitorId: document.getElementById('visitorId'),
  company: document.getElementById('company'),
};

const placeholder = (text) =>
  `data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='480' height='320'><rect width='100%' height='100%' fill='%23222'/><text x='50%' y='50%' dominant-baseline='middle' text-anchor='middle' fill='white' font-family='Arial' font-size='28'>${encodeURIComponent(
    text
  )}</text></svg>`;

const resetUi = () => {
  els.gateName.textContent = `Gate ${gateId}`;
  els.status.textContent = 'WAITING...';
  els.status.className = 'status';
  els.registeredPhoto.src = placeholder('Registered');
  els.livePhoto.src = placeholder('Live');
  els.visitorName.textContent = '--';
  els.visitorId.textContent = '--';
  els.company.textContent = '--';
};

resetUi();

const applyEvent = (evt) => {
  els.gateName.textContent = evt.gate_name || `Gate ${gateId}`;
  els.status.textContent = evt.status;
  els.status.className = `status ${evt.status?.includes('GRANTED') ? 'granted' : 'denied'}`;
  els.registeredPhoto.src = evt.registered_photo || placeholder('Registered');
  els.livePhoto.src = evt.live_photo || placeholder('Live');
  els.visitorName.textContent = evt.visitor_name;
  els.visitorId.textContent = evt.visitor_id;
  els.company.textContent = evt.company;
};

const connectWs = () => {
  const ws = new WebSocket(wsUrl);
  ws.addEventListener('open', () => {
    console.log('Display connected', wsUrl);
  });
  ws.addEventListener('message', (msg) => {
    const evt = JSON.parse(msg.data);
    if (evt.gate_id === gateId) {
      applyEvent(evt);
    }
  });
  ws.addEventListener('close', () => setTimeout(connectWs, 2000));
  ws.addEventListener('error', () => ws.close());
};

connectWs();

setInterval(() => {
  const now = new Date();
  els.clock.textContent = now.toLocaleTimeString();
}, 1000);
