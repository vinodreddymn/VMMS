BEGIN;

-- Seed roles
INSERT INTO roles (id, role_name, can_export_pdf, can_export_excel)
VALUES
(1, 'SUPER_ADMIN', true, true),
(2, 'SECURITY_HEAD', true, false),
(3, 'ENROLLMENT_STAFF', false, false)
ON CONFLICT (id) DO NOTHING;

-- Seed users with bcrypt password hashes (generated with bcrypt round 10)
-- Passwords: admin=AdminPass123!, security_head=Security123!, enrollment=Enroll123!
INSERT INTO users (id, username, password_hash, full_name, phone, role_id)
VALUES
(1, 'admin', '$2b$10$VINvb7KVDGUVa1dIrlIsT.rne/RnY5WI1FYdbsRKA.MAzXY.7g8li', 'Admin User', '9999999999', 1),
(2, 'security_head', '$2b$10$27KskdK.1kMAhAC5YuZoEeIPyYc6xsndt5jc3Ij756OFFLytkKbTm', 'Security Head', '9888888888', 2),
(3, 'enrollment', '$2b$10$QFORAL9V8MAQ0Hf7y6txo.gJa2pX1wmUcy5cbMzd61qLu7MeG3XF.', 'Enrollment Staff', '9777777777', 3)
ON CONFLICT (id) DO NOTHING;

-- Projects / Departments / Hosts
INSERT INTO projects (id, project_name)
VALUES (1, 'Test Site') ON CONFLICT (id) DO NOTHING;

INSERT INTO departments (id, department_name, project_id)
VALUES (1, 'Operations', 1) ON CONFLICT (id) DO NOTHING;

INSERT INTO hosts (id, host_name, phone, email, department_id)
VALUES (1, 'John Security Manager', '9876543210', 'security@vmms.com', 1) ON CONFLICT (id) DO NOTHING;

-- Entrances and Gates
INSERT INTO entrances (id, entrance_code, entrance_name, is_main_gate)
VALUES (1, 'ENT-001', 'Main Entrance', true) ON CONFLICT (id) DO NOTHING;

INSERT INTO gates (id, gate_name, entrance_id, ip_address, device_serial)
VALUES (1, 'Main Entrance', 1, '192.168.1.100', 'DEV-001') ON CONFLICT (id) DO NOTHING;

-- Visitor types
INSERT INTO visitor_types (id, type_name, allows_labour, is_internal)
VALUES (1, 'VISITOR', false, false), (2, 'LABOUR', true, false) ON CONFLICT (id) DO NOTHING;

-- A sample visitor
INSERT INTO visitors (
  id, visitor_type_id, pass_no, first_name, last_name, designation, company_name,
  project_id, department_id, host_id, primary_phone, email,
  date_of_birth, aadhaar_encrypted, aadhaar_last4, entrance_id,
  smartphone_allowed, smartphone_expiry, laptop_allowed, ops_area_permitted,
  status, valid_from, valid_to, created_by
)
VALUES (
  1001, 1, 'PASS20260101001', 'John', 'Doe', 'Vendor', 'Acme Services',
  1, 1, 1, '9876543210', 'john@example.com',
  '1985-01-01', 'enc-aadhaar-123', '9012', 1,
  true, '2026-12-31', false, true,
  'ACTIVE', '2026-01-01', '2026-12-31', 1
) ON CONFLICT (id) DO NOTHING;

-- Visitor document
INSERT INTO visitor_documents (id, visitor_id, doc_type, doc_number, expiry_date, file_path)
VALUES (2001, 1001, 'AADHAAR', 'XXXX-XXXX-9012', NULL, 'uploads/documents/aadhaar_1001.pdf') ON CONFLICT (id) DO NOTHING;

-- Biometric sample
INSERT INTO biometric_data (id, visitor_id, biometric_hash, algorithm)
VALUES (3001, 1001, 'sha256_sample_hash', 'FINGERPRINT_V2') ON CONFLICT (id) DO NOTHING;

-- RFID card for visitor
INSERT INTO rfid_cards (id, visitor_id, card_uid, qr_code, issue_date, expiry_date)
VALUES (4001, 1001, 'f3a8c5b2-7d9e-4f1a-8c0b-3d5f8a2e7c1b', 'data:image/png;base64,xxx', '2026-01-01', '2027-01-01') ON CONFLICT (id) DO NOTHING;

-- Sample labour and token
INSERT INTO labours (id, supervisor_id, full_name, phone)
VALUES (5001, 1001, 'Ram Kumar', '9123456789') ON CONFLICT (id) DO NOTHING;

INSERT INTO labour_tokens (id, labour_id, token_uid, assigned_date, valid_until)
VALUES (6001, 5001, 'labour-token-0001', '2026-01-01', '2027-01-01') ON CONFLICT (id) DO NOTHING;

-- Materials
INSERT INTO materials (id, category, make, model, serial_number, description)
VALUES (7001, 'TOOLS', 'Stanley', 'TIM-100', 'SN123456', 'Power Drill') ON CONFLICT (id) DO NOTHING;

INSERT INTO material_transactions (id, visitor_id, material_id, quantity, direction)
VALUES (8001, 1001, 7001, 2, 'OUT') ON CONFLICT (id) DO NOTHING;

-- Blacklist sample
INSERT INTO blacklist (id, aadhaar_hash, phone, biometric_hash, reason, block_type)
VALUES (9001, 'hash_blacklist_1', '9990001111', NULL, 'Security concern', 'TEMPORARY') ON CONFLICT (id) DO NOTHING;

-- Gate health
INSERT INTO gate_health (gate_id, last_heartbeat, is_online, cpu_usage, memory_usage, storage_usage, camera_status, rfid_status, biometric_status)
VALUES (1, NOW(), true, 12.5, 45.1, 30.0, true, true, true)
ON CONFLICT (gate_id) DO UPDATE SET last_heartbeat = EXCLUDED.last_heartbeat;

-- SMS log example
INSERT INTO sms_logs (id, recipient, message, event_type, related_entity_id, status)
VALUES (10001, '9876543210', 'Test SMS', 'TEST', 1001, 'SENT') ON CONFLICT (id) DO NOTHING;

-- Sync queue example
INSERT INTO sync_queue (id, gate_id, payload, synced)
VALUES (11001, 1, '{"access_logs":[]}', false) ON CONFLICT (id) DO NOTHING;

-- Set sequences to avoid conflicts for future inserts
SELECT setval(pg_get_serial_sequence('roles', 'id'), (SELECT COALESCE(MAX(id),1) FROM roles));
SELECT setval(pg_get_serial_sequence('users', 'id'), (SELECT COALESCE(MAX(id),1) FROM users));
SELECT setval(pg_get_serial_sequence('projects', 'id'), (SELECT COALESCE(MAX(id),1) FROM projects));
SELECT setval(pg_get_serial_sequence('departments', 'id'), (SELECT COALESCE(MAX(id),1) FROM departments));
SELECT setval(pg_get_serial_sequence('hosts', 'id'), (SELECT COALESCE(MAX(id),1) FROM hosts));
SELECT setval(pg_get_serial_sequence('entrances', 'id'), (SELECT COALESCE(MAX(id),1) FROM entrances));
SELECT setval(pg_get_serial_sequence('gates', 'id'), (SELECT COALESCE(MAX(id),1) FROM gates));
SELECT setval(pg_get_serial_sequence('visitor_types', 'id'), (SELECT COALESCE(MAX(id),1) FROM visitor_types));
SELECT setval(pg_get_serial_sequence('visitors', 'id'), (SELECT COALESCE(MAX(id),1001) FROM visitors));
SELECT setval(pg_get_serial_sequence('visitor_documents', 'id'), (SELECT COALESCE(MAX(id),2001) FROM visitor_documents));
SELECT setval(pg_get_serial_sequence('biometric_data', 'id'), (SELECT COALESCE(MAX(id),3001) FROM biometric_data));
SELECT setval(pg_get_serial_sequence('rfid_cards', 'id'), (SELECT COALESCE(MAX(id),4001) FROM rfid_cards));
SELECT setval(pg_get_serial_sequence('labours', 'id'), (SELECT COALESCE(MAX(id),5001) FROM labours));
SELECT setval(pg_get_serial_sequence('labour_tokens', 'id'), (SELECT COALESCE(MAX(id),6001) FROM labour_tokens));
SELECT setval(pg_get_serial_sequence('materials', 'id'), (SELECT COALESCE(MAX(id),7001) FROM materials));
SELECT setval(pg_get_serial_sequence('material_transactions', 'id'), (SELECT COALESCE(MAX(id),8001) FROM material_transactions));
SELECT setval(pg_get_serial_sequence('blacklist', 'id'), (SELECT COALESCE(MAX(id),9001) FROM blacklist));
SELECT setval(pg_get_serial_sequence('sms_logs', 'id'), (SELECT COALESCE(MAX(id),10001) FROM sms_logs));
SELECT setval(pg_get_serial_sequence('sync_queue', 'id'), (SELECT COALESCE(MAX(id),11001) FROM sync_queue));

COMMIT;
