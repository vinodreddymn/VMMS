BEGIN;

CREATE TABLE IF NOT EXISTS rfid_stock (
    id BIGSERIAL PRIMARY KEY,
    uid VARCHAR(100) UNIQUE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE',
    removed_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE rfid_cards_stock
    ADD COLUMN IF NOT EXISTS removed_reason TEXT;

ALTER TABLE rfid_stock
    ADD COLUMN IF NOT EXISTS removed_reason TEXT;

CREATE INDEX IF NOT EXISTS idx_rfid_stock_status ON rfid_stock(status);
CREATE INDEX IF NOT EXISTS idx_rfid_stock_uid ON rfid_stock(uid);

COMMIT;
