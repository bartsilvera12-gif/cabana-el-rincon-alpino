-- =========================================================================
-- Migración de `public` a un schema propio `rinconalpino`.
-- Corré esto UNA VEZ en el SQL Editor. Es idempotente (podés reintentarlo).
-- Los datos existentes se preservan (las tablas se MUEVEN, no se recrean).
-- =========================================================================

-- 1) Crear el schema y darle uso
create schema if not exists rinconalpino;
grant usage on schema rinconalpino to anon, authenticated, service_role;
alter default privileges in schema rinconalpino
  grant select, insert, update, delete on tables to anon, authenticated, service_role;

-- 2) Mover las tablas (mueve políticas RLS, índices y triggers con ellas)
alter table if exists public.reservations  set schema rinconalpino;
alter table if exists public.blocked_dates set schema rinconalpino;
alter table if exists public.config        set schema rinconalpino;
alter table if exists public.gallery       set schema rinconalpino;
alter table if exists public.admins        set schema rinconalpino;

grant select, insert, update, delete on all tables in schema rinconalpino
  to anon, authenticated;

-- 3) Dropear TODAS las policies primero (usan la vieja public.is_admin)
drop policy if exists "admins self read"           on rinconalpino.admins;
drop policy if exists "reservations public read"   on rinconalpino.reservations;
drop policy if exists "blocked_dates public read"  on rinconalpino.blocked_dates;
drop policy if exists "config public read"         on rinconalpino.config;
drop policy if exists "gallery public read"        on rinconalpino.gallery;
drop policy if exists "reservations public insert" on rinconalpino.reservations;
drop policy if exists "reservations admin update"  on rinconalpino.reservations;
drop policy if exists "reservations admin delete"  on rinconalpino.reservations;
drop policy if exists "blocked_dates admin write"  on rinconalpino.blocked_dates;
drop policy if exists "config admin update"        on rinconalpino.config;
drop policy if exists "gallery admin write"        on rinconalpino.gallery;
drop policy if exists "gallery photos public read"  on storage.objects;
drop policy if exists "gallery photos admin write"  on storage.objects;
drop policy if exists "gallery photos admin update" on storage.objects;
drop policy if exists "gallery photos admin delete" on storage.objects;

-- 4) Ahora sí, rehacer la función is_admin() en el nuevo schema
drop function if exists public.is_admin();
create or replace function rinconalpino.is_admin() returns boolean
language sql stable security definer set search_path = rinconalpino, public as $$
  select exists (select 1 from rinconalpino.admins where user_id = auth.uid());
$$;
grant execute on function rinconalpino.is_admin() to anon, authenticated;

create policy "admins self read"
  on rinconalpino.admins for select to authenticated
  using (auth.uid() = user_id);

create policy "reservations public read"
  on rinconalpino.reservations for select using (true);
create policy "blocked_dates public read"
  on rinconalpino.blocked_dates for select using (true);
create policy "config public read"
  on rinconalpino.config for select using (true);
create policy "gallery public read"
  on rinconalpino.gallery for select using (true);

create policy "reservations public insert"
  on rinconalpino.reservations for insert with check (true);

create policy "reservations admin update"
  on rinconalpino.reservations for update to authenticated
  using (rinconalpino.is_admin()) with check (rinconalpino.is_admin());
create policy "reservations admin delete"
  on rinconalpino.reservations for delete to authenticated
  using (rinconalpino.is_admin());

create policy "blocked_dates admin write"
  on rinconalpino.blocked_dates for all to authenticated
  using (rinconalpino.is_admin()) with check (rinconalpino.is_admin());

create policy "config admin update"
  on rinconalpino.config for update to authenticated
  using (rinconalpino.is_admin()) with check (rinconalpino.is_admin());

create policy "gallery admin write"
  on rinconalpino.gallery for all to authenticated
  using (rinconalpino.is_admin()) with check (rinconalpino.is_admin());

-- 6) Storage policies (ya dropeadas arriba en el paso 3, ahora se recrean)
create policy "gallery photos public read"
  on storage.objects for select
  using (bucket_id = 'gallery-photos');
create policy "gallery photos admin write"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'gallery-photos' and rinconalpino.is_admin());
create policy "gallery photos admin update"
  on storage.objects for update to authenticated
  using (bucket_id = 'gallery-photos' and rinconalpino.is_admin());
create policy "gallery photos admin delete"
  on storage.objects for delete to authenticated
  using (bucket_id = 'gallery-photos' and rinconalpino.is_admin());

-- 7) Chequeo
select 'schemas' as label, string_agg(schema_name, ', ') as val
from information_schema.schemata where schema_name in ('public', 'rinconalpino')
union all
select 'tablas rinconalpino', string_agg(tablename, ', ')
from pg_tables where schemaname = 'rinconalpino';

-- =========================================================================
-- IMPORTANTE — habilitar el schema en la API de Supabase (self-hosted):
--
-- En hPanel / VPS con self-hosted Supabase, editar el `.env` o
-- `docker-compose.yml` del proyecto y agregar `rinconalpino` a la lista:
--
--   PGRST_DB_SCHEMAS=public,rinconalpino,storage,graphql_public
--
-- Después: `docker compose restart rest` (o reiniciar PostgREST).
--
-- En Supabase hosteado sería: Dashboard → Settings → API → Exposed Schemas
-- y agregar `rinconalpino`.
-- =========================================================================
