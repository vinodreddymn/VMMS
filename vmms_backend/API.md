# VMMS Backend API Documentation

## Base URL
```
http://localhost:5000/api
```

## Authentication

All protected endpoints require a Bearer token in the Authorization header:

```
Authorization: Bearer <JWT_TOKEN>
```

## Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request (validation error)
- `401` - Unauthorized (missing/invalid token)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found
- `409` - Conflict (duplicate entry)
- `500` - Internal Server Error

## Response Format

### Success Response
```json
{
  "success": true,
  "data": {},
  "message": "Operation successful"
}
```

### Error Response
```json
{
  "success": false,
  "error": "Error message",
  "code": "ERROR_CODE",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

## Authentication Endpoints

### Login
```
POST /auth/login
Content-Type: application/json

Request:
{
  "username": "admin",
  "password": "Admin@123"
}

Response:
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "username": "admin",
      "email": "admin@vmms.com",
      "role": "SUPER_ADMIN",
      "can_export_pdf": true,
      "can_export_excel": true
    },
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "expiresIn": "8h"
  }
}
```

### Logout
```
POST /auth/logout
Authorization: Bearer <TOKEN>

Response:
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

## Visitor Endpoints

### Create Visitor (Enrollment)
```
POST /visitors
Authorization: Bearer <TOKEN>
Content-Type: application/json
Required Role: ENROLLMENT_STAFF, SECURITY_HEAD, SUPER_ADMIN

Request:
{
  "first_name": "John",
  "last_name": "Doe",
  "aadhaar": "123456789012",
  "mobile_number": "9876543210",
  "email": "john@example.com",
  "project_id": 1,
  "visitor_type_id": 2,
  "can_carry_smartphone": true,
  "can_carry_laptop": false,
  "can_access_operations_area": true,
  "valid_from": "2024-01-15",
  "valid_to": "2024-01-31",
  "remarks": "Regular vendor"
}

Response:
{
  "success": true,
  "data": {
    "visitor_id": 101,
    "pass_no": "PASS20240115001",
    "first_name": "John",
    "last_name": "Doe",
    "aadhaar_last4": "9012",
    "status": "ACTIVE",
    "created_at": "2024-01-15T10:30:00Z"
  }
}

Note: Automatically checks blacklist before creating. Returns 403 if blacklisted.
```

### List Visitors
```
GET /visitors?page=1&limit=20&project_id=1&status=ACTIVE&name=John
Authorization: Bearer <TOKEN>

Query Parameters:
- page: Page number (default: 1)
- limit: Records per page (default: 20)
- project_id: Filter by project
- status: ACTIVE, BLOCKED, EXPIRED
- name: Search by first/last name
- phone: Search by phone
- aadhaar_last4: Search by Aadhaar last 4 digits
- from_date: From date (YYYY-MM-DD)
- to_date: To date (YYYY-MM-DD)

Response:
{
  "success": true,
  "data": [
    {
      "visitor_id": 101,
      "pass_no": "PASS20240115001",
      "full_name": "John Doe",
      "mobile_number": "9876543210",
      "project_name": "Test Site",
      "status": "ACTIVE",
      "valid_from": "2024-01-15",
      "valid_to": "2024-01-31",
      "can_carry_smartphone": true,
      "can_carry_laptop": false,
      "can_access_operations_area": true
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "pages": 8
  }
}
```

### Get Visitor Details
```
GET /visitors/:visitor_id
Authorization: Bearer <TOKEN>

Response: (Complete visitor object with all permissions and dates)
```

### Update Visitor
```
PUT /visitors/:visitor_id
Authorization: Bearer <TOKEN>
Content-Type: application/json
Required Role: ENROLLMENT_STAFF, SECURITY_HEAD, SUPER_ADMIN

Request: (Any subset of fields from create endpoint)
{
  "can_carry_smartphone": false,
  "valid_to": "2024-02-15"
}

Response: (Updated visitor object)
```

### Upload Document
```
POST /visitors/:visitor_id/documents
Authorization: Bearer <TOKEN>
Content-Type: multipart/form-data
Required Role: ENROLLMENT_STAFF, SECURITY_HEAD, SUPER_ADMIN

Form Data:
- file: <binary file>
- doc_type: AADHAAR, PAN, POLICE_VERIFICATION, WORK_ORDER, ASO_RENEWAL, ASO_EXTENSION
- remarks: (optional)

Response:
{
  "success": true,
  "data": {
    "document_id": 1001,
    "visitor_id": 101,
    "doc_type": "AADHAAR",
    "file_name": "aadhaar_101.pdf",
    "file_path": "uploads/documents/aadhaar_101.pdf",
    "uploaded_at": "2024-01-15T10:30:00Z"
  }
}
```

### Get Documents
```
GET /visitors/:visitor_id/documents
Authorization: Bearer <TOKEN>

Response:
{
  "success": true,
  "data": [
    {
      "document_id": 1001,
      "doc_type": "AADHAAR",
      "file_name": "aadhaar_101.pdf",
      "uploaded_at": "2024-01-15T10:30:00Z",
      "download_url": "/api/documents/1001/download"
    }
  ]
}
```

### Enroll Biometric
```
POST /visitors/:visitor_id/biometric
Authorization: Bearer <TOKEN>
Content-Type: application/json
Required Role: ENROLLMENT_STAFF, SUPER_ADMIN

Request:
{
  "biometric_data": "raw_fingerprint_data_base64_encoded",
  "biometric_algorithm": "FINGERPRINT_V2",
  "finger": "RIGHT_THUMB"
}

Response:
{
  "success": true,
  "data": {
    "biometric_id": 2001,
    "visitor_id": 101,
    "biometric_hash": "sha256_hash_value",
    "algorithm": "FINGERPRINT_V2",
    "finger": "RIGHT_THUMB",
    "enrolled_at": "2024-01-15T10:30:00Z"
  }
}
```

### Issue RFID Card
```
POST /visitors/:visitor_id/rfid-card
Authorization: Bearer <TOKEN>
Content-Type: application/json
Required Role: ENROLLMENT_STAFF, SUPER_ADMIN

Request:
{
  "card_type": "PVC_CARD",
  "validity_days": 365
}

Response:
{
  "success": true,
  "data": {
    "card_id": 3001,
    "visitor_id": 101,
    "card_uid": "f3a8c5b2-7d9e-4f1a-8c0b-3d5f8a2e7c1b",
    "card_number": "RFID0001",
    "qr_code": "data:image/png;base64,...",
    "issued_at": "2024-01-15T10:30:00Z",
    "valid_until": "2025-01-15"
  }
}

Note: Automatically triggers master whitelist update for gate sync.
```

---

## Labour Endpoints

### Create Labour
```
POST /labour
Authorization: Bearer <TOKEN>
Content-Type: application/json
Required Role: ENROLLMENT_STAFF, SUPER_ADMIN

Request:
{
  "supervisor_id": 101,
  "first_name": "Ram",
  "last_name": "Kumar",
  "aadhaar": "987654321098",
  "mobile_number": "9123456789",
  "project_id": 1,
  "shift": "DAY"
}

Response:
{
  "success": true,
  "data": {
    "labour_id": 201,
    "supervisor_id": 101,
    "supervisor_name": "John Doe",
    "first_name": "Ram",
    "last_name": "Kumar",
    "status": "ACTIVE",
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

### Get Labours by Supervisor
```
GET /labour/supervisor/:supervisor_id
Authorization: Bearer <TOKEN>

Response:
{
  "success": true,
  "data": [
    {
      "labour_id": 201,
      "full_name": "Ram Kumar",
      "mobile_number": "9123456789",
      "shift": "DAY",
      "status": "ACTIVE"
    }
  ]
}
```

### Create Manifest
```
POST /labour/manifest
Authorization: Bearer <TOKEN>
Content-Type: application/json
Required Role: ENROLLMENT_STAFF, SUPER_ADMIN

Request:
{
  "supervisor_id": 101,
  "project_id": 1,
  "manifest_date": "2024-01-15",
  "shift": "DAY",
  "labour_ids": [201, 202, 203]
}

Response:
{
  "success": true,
  "data": {
    "manifest_id": 301,
    "supervisor_id": 101,
    "supervisor_name": "John Doe",
    "project_id": 1,
    "total_labours": 3,
    "status": "CREATED",
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

### Get Manifest Details
```
GET /labour/manifest/:manifest_id
Authorization: Bearer <TOKEN>

Response:
{
  "success": true,
  "data": {
    "manifest_id": 301,
    "supervisor_name": "John Doe",
    "supervisor_photo": "base64_encoded_image",
    "total_labours": 3,
    "labours": [
      {
        "labour_id": 201,
        "full_name": "Ram Kumar",
        "mobile_number": "9123456789"
      }
    ],
    "status": "CREATED|SIGNED",
    "signed_at": "2024-01-15T11:00:00Z",
    "pdf_path": "exports/manifest_301.pdf"
  }
}
```

### Generate Manifest PDF
```
POST /labour/manifest/:manifest_id/pdf
Authorization: Bearer <TOKEN>
Required Role: ENROLLMENT_STAFF, SUPER_ADMIN

Response:
{
  "success": true,
  "data": {
    "manifest_id": 301,
    "pdf_url": "exports/manifest_301.pdf",
    "pdf_path": "/api/exports/manifest_301.pdf",
    "generated_at": "2024-01-15T11:00:00Z"
  }
}

Note: PDF includes supervisor photo, labour list in tabular format, signature line, and date.
Automatically signs manifest and sends SMS to host with labour count.
```

### Check No-Shows
```
POST /labour/check-noshows
Authorization: Bearer <TOKEN>
Required Role: SECURITY_HEAD, SUPER_ADMIN

Response:
{
  "success": true,
  "data": {
    "no_shows": [
      {
        "manifest_id": 301,
        "labour_id": 201,
        "full_name": "Ram Kumar",
        "printed_at": "2024-01-15T10:30:00Z",
        "expected_entry_by": "2024-01-15T11:30:00Z",
        "alert_sent": true
      }
    ],
    "count": 1
  }
}

Note: Runs automatically every 10 minutes. Detects labour not scanned within 60 mins of manifest printing.
```

---

## Gate Endpoints

### Authenticate Visitor (RFID/Biometric)
```
POST /gate/authenticate
Content-Type: application/json
(No Authentication Required - Edge Computing)

Request:
{
  "card_uid": "f3a8c5b2-7d9e-4f1a-8c0b-3d5f8a2e7c1b",
  "gate_id": 1,
  "biometric_data": "optional_fingerprint_data" (optional)
}

Response:
{
  "success": true,
  "data": {
    "visitor_id": 101,
    "full_name": "John Doe",
    "pass_no": "PASS20240115001",
    "direction": "IN",
    "gate_name": "Main Entrance",
    "live_photo": "base64_encoded_image",
    "permissions": {
      "can_carry_smartphone": true,
      "can_carry_laptop": false,
      "can_access_operations_area": true
    },
    "scanned_at": "2024-01-15T10:30:00Z"
  }
}

Possible Errors:
- 403 Blacklisted:
  {
    "success": false,
    "error": "Person is blacklisted",
    "code": "BLACKLIST_BLOCKED",
    "reason": "Security concern"
  }
- 403 Expired:
  {
    "success": false,
    "error": "Pass validity expired",
    "code": "PASS_EXPIRED"
  }
```

### Authenticate Labour Token
```
POST /gate/authenticate-labour
Content-Type: application/json
(No Authentication Required - Edge Computing)

Request:
{
  "token_uid": "labour_token_string",
  "gate_id": 1
}

Response:
{
  "success": true,
  "data": {
    "labour_id": 201,
    "full_name": "Ram Kumar",
    "supervisor_name": "John Doe",
    "direction": "IN",
    "gate_name": "Main Entrance",
    "manifest_id": 301,
    "scanned_at": "2024-01-15T10:30:00Z"
  }
}
```

### Manual Check-In
```
POST /gate/manual-checkin
Authorization: Bearer <TOKEN>
Content-Type: application/json
Required Role: ENROLLMENT_STAFF

Request:
{
  "visitor_id": 101,
  "gate_id": 1,
  "direction": "IN",
  "remarks": "Manual override by staff"
}

Response:
{
  "success": true,
  "data": {
    "access_log_id": 1001,
    "visitor_id": 101,
    "direction": "IN",
    "manual_override": true,
    "performed_by_user": 1,
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

### Update Gate Health
```
POST /gate/health
Content-Type: application/json
(No Authentication Required - Gate Reports Status)

Request:
{
  "gate_id": 1,
  "cpu_usage": 45.2,
  "memory_usage": 62.1,
  "storage_usage": 78.5,
  "camera_status": "ONLINE",
  "rfid_status": "ONLINE",
  "biometric_status": "OFFLINE"
}

Response:
{
  "success": true,
  "message": "Health metrics updated"
}
```

### Get Gate Health
```
GET /gate/health/:gate_id
Authorization: Bearer <TOKEN>

Response:
{
  "success": true,
  "data": {
    "gate_id": 1,
    "gate_name": "Main Entrance",
    "status": "ONLINE",
    "cpu_usage": 45.2,
    "memory_usage": 62.1,
    "storage_usage": 78.5,
    "camera_status": "ONLINE",
    "rfid_status": "ONLINE",
    "biometric_status": "OFFLINE",
    "last_heartbeat": "2024-01-15T10:30:00Z"
  }
}
```

### Get Live Muster
```
GET /gate/muster
Authorization: Bearer <TOKEN>
Required Role: SECURITY_HEAD, SUPER_ADMIN

Response:
{
  "success": true,
  "data": {
    "current_occupancy": 45,
    "persons_inside": [
      {
        "visitor_id": 101,
        "full_name": "John Doe",
        "entry_time": "2024-01-15T09:30:00Z",
        "pass_no": "PASS20240115001",
        "entry_gate": "Main Entrance",
        "last_seen_gate": "Main Entrance"
      }
    ],
    "as_of": "2024-01-15T10:30:00Z"
  }
}
```

### Get Access Logs
```
GET /gate/logs?visitor_id=101&gate_id=1&from_date=2024-01-01&to_date=2024-01-31&page=1&limit=20
Authorization: Bearer <TOKEN>

Query Parameters:
- visitor_id: Filter by visitor
- gate_id: Filter by gate
- direction: IN or OUT
- status: SUCCESS, FAILED
- from_date: From date (YYYY-MM-DD)
- to_date: To date (YYYY-MM-DD)
- page: Page number (default: 1)
- limit: Records per page (default: 20)

Response:
{
  "success": true,
  "data": [
    {
      "access_log_id": 1001,
      "visitor_id": 101,
      "full_name": "John Doe",
      "gate_name": "Main Entrance",
      "direction": "IN",
      "status": "SUCCESS",
      "scan_time": "2024-01-15T10:30:00Z",
      "manual_override": false
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150
  }
}
```

---

## Material Endpoints

### Create Material Master
```
POST /materials
Authorization: Bearer <TOKEN>
Content-Type: application/json
Required Role: SUPER_ADMIN

Request:
{
  "category": "TOOLS",
  "make": "Stanley",
  "model": "TIM-100",
  "serial_number": "SN123456",
  "description": "Power Drill",
  "is_returnable": true,
  "unit": "Piece"
}

Response:
{
  "success": true,
  "data": {
    "material_id": 401,
    "category": "TOOLS",
    "make": "Stanley",
    "model": "TIM-100",
    "description": "Power Drill",
    "is_returnable": true
  }
}
```

### Record Transaction
```
POST /materials/transaction
Authorization: Bearer <TOKEN>
Content-Type: application/json
Required Role: SECURITY_HEAD, ENROLLMENT_STAFF, SUPER_ADMIN

Request:
{
  "visitor_id": 101,
  "material_id": 401,
  "quantity": 2,
  "direction": "OUT",
  "remarks": "Issued for site work",
  "issued_by_user": 1
}

Response:
{
  "success": true,
  "data": {
    "transaction_id": 701,
    "visitor_id": 101,
    "material_id": 401,
    "quantity": 2,
    "direction": "OUT",
    "new_balance": 3,
    "transaction_time": "2024-01-15T10:30:00Z"
  }
}

Note: If direction=OUT and is_returnable=true, alert sent to host if balance remains positive.
```

### Get Material Balance
```
GET /materials/balance/:visitor_id
Authorization: Bearer <TOKEN>

Response:
{
  "success": true,
  "data": {
    "visitor_id": 101,
    "visitor_name": "John Doe",
    "materials": [
      {
        "material_id": 401,
        "description": "Power Drill",
        "category": "TOOLS",
        "current_balance": 3,
        "is_returnable": true,
        "last_transaction": "2024-01-15T10:30:00Z"
      }
    ]
  }
}
```

### Get Pending Returns
```
GET /materials/pending-returns
Authorization: Bearer <TOKEN>
Required Role: SECURITY_HEAD, SUPER_ADMIN

Response:
{
  "success": true,
  "data": [
    {
      "material_id": 401,
      "description": "Power Drill",
      "visitor_id": 101,
      "visitor_name": "John Doe",
      "project_id": 1,
      "project_name": "Test Site",
      "host_phone": "9876543210",
      "pending_quantity": 3,
      "days_pending": 5,
      "alert_sent": true
    }
  ]
}
```

---

## Blacklist Endpoints

### Add to Blacklist
```
POST /blacklist
Authorization: Bearer <TOKEN>
Content-Type: application/json
Required Role: SECURITY_HEAD, SUPER_ADMIN

Request:
{
  "aadhaar": "123456789012",
  "phone": "9876543210",
  "biometric_hash": "optional_hash",
  "reason": "Security concern - previous incident",
  "block_type": "TEMPORARY",  # or PERMANENT
  "validity_days": 30
}

Response:
{
  "success": true,
  "data": {
    "blacklist_id": 601,
    "aadhaar_hash": "hashed_value",
    "phone": "9876543210",
    "reason": "Security concern",
    "block_type": "TEMPORARY",
    "valid_until": "2024-02-14",
    "created_at": "2024-01-15T10:30:00Z",
    "blocked_by": "security_head_user"
  }
}
```

### Check Blacklist
```
POST /blacklist/check
Content-Type: application/json
(No Authentication Required - Used During Enrollment & Gate Auth)

Request:
{
  "aadhaar": "123456789012",
  "phone": "9876543210",
  "biometric_hash": "optional_hash"
}

Response:
{
  "success": true,
  "data": {
    "is_blacklisted": true,
    "entries": [
      {
        "reason": "Security concern",
        "block_type": "PERMANENT",
        "created_date": "2024-01-15"
      }
    ]
  }
}
```

### Get Blacklist Entries
```
GET /blacklist?page=1&limit=20&block_type=PERMANENT
Authorization: Bearer <TOKEN>
Required Role: SECURITY_HEAD, SUPER_ADMIN

Response:
{
  "success": true,
  "data": [
    {
      "blacklist_id": 601,
      "aadhaar_last4": "9012",
      "phone": "9876543210",
      "reason": "Security concern",
      "block_type": "PERMANENT",
      "created_at": "2024-01-15T10:30:00Z",
      "created_by": "security_head_user",
      "attempt_count": 3,
      "last_attempt": "2024-01-15T10:29:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45
  }
}
```

### Remove from Blacklist
```
DELETE /blacklist/:blacklist_id
Authorization: Bearer <TOKEN>
Required Role: SUPER_ADMIN

Response:
{
  "success": true,
  "message": "Removed from blacklist"
}
```

---

## Analytics & Reporting Endpoints

### Live Muster
```
GET /analytics/muster
Authorization: Bearer <TOKEN>
Required Role: SECURITY_HEAD, SUPER_ADMIN

Response:
{
  "success": true,
  "data": {
    "current_occupancy": 45,
    "max_capacity": 500,
    "occupancy_percentage": 9,
    "persons_inside": [...same as gate/muster...]
  }
}
```

### Daily Statistics
```
GET /analytics/daily-stats?date=2024-01-15&project_id=1
Authorization: Bearer <TOKEN>
Required Role: SECURITY_HEAD, SUPER_ADMIN

Query Parameters:
- date: Statistics date (YYYY-MM-DD), defaults to today
- project_id: (optional) Filter by project

Response:
{
  "success": true,
  "data": {
    "date": "2024-01-15",
    "total_entries": 120,
    "total_exits": 118,
    "labour_entries": 45,
    "visitor_entries": 75,
    "first_entry_time": "2024-01-15T06:30:00Z",
    "last_exit_time": "2024-01-15T18:30:00Z"
  }
}
```

### Gate Load Statistics
```
GET /analytics/gate-load?from_date=2024-01-01&to_date=2024-01-31
Authorization: Bearer <TOKEN>
Required Role: SECURITY_HEAD, SUPER_ADMIN

Response:
{
  "success": true,
  "data": [
    {
      "gate_id": 1,
      "gate_name": "Main Entrance",
      "total_scans": 1200,
      "inward_traffic": 600,
      "outward_traffic": 600,
      "failed_attempts": 5
    }
  ]
}
```

### Project Statistics
```
GET /analytics/project-stats?days=30
Authorization: Bearer <TOKEN>
Required Role: SECURITY_HEAD, SUPER_ADMIN

Query Parameters:
- days: Number of days to analyze (default: 30)

Response:
{
  "success": true,
  "data": [
    {
      "project_id": 1,
      "project_name": "Test Site",
      "unique_visitors": 150,
      "total_visits": 450,
      "repeat_visitors": 300,
      "active_visitors": 40
    }
  ]
}
```

### Search Visitors
```
GET /analytics/search?name=John&phone=9876&project_id=1&status=ACTIVE
Authorization: Bearer <TOKEN>

Query Parameters:
- name: Search by first/last name (ILIKE)
- phone: Search by phone (prefix match)
- aadhaar_last4: Search by last 4 digits
- project_id: Exact match on project
- status: ACTIVE, BLOCKED, EXPIRED
- from_date: From date (YYYY-MM-DD)
- to_date: To date (YYYY-MM-DD)
- page: Page number (default: 1)
- limit: Records per page (default: 20)

Response:
{
  "success": true,
  "data": [
    {
      "visitor_id": 101,
      "full_name": "John Doe",
      "mobile_number": "9876543210",
      "project_name": "Test Site",
      "status": "ACTIVE",
      "last_entry": "2024-01-15T10:30:00Z"
    }
  ],
  "pagination": {
    "total": 45,
    "page": 1,
    "pages": 3
  }
}
```

### Failed Attempts
```
GET /analytics/failed-attempts?from_date=2024-01-01&to_date=2024-01-31
Authorization: Bearer <TOKEN>
Required Role: SECURITY_HEAD, SUPER_ADMIN

Response:
{
  "success": true,
  "data": [
    {
      "attempt_id": 2001,
      "card_uid": "f3a8c5b2-7d9e-4f1a-8c0b-3d5f8a2e7c1b",
      "gate_name": "Main Entrance",
      "reason": "PASS_EXPIRED",
      "error_code": "EXPIRY_ERR",
      "attempt_time": "2024-01-15T10:30:00Z"
    }
  ]
}
```

### Blacklist Incidents
```
GET /analytics/blacklist-incidents?days=90
Authorization: Bearer <TOKEN>
Required Role: SECURITY_HEAD, SUPER_ADMIN

Response:
{
  "success": true,
  "data": [
    {
      "blacklist_id": 601,
      "aadhaar_last4": "9012",
      "phone": "9876543210",
      "reason": "Security concern",
      "attempt_count": 3,
      "first_attempt": "2024-01-10T10:30:00Z",
      "last_attempt": "2024-01-15T10:30:00Z",
      "alert_sent": true
    }
  ]
}
```

---

## Report Export Endpoints

### Export PDF
```
GET /reports/export-pdf?report_type=DAILY_STATS&from_date=2024-01-01&to_date=2024-01-31
Authorization: Bearer <TOKEN>
Required Role: SECURITY_HEAD, SUPER_ADMIN
Permission Required: can_export_pdf

Query Parameters:
- report_type: LIVE_MUSTER, DAILY_STATS, GATE_LOAD, PROJECT_STATS, VISITOR_SEARCH, FAILED_ATTEMPTS, BLACKLIST_INCIDENTS
- from_date: From date (YYYY-MM-DD)
- to_date: To date (YYYY-MM-DD)
- project_id: (optional) Filter by project

Response:
{
  "success": true,
  "data": {
    "pdf_url": "/exports/report_20240115.pdf",
    "file_name": "report_20240115.pdf",
    "generated_at": "2024-01-15T10:30:00Z",
    "report_type": "DAILY_STATS"
  }
}
```

### Export Excel
```
GET /reports/export-excel?from_date=2024-01-01&to_date=2024-01-31
Authorization: Bearer <TOKEN>
Required Role: SUPER_ADMIN
Permission Required: can_export_excel

Response:
{
  "success": true,
  "data": {
    "excel_url": "/exports/report_20240115.xlsx",
    "file_name": "report_20240115.xlsx",
    "sheets": ["Live Muster", "Daily Stats", "Gate Load", "Project Stats"],
    "generated_at": "2024-01-15T10:30:00Z"
  }
}

Note: Excel includes all report types in separate worksheets.
```

---

## Synchronization Endpoints

### Get Master Whitelist
```
GET /sync/whitelist?last_sync=2024-01-15T10:25:00Z
Content-Type: application/json
(No Authentication Required - Edge Computing)

Query Parameters:
- last_sync: Last synchronization timestamp (ISO format)

Response:
{
  "success": true,
  "data": {
    "timestamp": "2024-01-15T10:30:00Z",
    "entries": [
      {
        "visitor_id": 101,
        "card_uid": "f3a8c5b2-7d9e-4f1a-8c0b-3d5f8a2e7c1b",
        "full_name": "John Doe",
        "biometric_hash": "sha256_hash",
        "permissions": {
          "can_carry_smartphone": true,
          "can_carry_laptop": false,
          "can_access_operations_area": true
        },
        "valid_from": "2024-01-15",
        "valid_until": "2024-01-31",
        "status": "ACTIVE"
      }
    ],
    "total_entries": 250
  }
}
```

### Submit Synced Data
```
POST /sync/queue
Content-Type: application/json
(No Authentication Required - Edge Computing)

Request:
{
  "gate_id": 1,
  "sync_timestamp": "2024-01-15T10:30:00Z",
  "access_logs": [
    {
      "card_uid": "f3a8c5b2-7d9e-4f1a-8c0b-3d5f8a2e7c1b",
      "direction": "IN",
      "scan_time": "2024-01-15T10:30:00Z",
      "live_photo": "base64_encoded_compressed_image"
    }
  ]
}

Response:
{
  "success": true,
  "data": {
    "logs_processed": 5,
    "queue_id": "sync_queue_123",
    "synced_at": "2024-01-15T10:30:00Z"
  }
}
```

### Get Unsynced Queue
```
GET /sync/queue?gate_id=1
Authorization: Bearer <TOKEN>

Response:
{
  "success": true,
  "data": [
    {
      "queue_id": 1,
      "gate_id": 1,
      "access_logs": [...],
      "created_at": "2024-01-15T10:00:00Z",
      "synced": false
    }
  ]
}
```

---

## Administration Endpoints

### Create User
```
POST /admin/users
Authorization: Bearer <TOKEN>
Content-Type: application/json
Required Role: SUPER_ADMIN

Request:
{
  "username": "security_head",
  "email": "security@vmms.com",
  "password": "SecurePass123!",
  "role_id": 2,  # SECURITY_HEAD
  "full_name": "John Security Manager"
}

Response:
{
  "success": true,
  "data": {
    "user_id": 2,
    "username": "security_head",
    "email": "security@vmms.com",
    "role": "SECURITY_HEAD",
    "can_export_pdf": true,
    "can_export_excel": false,
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

### Get Users
```
GET /admin/users?role=SECURITY_HEAD&page=1&limit=20
Authorization: Bearer <TOKEN>
Required Role: SUPER_ADMIN

Response:
{
  "success": true,
  "data": [
    {
      "user_id": 2,
      "username": "security_head",
      "email": "security@vmms.com",
      "role": "SECURITY_HEAD",
      "status": "ACTIVE"
    }
  ]
}
```

### Create Project
```
POST /admin/projects
Authorization: Bearer <TOKEN>
Content-Type: application/json
Required Role: SUPER_ADMIN

Request:
{
  "project_name": "Main Construction Site",
  "project_code": "MCS-001",
  "location": "Downtown District",
  "city": "Mumbai",
  "state": "Maharashtra"
}

Response:
{
  "success": true,
  "data": {
    "project_id": 1,
    "project_name": "Main Construction Site",
    "project_code": "MCS-001",
    "location": "Downtown District"
  }
}
```

### Create Gate
```
POST /admin/gates
Authorization: Bearer <TOKEN>
Content-Type: application/json
Required Role: SUPER_ADMIN

Request:
{
  "gate_name": "Main Entrance",
  "gate_code": "GATE-001",
  "entrance_id": 1,
  "project_id": 1,
  "ip_address": "192.168.1.100",
  "is_active": true
}

Response:
{
  "success": true,
  "data": {
    "gate_id": 1,
    "gate_name": "Main Entrance",
    "gate_code": "GATE-001",
    "project_name": "Main Construction Site",
    "ip_address": "192.168.1.100",
    "status": "OFFLINE"
  }
}
```

---

## Error Codes Reference

| Code | Status | Description |
|------|--------|-------------|
| BLACKLIST_BLOCKED | 403 | Person is blacklisted |
| PASS_EXPIRED | 403 | Visitor pass has expired |
| INVALID_TOKEN | 401 | JWT token invalid or expired |
| INSUFFICIENT_PERMISSION | 403 | User lacks required role |
| RESOURCE_NOT_FOUND | 404 | Requested resource doesn't exist |
| DUPLICATE_ENTRY | 409 | Record already exists |
| VALIDATION_ERROR | 400 | Request validation failed |
| DATABASE_ERROR | 500 | Database operation failed |
| SMS_PROVIDER_ERROR | 500 | SMS sending failed |

---

## Rate Limiting

- Default: 100 requests per 15 minutes per IP
- Configurable: RATE_LIMIT_MAX_REQUESTS, RATE_LIMIT_WINDOW in .env

---

## Pagination

All list endpoints support pagination:

```json
{
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "pages": 8
  }
}
```

Default limit: 20, max limit: 100
