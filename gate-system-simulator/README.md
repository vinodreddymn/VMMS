# Gate Access Control System Simulator

Simulates two independent gate devices talking to a single backend and pushing events to dedicated display screens. Everything runs on one machine using virtual loopback IPs.

## Architecture
- **Backend (Express + WebSocket)**: Master whitelist, receives scan events, stores access logs (in-memory fallback), broadcasts decisions over `ws://127.0.0.1:3000/display`.
- **Gate Clients (Gate 1 @ 127.0.0.2, Gate 2 @ 127.0.0.3)**: Periodically sync whitelist, simulate RFID scans + camera captures, apply local whitelist cache, post scans to backend.
- **Display UI (per gate)**: Static web page that listens to the display WebSocket and shows the latest scan for its gate.
- **Simulator tools**: Loopback IP setup guide and a convenience launcher script.

## Prerequisites
- Node.js 18+ (for native `fetch` + ES modules)
- Python (for the simple static file server used by `start-all.sh`)
- Optional: PostgreSQL + `DATABASE_URL` env variable (otherwise memory store is used)

## Install
```bash
cd gate-system-simulator
npm install
```

## Start everything (Linux/macOS with bash)
```bash
chmod +x simulator-tools/start-all.sh
./simulator-tools/start-all.sh
```
Logs go to `/tmp/gate-*.log`. Press Ctrl+C to stop all processes.

## Run manually (one terminal each)
```bash
npm run start:backend
npm run start:gate1
npm run start:gate2
python -m http.server 8080 --directory display-ui/gate-display
```

## Display screens
- Gate 1: open `http://127.0.0.1:8080?gate=1`
- Gate 2: open `http://127.0.0.1:8080?gate=2`

## Simulated behavior
- Each gate syncs whitelist every 5 minutes (`GET /api/sync/whitelist?since=<timestamp>`).
- Scan simulator emits a scan every 10 seconds with a random valid/invalid RFID and fake live photo path.
- Gate posts to `POST /api/gate/scan`; backend decides ACCESS GRANTED/DENIED and broadcasts to displays.
- Backend keeps in-memory whitelist/logs unless `DATABASE_URL` points to PostgreSQL.

## Virtual IPs
Add loopback aliases `127.0.0.2` and `127.0.0.3` so each gate can pretend to be a separate device. See `simulator-tools/ip-config-guide.md` for OS-specific commands.

## Key paths
- Backend: `backend/server.js`
- Gate clients: `gate-client/gate1/gateClient.js`, `gate-client/gate2/gateClient.js`
- Display UI: `display-ui/gate-display/index.html`
- Tools: `simulator-tools/start-all.sh`, `simulator-tools/ip-config-guide.md`

## Mock data
In-memory whitelist comes with two visitors (RFID12345, RFID67890). Random scans will sometimes match (ACCESS GRANTED) and sometimes not (ACCESS DENIED).
