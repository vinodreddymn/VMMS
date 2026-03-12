# VMMS Site Access & Visitor Management — Customer Handout

## Part 1 — Plain‑English Overview

- **What it is:** A digital gate and visitor system. People tap an RFID card or token, the gate checks if they’re allowed, snaps a photo, and shows a green (entry) or red (exit) message on screen.
- **Who it covers:** Both **visitors** (with passes) and **labour staff** (with tokens). Each physical gate has its own screen; staff pick the gate once, visitors can’t change it.
- **How entry works:** Present card → system verifies → shows your name, photo match, and direction (IN/OUT). If something’s wrong, it says “Access Denied.”
- **Visitor management:** Create passes, set valid dates, assign a host, decide which gates they can use, and upload required documents/photos.
- **Labour management:** Issue/return RFID tokens, keep manifests, and track movements on site.
- **Dashboards:** Live views of today’s scans, gate load, and recent entries; a big-screen “Andon” view for control rooms.
- **Manual fallback:** If a card fails, staff can search the person and log a manual entry.
- **Health & reliability:** Gate health screen shows device IP/serial/status; a sync page pushes any queued scans if the network drops.
- **Reports & analytics:** Filterable tables (by date, gate, project, department, status) with CSV/PDF export, daily stats, gate performance, peak hours, risk scores, and muster counts.
- **Admin controls:** Manage users/roles, gates and entrances, projects/departments, visitor types, hosts, RFID stock, and blacklists.

## Part 2 — Technical Appendix (for IT/Engineering)

**Stack & Routing**
- React + Vite SPA; protected routes in `src/App.jsx` via `ProtectedRoute`. Public: `/login`, `/andon`, `/gate/display`; everything else under the main layout.

**Gate/Access Flow**
- Screen: `GateDisplay.jsx` (gate selection overlay → RFID input → camera capture).
- APIs: `POST /gate/authenticate` (visitors), `POST /gate/authenticate-labour` (labour); payload includes `gate_id`, RFID UID, base64 JPEG photo.
- Manual override: `POST /gate/manual-entry` from `ManualGateEntry.jsx`.
- Health/muster/search: `gate.api.js` (`/gate/health`, `/gate/muster`, `/gate/logs`, `/gate/search`).
- Gate selection persisted in `localStorage`; setup code via `VITE_GATE_SETUP_CODE` (default `VMMS-STAFF`).

**Visitor Module**
- Screens: list/detail/form/wizard, photo upload, RFID, biometric pages.
- Data: `/masters` provides projects, departments, visitorTypes, hosts, gates; `VisitorsDetail.jsx` renders `allowed_gates`.
- Transactions: `/analytics/transactions` with `person_type=VISITOR`; exports `/analytics/transactions/export-{csv,pdf}`.

**Labour Module**
- Screens: list/detail/form/manifest, token return, transactions (`person_type=LABOUR`).
- Token validation noted in `labour.api.js` (gate entry checks).

**Analytics & Dashboards**
- `analytics.api.js`: gate stats/performance, daily stats, peak hours, risk scores, visitor trends, muster, material & labour analytics, transaction exports.
- Used by `Dashboard.jsx`, `AdminDashboard.jsx`, `Analytics.jsx`, `GateLoadChart.jsx`, `EntryFeed.jsx`, `LiveMuster.jsx`.

**Administration**
- `admin.api.js`: CRUD for users, roles, gates (`/admin/gates`), entrances, projects, departments; RFID stock (visitor cards, labour tokens); blacklists.
- `AdminUsers.jsx` also edits entrances and gate metadata (name, entrance_id, IP, device_serial).

**Masters & Shared Data**
- `master.api.js` wraps `/masters`; backward-compatible helpers expose projects/departments/visitorTypes/hosts/gates.

**Security**
- Auth store `useAuthStore` keeps user and role (ADMIN/SUPER_ADMIN). `ProtectedRoute` redirects to `/login` if unauthenticated.

**Offline/Sync**
- `Sync.jsx` uses queue APIs (`getUnsyncedQueue`, `submitSyncQueue`) to push buffered `access_logs` per gate.

**Media & Files**
- Photos captured via `navigator.mediaDevices.getUserMedia`, 640×480 JPEG; file URLs resolved with `VITE_FILE_BASE_URL` or derived API base.

**Env Keys (frontend)**
- `VITE_API_BASE_URL`, `VITE_FILE_BASE_URL`, `VITE_GATE_SETUP_CODE`.

**Build/Run**
- Frontend: Vite dev server (`npm run dev`), production build via `npm run build`.
- Backend: `vmms_backend` provides the REST endpoints above (not detailed here).

**Data Model Touchpoint**
- `gates(id, gate_name, entrance_id, ip_address, device_serial, is_active)`; referenced by `access_logs`, `visitor_gate_permissions`, `gate_health`, etc. Access logs return `gate_name` for UI tables.
