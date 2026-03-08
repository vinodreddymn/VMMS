# VMMS Backend - Enterprise Access Control System

A comprehensive, zero-input gate authentication system with offline capabilities for enterprise visitor and labour management.

## Features

### 🎫 Visitor Management
- **Enrollment**: Register visitors with complete KYC (Aadhaar, PAN, Police Verification, Work Order)
- **Biometric Enrollment**: Fingerprint/thumb impression capture and verification
- **RFID Card Issuance**: Automatic PVC card generation with QR codes
- **Permission Management**: Smartphone, Laptop, and Operations Area permissions
- **Document Management**: Store and manage all KYC and renewal documents
- **Pass Validity**: Date-based pass validity with soft-lock mechanism

### 👥 Labour Management
- **Labour Registration**: Register labourers under supervisor
- **Token Assignment**: Daily reusable RFID/QR tokens
- **Manifest Generation**: Automated PDF manifests with supervisor photo and labour list
- **No-Show Detection**: Automatic alerting if labour doesn't enter facility within 60 mins of manifest printing
- **SMS Notifications**: Real-time alerts to project hosts/supervisors

### 🚪 Gate Authentication (Zero-Input Model)
- **RFID Tap-to-Enter**: Bi-directional access toggle (IN/OUT detection)
- **Biometric Verification**: Optional biometric matching for security
- **Live Photo Capture**: Automatic capture of live gate photos (compressed, auto-deleted)
- **Offline Mode**: Local SQLite cache for 5+ hours of offline operation
- **Master Whitelist Sync**: 5-minute automatic sync of valid personnel

### 🚫 Blacklist & Alerts
- **Global Blacklist**: Manage blacklisted Aadhaar, phone, and biometric hashes
- **Real-Time Alerts**: SMS to security head and project hosts when blacklisted person attempts entry
- **Block Reasons**: Track and manage detailed reason codes

### 📦 Material Management
- **Returnable Items Tracking**: Track inbound/outbound materials
- **Balance Ledger**: Automatic balance calculation with partial exit/entry support
- **Exit Alerts**: SMS alert to project host if visitor exits with pending returns

### 📊 Analytics & Reporting
- **Live Muster**: Real-time display of personnel currently inside
- **Daily Statistics**: Entry/exit counts, gate-wise breakdown
- **Project Analytics**: Visitor statistics per project/department
- **Access Logs**: Comprehensive filtering and search
- **Failed Attempt Tracking**: Monitor blacklist hits and access errors
- **PDF/Excel Export**: Role-based export (SECURITY_HEAD: PDF, SUPER_ADMIN: Excel)

### 🔐 Role-Based Access Control (RBAC)
- **SUPER_ADMIN**: Full system access, Excel export
- **SECURITY_HEAD**: View reports, manage blacklist, PDF export
- **ENROLLMENT_STAFF**: Visitor registration, document upload, manual override
- **GATE_MANAGER**: Gate configuration, health monitoring

### 🔄 Synchronization
- **Offline Sync Queue**: Store access logs and photos during offline period
- **Automatic Re-sync**: Push all cached data when connectivity restored
- **Master Whitelist**: Central whitelist pushed to gates every 5 minutes
- **Conflict-Free**: Prevents duplicate entries during sync

## Architecture

```
Frontend (GUI) 
    ↓
Edge Gate Cameras/Hardware
    ↓
Gate Mini-PC (Offline Buffer)
    ↓
VMMS Backend Server
    ↓
PostgreSQL (Primary)
Redis (Caching)
```

## Database Schema

### Core Tables
- `users` - System users with role-based access
- `roles` - Role definitions with permission flags
- `projects` - Project/site definitions
- `departments` - Department structures within projects
- `hosts` - Project hosts (contact persons)
- `entrances` - Main gates and sub-entrances
- `gates` - Individual gate devices

### Visitor Management
- `visitors` - Complete visitor profiles with all KYC data
- `visitor_documents` - KYC documents (Aadhaar, PV, WO, ASO forms)
- `visitor_types` - Visitor classification (Supervisor, Labour, Vendor, Internal)
- `biometric_data` - Biometric hashes (encrypted)
- `rfid_cards` - RFID card management (active/inactive/reissued)
- `card_reissue_log` - ASO-based card renewal tracking

### Labour Management
- `labours` - Labour registrations
- `labour_tokens` - Daily token assignments
- `labour_manifests` - Daily labour manifests (PDF stored)
- `manifest_labours` - Labour-manifest M:M relationship

### Access Control
- `access_logs` - **Partitioned** by date for performance
- `biometric_match_audit` - Biometric verification logs
- `material_transactions` - Inbound/outbound material tracking
- `material_balance` - Running balance for returnable items

### Security
- `blacklist` - Global blacklist with hashed identifiers
- `sms_logs` - All SMS communications with status

### Synchronization
- `sync_queue` - Offline queue for gate data push
- `master_whitelist` - Central whitelist for gate distribution

### Monitoring
- `gate_health` - Current gate status
- `gate_health_logs` - Historical gate health
- `visitor_status_audit` - Visitor status change audit trail

## API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout

### Visitor Management
- `POST /api/visitors` - Create visitor (enrollment)
- `GET /api/visitors` - List visitors with filters
- `GET /api/visitors/:id` - Get visitor details
- `PUT /api/visitors/:id` - Update visitor
- `POST /api/visitors/:id/documents` - Upload documents
- `GET /api/visitors/:id/documents` - Get documents
- `POST /api/visitors/:id/biometric` - Enroll biometric
- `POST /api/visitors/:id/rfid-card` - Issue RFID card

### Labour Management
- `POST /api/labour` - Register labour
- `GET /api/labour/supervisor/:id` - Get labours by supervisor
- `POST /api/labour/manifest` - Create daily manifest
- `GET /api/labour/manifest/:id` - Get manifest details
- `POST /api/labour/manifest/:id/pdf` - Generate PDF
- `POST /api/labour/check-noshows` - Check no-shows

### Gate Authentication
- `POST /api/gate/authenticate` - RFID authentication
- `POST /api/gate/authenticate-labour` - Labour token auth
- `POST /api/gate/manual-checkin` - Manual check-in override
- `POST /api/gate/health` - Submit gate health metrics
- `GET /api/gate/health/:gate_id` - Get gate health
- `GET /api/gate/muster` - Get live muster
- `GET /api/gate/logs` - Get access logs

### Material Management
- `POST /api/materials` - Create material master
- `GET /api/materials` - Get materials
- `POST /api/materials/transaction` - Record transaction
- `GET /api/materials/balance/:visitor_id` - Get balance
- `GET /api/materials/pending-returns` - Get pending returns

### Blacklist
- `POST /api/blacklist` - Add to blacklist (Security Head)
- `GET /api/blacklist` - Get blacklist entries
- `DELETE /api/blacklist/:id` - Remove from blacklist
- `POST /api/blacklist/check` - Check if blacklisted

### Analytics & Reports
- `GET /api/analytics/muster` - Live muster
- `GET /api/analytics/daily-stats` - Daily statistics
- `GET /api/analytics/gate-load` - Gate-wise load
- `GET /api/analytics/project-stats` - Project-wise stats
- `GET /api/analytics/search` - Advanced visitor search
- `GET /api/analytics/failed-attempts` - Failed access attempts
- `GET /api/analytics/blacklist-incidents` - Blacklist incidents
- `GET /api/reports/export-pdf` - Export PDF (SECURITY_HEAD)
- `GET /api/reports/export-excel` - Export Excel (SUPER_ADMIN)

### Synchronization
- `GET /api/sync/whitelist` - Get master whitelist (for gates)
- `POST /api/sync/queue` - Submit synced data
- `GET /api/sync/queue` - Get unsynced items
- `POST /api/sync/mark-synced` - Mark as synced

### Administration
- `POST /api/admin/users` - Create admin user
- `GET /api/admin/users` - List users
- `PUT /api/admin/users/:id` - Update user
- `DELETE /api/admin/users/:id` - Deactivate user
- `POST /api/admin/projects` - Create project
- `GET /api/admin/projects` - Get projects
- `POST /api/admin/departments` - Create department
- `POST /api/admin/hosts` - Create host
- `GET /api/admin/hosts` - Get hosts
- `POST /api/admin/gates` - Create gate
- `GET /api/admin/gates` - Get gates

## Installation

```bash
# Install dependencies
npm install

# Create uploads and exports directories
mkdir -p uploads exports

# Set environment variables (see .env.example)
cp .env.example .env
# Edit .env with your database credentials

# Initialize database
psql -U postgres -d vmms_db -f migrations/001_init_schema.sql

# Start server
npm start

# Development with nodemon
npm run dev
```

## Environment Variables

```env
# Server
PORT=5000
NODE_ENV=development
JWT_SECRET=your-super-secret-jwt-key

# Database
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_password
DB_NAME=vmms_db

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# Encryption
ENCRYPTION_KEY=your-256-bit-key-do-not-use-in-prod

# SMS Provider (Optional)
SMS_PROVIDER=console  # or 'twilio', 'aws'
# For Twilio:
# TWILIO_ACCOUNT_SID=...
# TWILIO_AUTH_TOKEN=...
# TWILIO_FROM_NUMBER=...
```

## Cron Jobs

1. **No-Show Detection** (Every 10 minutes)
   - Checks if registered labourers entered within 60 mins of manifest printing
   - Sends SMS alert to project host if no-show detected

2. **Material Balance Check** (Every 30 minutes)
   - Periodic check for pending material returns
   - Logs warnings for items not yet returned

3. **Master Whitelist Distribution** (Every 5 minutes)
   - Automatically pushes updated whitelist to all gates
   - Ensures gates always have latest permissions

## Security Considerations

1. **Aadhaar Encryption**: AES-256-CBC encryption at rest
2. **Biometric Hashing**: SHA-256 hashing (not storable images)
3. **Password Hashing**: bcrypt with salt rounds=10
4. **JWT Tokens**: Expiry set to 8 hours
5. **RBAC**: Fine-grained role-based access control
6. **Audit Logging**: All status changes tracked with user and timestamp
7. **Blacklist Validation**: Real-time check during enrollment and access

## Performance Optimization

1. **Database Indexing**: Indexes on frequently queried columns
2. **Partitioned Access Logs**: Partitioned by date for faster queries
3. **Caching**: Redis for session and whitelist caching
4. **Pagination**: Limits for all list endpoints
5. **Compression**: Live photos compressed before storage
6. **Auto-deletion**: Photos deleted after 90 days automatically

## Monitoring & Maintenance

1. **Gate Health Dashboard**: Real-time CPU, memory, storage, device status
2. **Access Log Archives**: Automatic archival of historical access logs
3. **Sync Queue Monitoring**: Track pending syncs from gates
4. **SMS Log Tracking**: Monitor all SMS communications

## Deployment

### Docker
```bash
# Build
docker build -t vmms-backend .

# Run
docker run -p 5000:5000 \
  -e DATABASE_URL=postgres://user:pass@db:5432/vmms_db \
  vmms-backend
```

### Process Manager (PM2)
```bash
pm2 start src/server.js --name vmms-backend
pm2 save
pm2 startup
```

## License

Licensed under the ISC License.

## Support

For issues, feature requests, or contributions, please contact the development team.
