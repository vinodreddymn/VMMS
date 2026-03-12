-- Vehicle details for visitors
ALTER TABLE visitors
  ADD COLUMN IF NOT EXISTS vehicle_number VARCHAR(20),
  ADD COLUMN IF NOT EXISTS vehicle_make VARCHAR(100),
  ADD COLUMN IF NOT EXISTS vehicle_model VARCHAR(100),
  ADD COLUMN IF NOT EXISTS vehicle_color VARCHAR(50);

-- Optional indexes for lookups by vehicle number
CREATE INDEX IF NOT EXISTS idx_visitors_vehicle_number ON visitors (vehicle_number);
