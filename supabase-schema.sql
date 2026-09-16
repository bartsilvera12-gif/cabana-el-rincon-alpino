-- =========================================================================
-- Cabaña El Rincón Alpino — schema para Supabase
-- Corré esto en el SQL Editor de tu proyecto (una sola vez).
-- =========================================================================

-- ----- Tablas ----------------------------------------------------------

create table if not exists reservations (
  code text primary key,
  name text not null,
  phone text not null,
  check_in date not null,
  check_out date not null,
  guests int not null,
  total bigint not null,
  status text not null default 'PENDIENTE'
    check (status in ('PENDIENTE','CONFIRMADA','RECHAZADA','VENCIDA')),
  created_at timestamptz not null default now()
);
create index if not exists reservations_status_idx on reservations (status);
create index if not exists reservations_check_in_idx on reservations (check_in);

create table if not exists blocked_dates (
  date date primary key,
  reason text,
  created_at timestamptz not null default now()
);

create table if not exists config (
  id int primary key default 1,
  price_weekday bigint not null default 450000,
  price_weekend bigint not null default 550000,
  price_extra_person bigint not null default 50000,
  max_guests int not null default 6,
  deposit_pct int not null default 50,
  check_in_time text not null default '16:00',
  check_out_time text not null default '12:00',
  whatsapp text not null default '595982336705',
  alias text not null default '0982336705',
  constraint config_singleton check (id = 1)
);
insert into config (id) values (1) on conflict do nothing;

create table if not exists gallery (
  id uuid primary key default gen_random_uuid(),
  path text not null,           -- key dentro del bucket 'gallery-photos'
  category text not null default 'Cabaña'
    check (category in ('Cabaña','Piscina','Quincho','Interior','Cocina')),
  sort_order int not null default 0,
  title text,
  created_at timestamptz not null default now()
);
create index if not exists gallery_order_idx on gallery (sort_order);

-- ----- RLS -------------------------------------------------------------

alter table reservations   enable row level security;
alter table blocked_dates  enable row level security;
alter table config         enable row level security;
alter table gallery        enable row level security;

-- Lectura pública (necesaria para el sitio)
create policy "reservations public read"
  on reservations for select using (true);
create policy "blocked_dates public read"
  on blocked_dates for select using (true);
create policy "config public read"
  on config for select using (true);
create policy "gallery public read"
  on gallery for select using (true);

-- Insert público de reservas (flujo de booking)
create policy "reservations public insert"
  on reservations for insert with check (true);

-- Todo lo demás requiere estar autenticado (admin)
create policy "reservations admin update"
  on reservations for update to authenticated using (true) with check (true);
create policy "reservations admin delete"
  on reservations for delete to authenticated using (true);

create policy "blocked_dates admin write"
  on blocked_dates for all to authenticated using (true) with check (true);

create policy "config admin update"
  on config for update to authenticated using (true) with check (true);

create policy "gallery admin write"
  on gallery for all to authenticated using (true) with check (true);

-- ----- Storage bucket para fotos ---------------------------------------

insert into storage.buckets (id, name, public)
values ('gallery-photos', 'gallery-photos', true)
on conflict (id) do nothing;

create policy "gallery photos public read"
  on storage.objects for select using (bucket_id = 'gallery-photos');
create policy "gallery photos admin write"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'gallery-photos');
create policy "gallery photos admin update"
  on storage.objects for update to authenticated
  using (bucket_id = 'gallery-photos');
create policy "gallery photos admin delete"
  on storage.objects for delete to authenticated
  using (bucket_id = 'gallery-photos');

-- =========================================================================
-- Después de correr esto:
--   1. Andá a Authentication → Users → Add user
--      Email:    tu-email@dominio
--      Password: (elegí una)
--      Auto Confirm: sí
--   2. Ese usuario es el que va a poder entrar al panel /admin.
-- =========================================================================
