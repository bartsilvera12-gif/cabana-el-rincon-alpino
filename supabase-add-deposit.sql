-- =========================================================================
-- Agrega la columna `deposit` (monto de la seña) a reservations.
-- Necesaria para guardar la seña de las reservas cargadas a mano.
-- Corré esto UNA VEZ en el SQL Editor. Es idempotente (podés reintentarlo).
-- =========================================================================

alter table if exists rinconalpino.reservations
  add column if not exists deposit bigint;
