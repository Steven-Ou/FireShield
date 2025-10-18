CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users & auth
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  display_name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'USER',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- API devices
CREATE TABLE devices (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  api_key TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT now(),
  last_seen TIMESTAMPTZ
);

-- Time series samples
CREATE TABLE samples (
  device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
  ts TIMESTAMPTZ NOT NULL,
  tvoc_ppb REAL,
  voc_index REAL,
  eco2_ppm REAL,
  hum_rel REAL,
  temp_c REAL,
  formaldehyde_ppm REAL,
  benzene_ppm REAL,
  raw JSONB,
  PRIMARY KEY (device_id, ts)
);
CREATE INDEX samples_device_ts_idx ON samples (device_id, ts DESC);

-- Alerts
CREATE TABLE alerts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
  ts TIMESTAMPTZ NOT NULL,
  severity TEXT NOT NULL,
  message TEXT,
  details JSONB
);
