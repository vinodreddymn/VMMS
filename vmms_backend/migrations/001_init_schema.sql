-- =====================================================
-- VMMS ENTERPRISE DATABASE SCHEMA
-- =====================================================

BEGIN;

-- =====================================================
-- 1️⃣ RBAC
-- =====================================================

CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL,
    can_export_pdf BOOLEAN DEFAULT FALSE,
    can_export_excel BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    full_name VARCHAR(150),
    phone VARCHAR(20),
    role_id INT REFERENCES roles(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 2️⃣ PROJECT / DEPARTMENT / HOST STRUCTURE
-- =====================================================

CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    project_name VARCHAR(150) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    department_name VARCHAR(150) NOT NULL,
    project_id INT REFERENCES projects(id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE hosts (
    id SERIAL PRIMARY KEY,
    host_name VARCHAR(150) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(150),
    department_id INT REFERENCES departments(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 3️⃣ ENTRANCES & GATES
-- =====================================================

CREATE TABLE entrances (
    id SERIAL PRIMARY KEY,
    entrance_code VARCHAR(20) UNIQUE NOT NULL,
    entrance_name VARCHAR(100),
    is_main_gate BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE gates (
    id SERIAL PRIMARY KEY,
    gate_name VARCHAR(100),
    entrance_id INT REFERENCES entrances(id),
    ip_address VARCHAR(50),
    device_serial VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 4️⃣ VISITOR TYPES
-- =====================================================

CREATE TABLE visitor_types (
    id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) UNIQUE NOT NULL,
    allows_labour BOOLEAN DEFAULT FALSE,
    is_internal BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 5️⃣ VISITORS (UPDATED WITH PROJECT, DEPT, HOST, SMARTPHONE FLAG)
-- =====================================================

CREATE TABLE visitors (
    id BIGSERIAL PRIMARY KEY,

    visitor_type_id INT REFERENCES visitor_types(id),

    pass_no VARCHAR(50) UNIQUE NOT NULL,

    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100),
    full_name VARCHAR(200) GENERATED ALWAYS AS
        (first_name || ' ' || COALESCE(last_name,'')) STORED,

    designation VARCHAR(150),

    company_name VARCHAR(150),
    company_address TEXT,

    project_id INT REFERENCES projects(id),
    department_id INT REFERENCES departments(id),
    host_id INT REFERENCES hosts(id),

    primary_phone VARCHAR(20),
    alternate_phone VARCHAR(20),
    email VARCHAR(150),

    date_of_birth DATE,
    blood_group VARCHAR(5),
    height_cm INT,
    visible_marks TEXT,

    temp_address TEXT,
    perm_address TEXT,

    aadhaar_encrypted TEXT NOT NULL,
    aadhaar_last4 VARCHAR(4) NOT NULL,

    entrance_id INT REFERENCES entrances(id),

    -- TRS REQUIRED PERMISSIONS
    smartphone_allowed BOOLEAN DEFAULT FALSE,
    smartphone_expiry DATE,

    laptop_allowed BOOLEAN DEFAULT FALSE,
    laptop_make VARCHAR(100),
    laptop_model VARCHAR(100),
    laptop_serial VARCHAR(100),
    laptop_expiry DATE,

    ops_area_permitted BOOLEAN DEFAULT FALSE,

    status VARCHAR(20) DEFAULT 'ACTIVE',

    valid_from DATE,
    valid_to DATE,

    enrollment_photo_path TEXT,

    created_by INT REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_visitors_pass_no ON visitors(pass_no);
CREATE INDEX idx_visitors_aadhaar_last4 ON visitors(aadhaar_last4);
CREATE INDEX idx_visitors_project_id ON visitors(project_id);

-- =====================================================
-- 6️⃣ DOCUMENTS (KYC + ASO FORMS)
-- =====================================================

CREATE TABLE visitor_documents (
    id BIGSERIAL PRIMARY KEY,
    visitor_id BIGINT REFERENCES visitors(id) ON DELETE CASCADE,
    doc_type VARCHAR(50), -- AADHAAR / PV / WO / ASO_RENEWAL / ASO_EXTENSION
    doc_number VARCHAR(100),
    expiry_date DATE,
    file_path TEXT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_visitor_documents_visitor_id ON visitor_documents(visitor_id);

-- =====================================================
-- 7️⃣ BIOMETRICS
-- =====================================================

CREATE TABLE biometric_data (
    id BIGSERIAL PRIMARY KEY,
    visitor_id BIGINT REFERENCES visitors(id) ON DELETE CASCADE,
    biometric_hash TEXT NOT NULL,
    algorithm VARCHAR(50) DEFAULT 'SHA256',
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE biometric_match_audit (
    id BIGSERIAL PRIMARY KEY,
    visitor_id BIGINT,
    gate_id INT REFERENCES gates(id),
    biometric_hash TEXT,
    match_score NUMERIC(5,2),
    match_result VARCHAR(20),
    attempt_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_biometric_match_audit_visitor_id ON biometric_match_audit(visitor_id);
CREATE INDEX idx_biometric_match_audit_gate_id ON biometric_match_audit(gate_id);

-- =====================================================
-- 8️⃣ RFID CARDS
-- =====================================================

CREATE TABLE rfid_cards (
    id BIGSERIAL PRIMARY KEY,
    visitor_id BIGINT REFERENCES visitors(id),
    card_uid VARCHAR(100) UNIQUE NOT NULL,
    qr_code TEXT,
    issue_date DATE,
    expiry_date DATE,
    card_status VARCHAR(20) DEFAULT 'ACTIVE',
    replaced_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE card_reissue_log (
    id BIGSERIAL PRIMARY KEY,
    old_card_id BIGINT REFERENCES rfid_cards(id),
    new_card_id BIGINT REFERENCES rfid_cards(id),
    aso_document_id BIGINT REFERENCES visitor_documents(id),
    reissued_by INT REFERENCES users(id),
    reason TEXT,
    reissued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_rfid_cards_visitor_id ON rfid_cards(visitor_id);
CREATE INDEX idx_rfid_cards_card_uid ON rfid_cards(card_uid);

-- =====================================================
-- 9️⃣ LABOUR MANAGEMENT
-- =====================================================

CREATE TABLE labours (
    id BIGSERIAL PRIMARY KEY,
    supervisor_id BIGINT REFERENCES visitors(id),
    full_name VARCHAR(150),
    phone VARCHAR(20),
    aadhaar_encrypted TEXT,
    aadhaar_last4 VARCHAR(4),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE labour_tokens (
    id BIGSERIAL PRIMARY KEY,
    labour_id BIGINT REFERENCES labours(id),
    token_uid VARCHAR(100),
    assigned_date DATE,
    valid_until TIMESTAMP,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE labour_manifests (
    id BIGSERIAL PRIMARY KEY,
    supervisor_id BIGINT REFERENCES visitors(id),
    manifest_date DATE,
    printed_at TIMESTAMP,
    signed BOOLEAN DEFAULT FALSE,
    pdf_path TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE manifest_labours (
    manifest_id BIGINT REFERENCES labour_manifests(id),
    labour_id BIGINT REFERENCES labours(id),
    PRIMARY KEY (manifest_id, labour_id)
);

CREATE INDEX idx_labours_supervisor_id ON labours(supervisor_id);
CREATE INDEX idx_labour_tokens_labour_id ON labour_tokens(labour_id);
CREATE INDEX idx_labour_manifests_supervisor_id ON labour_manifests(supervisor_id);

-- =====================================================
-- 🔟 ACCESS LOGS (PARTITIONED)
-- =====================================================

CREATE TABLE access_logs (
    id BIGSERIAL,
    person_type VARCHAR(20),
    person_id BIGINT,
    gate_id INT REFERENCES gates(id),
    direction VARCHAR(10),
    scan_time TIMESTAMP NOT NULL,
    status VARCHAR(20),
    error_code VARCHAR(10),
    live_photo_path TEXT,
    manual_override BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (id, scan_time)
) PARTITION BY RANGE (scan_time);

CREATE TABLE access_logs_default
PARTITION OF access_logs DEFAULT;

CREATE INDEX idx_access_logs_person_id ON access_logs(person_id);
CREATE INDEX idx_access_logs_gate_id ON access_logs(gate_id);
CREATE INDEX idx_access_logs_scan_time ON access_logs(scan_time);

-- =====================================================
-- 1️⃣1️⃣ MATERIAL MANAGEMENT
-- =====================================================

CREATE TABLE materials (
    id SERIAL PRIMARY KEY,
    category VARCHAR(50),
    make VARCHAR(100),
    model VARCHAR(100),
    serial_number VARCHAR(100),
    description TEXT,
    is_returnable BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE material_transactions (
    id BIGSERIAL PRIMARY KEY,
    visitor_id BIGINT REFERENCES visitors(id),
    material_id INT REFERENCES materials(id),
    quantity INT,
    direction VARCHAR(10),
    transaction_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE material_balance (
    id BIGSERIAL PRIMARY KEY,
    visitor_id BIGINT REFERENCES visitors(id),
    material_id INT REFERENCES materials(id),
    balance INT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(visitor_id, material_id)
);

CREATE INDEX idx_material_transactions_visitor_id ON material_transactions(visitor_id);
CREATE INDEX idx_material_balance_visitor_id ON material_balance(visitor_id);

-- =====================================================
-- 1️⃣2️⃣ BLACKLIST
-- =====================================================

CREATE TABLE blacklist (
    id SERIAL PRIMARY KEY,
    aadhaar_hash TEXT,
    phone VARCHAR(20),
    biometric_hash TEXT,
    reason TEXT,
    block_type VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_blacklist_aadhaar_hash ON blacklist(aadhaar_hash);
CREATE INDEX idx_blacklist_phone ON blacklist(phone);

-- =====================================================
-- 1️⃣3️⃣ SMS LOGS
-- =====================================================

CREATE TABLE sms_logs (
    id SERIAL PRIMARY KEY,
    recipient VARCHAR(20),
    message TEXT,
    event_type VARCHAR(50),
    related_entity_id BIGINT,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20)
);

CREATE INDEX idx_sms_logs_recipient ON sms_logs(recipient);
CREATE INDEX idx_sms_logs_sent_at ON sms_logs(sent_at);

-- =====================================================
-- 1️⃣4️⃣ OFFLINE SYNC
-- =====================================================

CREATE TABLE sync_queue (
    id BIGSERIAL PRIMARY KEY,
    gate_id INT REFERENCES gates(id),
    payload JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    synced BOOLEAN DEFAULT FALSE,
    synced_at TIMESTAMP
);

CREATE INDEX idx_sync_queue_gate_id ON sync_queue(gate_id);
CREATE INDEX idx_sync_queue_synced ON sync_queue(synced);

-- =====================================================
-- 1️⃣5️⃣ GATE HEALTH
-- =====================================================

CREATE TABLE gate_health (
    gate_id INT PRIMARY KEY REFERENCES gates(id),
    last_heartbeat TIMESTAMP,
    is_online BOOLEAN,
    cpu_usage NUMERIC(5,2),
    memory_usage NUMERIC(5,2),
    storage_usage NUMERIC(5,2),
    camera_status BOOLEAN,
    rfid_status BOOLEAN,
    biometric_status BOOLEAN,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE gate_health_logs (
    id BIGSERIAL PRIMARY KEY,
    gate_id INT REFERENCES gates(id),
    heartbeat_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cpu_usage NUMERIC(5,2),
    memory_usage NUMERIC(5,2),
    storage_usage NUMERIC(5,2),
    camera_status BOOLEAN,
    rfid_status BOOLEAN,
    biometric_status BOOLEAN
);

CREATE INDEX idx_gate_health_logs_gate_id ON gate_health_logs(gate_id);

-- =====================================================
-- 1️⃣6️⃣ STATUS AUDIT
-- =====================================================

CREATE TABLE visitor_status_audit (
    id BIGSERIAL PRIMARY KEY,
    visitor_id BIGINT REFERENCES visitors(id),
    old_status VARCHAR(20),
    new_status VARCHAR(20),
    changed_by INT REFERENCES users(id),
    reason TEXT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_visitor_status_audit_visitor_id ON visitor_status_audit(visitor_id);

-- =====================================================
-- 1️⃣7️⃣ MASTER WHITELIST (FOR GATE SYNC)
-- =====================================================

CREATE TABLE master_whitelist (
    id BIGSERIAL PRIMARY KEY,
    visitor_id BIGINT REFERENCES visitors(id),
    rfid_uid VARCHAR(100),
    biometric_hash TEXT,
    smartphone_allowed BOOLEAN,
    laptop_allowed BOOLEAN,
    ops_area_permitted BOOLEAN,
    valid_until DATE,
    last_synced TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_master_whitelist_visitor_id ON master_whitelist(visitor_id);
CREATE INDEX idx_master_whitelist_rfid_uid ON master_whitelist(rfid_uid);

-- =====================================================
-- SEED DATA
-- =====================================================

INSERT INTO roles (role_name, can_export_pdf, can_export_excel) VALUES
('SUPER_ADMIN', TRUE, TRUE),
('SECURITY_HEAD', TRUE, FALSE),
('ENROLLMENT_STAFF', FALSE, FALSE),
('GATE_MANAGER', FALSE, FALSE);

INSERT INTO visitor_types (type_name, allows_labour, is_internal) VALUES
('SUPERVISOR', TRUE, FALSE),
('LABOUR', FALSE, FALSE),
('VENDOR', FALSE, FALSE),
('INTERNAL', FALSE, TRUE);

COMMIT;
