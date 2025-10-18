-- enable uuid gen if needed
create extension if not exists pgcrypto;

create table if not exists users (
  id uuid primary key default gen_random_uuid(),
  email text not null unique,
  password_hash text not null,
  display_name text not null,
  role text not null default 'USER',
  created_at timestamptz not null default now()
);

create table if not exists devices (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  device_key text not null unique,
  owner_id uuid references users(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists samples (
  id bigserial primary key,
  device_id uuid not null references devices(id) on delete cascade,
  ts timestamptz not null,
  tvoc_ppb double precision,
  voc_index double precision,
  eco2_ppm double precision,
  hum_rel double precision,
  temp_c double precision,
  formaldehyde_ppm double precision,
  benzene_ppm double precision,
  created_at timestamptz not null default now()
);
create index if not exists idx_samples_device_ts on samples(device_id, ts desc);

create table if not exists alerts (
  id bigserial primary key,
  device_id uuid not null references devices(id) on delete cascade,
  level text not null,   -- INFO/WARN/CRITICAL
  message text not null,
  ts timestamptz not null default now()
);
