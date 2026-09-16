-- =========================================================================
-- Sembrar las 20 fotos locales en la tabla `gallery` (opcional, una vez).
-- Cada fila apunta al archivo bundleado en el sitio (uploads/photos/...).
-- =========================================================================

insert into gallery (path, category, sort_order, title) values
  ('uploads/photos/photo-01.jpg', 'Piscina',  1,  'Piscina + quincho'),
  ('uploads/photos/photo-02.jpg', 'Quincho',  2,  'Quincho — mesa comedor'),
  ('uploads/photos/photo-03.jpg', 'Quincho',  3,  'Sector de parrilla'),
  ('uploads/photos/photo-04.jpg', 'Piscina',  4,  'Piscina — cascada'),
  ('uploads/photos/photo-05.jpg', 'Quincho',  5,  'Quincho — sillón huevo'),
  ('uploads/photos/photo-06.jpg', 'Piscina',  6,  'Piscina'),
  ('uploads/photos/photo-07.jpg', 'Piscina',  7,  'Piscina — otra vista'),
  ('uploads/photos/photo-08.jpg', 'Cabaña',   8,  'Exterior — cabaña + piscina + quincho'),
  ('uploads/photos/photo-09.jpg', 'Cabaña',   9,  'A-frame frontal'),
  ('uploads/photos/photo-10.jpg', 'Cabaña',   10, 'A-frame + piscina al atardecer'),
  ('uploads/photos/photo-11.jpg', 'Quincho',  11, 'Fogata + hamacas'),
  ('uploads/photos/photo-12.jpg', 'Quincho',  12, 'Quincho — interior'),
  ('uploads/photos/photo-13.jpg', 'Cocina',   13, 'Living + cocina abierta'),
  ('uploads/photos/photo-14.jpg', 'Interior', 14, 'Living con sofá'),
  ('uploads/photos/photo-15.jpg', 'Cocina',   15, 'Cocina equipada'),
  ('uploads/photos/photo-16.jpg', 'Interior', 16, 'Mesa comedor interior'),
  ('uploads/photos/photo-17.jpg', 'Interior', 17, 'TV + rack'),
  ('uploads/photos/photo-18.jpg', 'Interior', 18, 'Living amplio'),
  ('uploads/photos/photo-19.jpg', 'Cabaña',   19, 'A-frame frontal simétrico'),
  ('uploads/photos/photo-20.jpg', 'Interior', 20, 'TV grande + fogata deco')
on conflict do nothing;

select count(*) as fotos_en_galeria from gallery;
