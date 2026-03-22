-- Add recipient_name to sms_logs for better audit context
ALTER TABLE sms_logs
  ADD COLUMN IF NOT EXISTS recipient_name VARCHAR(150);

-- Index to speed up querying pending messages per recipient
CREATE INDEX IF NOT EXISTS idx_sms_logs_status ON sms_logs(status);
