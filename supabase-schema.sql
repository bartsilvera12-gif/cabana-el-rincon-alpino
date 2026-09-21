-- =========================================================================
-- Cabaña El Rincón Alpino — schema para Supabase
-- Es idempotente: podés correrlo varias veces sin errores.
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
  deposit bigint,
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
  price_weekday bigint not null default 550000,
  price_weekend bigint not null default 700000,
  price_extra_person bigint not null default 50000,
  max_guests int not null default 6,
  deposit_pct int not null default 50,
  check_in_time text not null default '16:00',
  check_out_time text not null default '12:00',
  whatsapp text not null default '595987502862',
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

-- ----- Admins ----------------------------------------------------------
-- Solo los user_ids en esta tabla pueden entrar al panel y modificar datos.

create table if not exists admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

-- Helper: verifica si el auth.uid() actual está en admins.
create or replace function public.is_admin() returns boolean
language sql stable security definer as $$
  select exists (select 1 from admins where user_id = auth.uid());
$$;
grant execute on function public.is_admin() to anon, authenticated;

-- ----- RLS -------------------------------------------------------------

alter table reservations   enable row level security;
alter table blocked_dates  enable row level security;
alter table config         enable row level security;
alter table gallery        enable row level security;
alter table admins         enable row level security;

drop policy if exists "admins self read"           on admins;
drop policy if exists "reservations public read"   on reservations;
drop policy if exists "blocked_dates public read"  on blocked_dates;
drop policy if exists "config public read"         on config;
drop policy if exists "gallery public read"        on gallery;
drop policy if exists "reservations public insert" on reservations;
drop policy if exists "reservations admin update"  on reservations;
drop policy if exists "reservations admin delete"  on reservations;
drop policy if exists "blocked_dates admin write"  on blocked_dates;
drop policy if exists "config admin update"        on config;
drop policy if exists "gallery admin write"        on gallery;

create policy "admins self read"
  on admins for select to authenticated
  using (auth.uid() = user_id);

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

-- Escrituras admin: requieren estar en la tabla admins
create policy "reservations admin update"
  on reservations for update to authenticated
  using (public.is_admin()) with check (public.is_admin());
create policy "reservations admin delete"
  on reservations for delete to authenticated
  using (public.is_admin());

create policy "blocked_dates admin write"
  on blocked_dates for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

create policy "config admin update"
  on config for update to authenticated
  using (public.is_admin()) with check (public.is_admin());

create policy "gallery admin write"
  on gallery for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- ----- Storage bucket para fotos ---------------------------------------

insert into storage.buckets (id, name, public)
values ('gallery-photos', 'gallery-photos', true)
on conflict (id) do nothing;

drop policy if exists "gallery photos public read"  on storage.objects;
drop policy if exists "gallery photos admin write"  on storage.objects;
drop policy if exists "gallery photos admin update" on storage.objects;
drop policy if exists "gallery photos admin delete" on storage.objects;

create policy "gallery photos public read"
  on storage.objects for select
  using (bucket_id = 'gallery-photos');
create policy "gallery photos admin write"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'gallery-photos' and public.is_admin());
create policy "gallery photos admin update"
  on storage.objects for update to authenticated
  using (bucket_id = 'gallery-photos' and public.is_admin());
create policy "gallery photos admin delete"
  on storage.objects for delete to authenticated
  using (bucket_id = 'gallery-photos' and public.is_admin());

-- ----- Admin autorizado ------------------------------------------------
-- Solo este user_id puede entrar al panel y modificar datos.

insert into admins (user_id)
values ('a2625c64-b5f9-46bb-b995-3a9532eb651d')
on conflict (user_id) do nothing;

-- =========================================================================
-- Para autorizar otro admin más adelante:
--   insert into admins (user_id) values ('<uuid del user>')
--   on conflict (user_id) do nothing;
-- El uuid lo sacás de Authentication → Users.
-- =========================================================================
