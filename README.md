# Cabaña El Rincón Alpino

Sitio de reservas de la Cabaña El Rincón Alpino en Luque – Yuquyry.

## Deploy en Vercel

1. Entrar a https://vercel.com/new
2. Importar este repositorio de GitHub
3. Framework Preset: **Other** (no necesita build)
4. Deploy

Vercel sirve `index.html` en la raíz automáticamente.

## Deploy en Hostinger (conectando este repo por Git)

Como el sitio es 100% estático, Hostinger lo puede clonar directo desde
GitHub y desplegarlo automáticamente en cada `push` a `main`.

### Setup inicial (una sola vez)

1. hPanel → tu sitio → **Avanzado → GIT**.
2. **Create Repository** con:
   - **Repository URL**: `https://github.com/bartsilvera12-gif/cabana-el-rincon-alpino.git`
   - **Branch**: `main`
   - **Install Path**: `public_html` (dejalo vacío o poné `.`)
3. **Create** → Hostinger hace el primer clone en `public_html/`.
4. En la misma pantalla, copiar el **Webhook URL** que aparece.

### Auto-deploy en cada push

1. En GitHub abrir el repo → **Settings → Webhooks → Add webhook**.
2. **Payload URL**: pegar el webhook que dio Hostinger.
3. **Content type**: `application/json`.
4. **Which events?**: *Just the push event*.
5. **Active** ✓ → **Add webhook**.

Desde ahí, cada `git push origin main` tira un webhook a Hostinger que
hace `git pull` en `public_html/` y el sitio actualiza solo.

### Después del primer deploy

1. hPanel → **Avanzado → SSL** → instalar Let's Encrypt gratis.
2. Probar `https://tudominio.com` — el `.htaccess` fuerza HTTPS y
   activa gzip + cache de assets.
3. Link "Admin" en el footer → login con el email/pass del usuario
   en la tabla `admins` de Supabase.

### Deploy manual (sin webhook)

En hPanel → **Avanzado → GIT** → botón **Deploy** (pull manual).

## Base de datos (Supabase)

Antes del primer deploy, correr `supabase-schema.sql` en el SQL Editor
del proyecto Supabase (`https://api.neura.com.py`). Crea tablas,
políticas RLS, el bucket de fotos, y deja al usuario admin autorizado.

## Local

```bash
npx http-server -p 8000 -c-1
```

Abre http://localhost:8000
