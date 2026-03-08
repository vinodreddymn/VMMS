BEGIN;

ALTER TABLE visitors
ADD COLUMN IF NOT EXISTS can_register_labours BOOLEAN DEFAULT FALSE;

CREATE INDEX IF NOT EXISTS idx_visitors_can_register_labours ON visitors(can_register_labours);

COMMIT;
