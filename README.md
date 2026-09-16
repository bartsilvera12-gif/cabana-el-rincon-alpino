# Cabaña El Rincón Alpino

Sitio de reservas de la Cabaña El Rincón Alpino en Luque – Yuquyry.

## Deploy en Vercel

1. Entrar a https://vercel.com/new
2. Importar este repositorio de GitHub
3. Framework Preset: **Other** (no necesita build)
4. Deploy

Vercel sirve `index.html` en la raíz automáticamente.

## Deploy en Hostinger

Como es un sitio 100% estático (HTML + JS + CSS + fotos), va en cualquier
plan de Hostinger. Dos opciones:

### Opción A — subir por File Manager (más rápido)

1. En hPanel → **Archivos → Administrador de archivos**
2. Entrar en `public_html/` y vaciarla si tiene algo (el `default.php` que
   viene por defecto).
3. Subir `hostinger-deploy.zip` (está en la raíz de este repo).
4. Click derecho sobre el zip → **Extraer** → destino `public_html/`.
5. Borrar el zip después de extraerlo.

### Opción B — subir por FTP

Credenciales: hPanel → **Archivos → Cuentas FTP**. Con FileZilla o
WinSCP, subir estos archivos/carpetas al `public_html/`:

- `index.html`
- `support.js`
- `favicon.png`
- `.htaccess`  (habilita HTTPS, gzip y cache; asegurate de mostrar archivos ocultos)
- `uploads/`   (logo + fotos)

### Después de subir

1. Probar el sitio en `https://tudominio.com`.
2. HTTPS: en hPanel → **Avanzado → SSL** — instalar el certificado gratuito
   si no lo tenés (el `.htaccess` fuerza HTTPS igual).
3. El link "Admin" en el footer entra al panel; email/pass son los del
   usuario que agregaste a `admins` en Supabase.

### Actualizaciones

Cada vez que cambie el HTML/JS/fotos, reemplazar los archivos por FTP o
subir un zip nuevo y volver a extraer.

## Base de datos (Supabase)

Antes del primer deploy, correr `supabase-schema.sql` en el SQL Editor
del proyecto Supabase (`https://api.neura.com.py`). Crea tablas,
políticas RLS, el bucket de fotos, y deja al usuario admin autorizado.

## Local

```bash
npx http-server -p 8000 -c-1
```

Abre http://localhost:8000
