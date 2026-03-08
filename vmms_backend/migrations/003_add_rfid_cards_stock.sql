BEGIN;

CREATE TABLE IF NOT EXISTS rfid_cards_stock (
    id BIGSERIAL PRIMARY KEY,
    uid VARCHAR(100) UNIQUE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_rfid_cards_stock_status ON rfid_cards_stock(status);
CREATE INDEX IF NOT EXISTS idx_rfid_cards_stock_uid ON rfid_cards_stock(uid);

COMMIT;
