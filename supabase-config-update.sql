-- =========================================================================
-- Tarifas y WhatsApp al día — correr una vez en el SQL Editor de Supabase.
-- Solo toca la fila de configuración (id = 1); no borra ni migra nada.
--
-- Después de esto, el cliente puede seguir cambiando estos mismos valores
-- desde el panel → Configuración, sin tocar SQL nunca más.
-- =========================================================================

update config set
  price_weekday = 550000,        -- lunes a viernes
  price_weekend = 700000,        -- sábados y domingos
  whatsapp      = '595987502862' -- +595 987 502862 (WhatsApp Business)
where id = 1;

-- Para revisar cómo quedó:
select price_weekday, price_weekend, whatsapp from config where id = 1;
