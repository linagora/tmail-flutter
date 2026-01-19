# Deploy TMail web with Stalwart + Nginx (Ubuntu 24.04)

This guide assumes:

- Stalwart is already running on the same host.
- Nginx is already configured and handling TLS.
- You are deploying the TMail web app as static files (no Docker required).
- URLs:
  - Stalwart (JMAP) endpoint: `https://admin.x-mail.au`
  - TMail web app: `https://app.x-mail.au`

## 1) Configure the JMAP backend URL

Update `env.file` before building so the web app points to Stalwart JMAP:

```bash
SERVER_URL=https://admin.x-mail.au/
```

> **Note**: If your Stalwart JMAP endpoint is on a different path (for example, `/jmap`), update `SERVER_URL` accordingly.

### Recommended `env.file` values for your setup

Below is a complete `env.file` example aligned with your domains and a Stalwart-backed login. Only change `WEB_OIDC_CLIENT_ID` and `OIDC_SCOPES` if you have an OIDC provider configured. Otherwise, keep the defaults and the app will fall back to basic authentication.

```env
SERVER_URL=https://admin.x-mail.au/
DOMAIN_REDIRECT_URL=https://app.x-mail.au
WEB_OIDC_CLIENT_ID=teammail-web
OIDC_SCOPES=openid,profile,email,offline_access
APP_GRID_AVAILABLE=supported
FCM_AVAILABLE=supported
IOS_FCM=supported
FORWARD_WARNING_MESSAGE=
PLATFORM=other
WS_ECHO_PING=
COZY_INTEGRATION=
COZY_EXTERNAL_BRIDGE_VERSION=
```

## 2) Build the web app

From the repository root:

```bash
/bin/bash scripts/prebuild.sh
flutter build web
```

The static site output is written to `build/web`.

## 3) Deploy the built assets

Copy the build output to a web root used by Nginx (matching your config):

```bash
sudo mkdir -p /var/www/webmail
sudo rsync -av --delete build/web/ /var/www/webmail/
```

## 4) Nginx server block (app.x-mail.au)

If your Nginx is already set up, ensure the `app.x-mail.au` server points to the static build output and includes a SPA fallback. This mirrors your current layout:

```nginx
server {
    listen 443 ssl http2;
    server_name app.x-mail.au;
    ssl_certificate /etc/letsencrypt/live/admin.x-mail.au/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/admin.x-mail.au/privkey.pem;

    root /var/www/webmail;
    index index.html;

    location ~* \.(js|css|wasm|json|svg|png|ico|webmanifest|woff2?)$ {
        add_header Cache-Control "public, max-age=31536000, immutable";
        try_files $uri =404;
    }

    location / {
        try_files $uri /index.html;
    }
}
```

Reload Nginx after changes:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

## 5) Nginx server block (admin.x-mail.au)

For the Stalwart Admin UI (reverse proxy to `127.0.0.1:8080`), this matches your current setup:

```nginx
server {
    listen 443 ssl http2;
    server_name admin.x-mail.au;
    ssl_certificate /etc/letsencrypt/live/admin.x-mail.au/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/admin.x-mail.au/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

## 6) Stalwart config notes (CORS + public URLs)

Make sure Stalwart allows the web app origin in CORS so the browser can call JMAP from `https://app.x-mail.au`:

```toml
[cors]
allow_origins = ["https://app.x-mail.au"]
allow_credentials = true
allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"]
allow_headers = ["Authorization", "Content-Type", "Accept", "Origin", "X-Requested-With"]
max_age = 86400
```

Also ensure Stalwart’s public URLs match your `admin.x-mail.au` hostname:

```toml
[server]
hostname = "admin.x-mail.au"
public_base_url = "https://admin.x-mail.au"
issuer = "https://admin.x-mail.au"
external_url = "https://admin.x-mail.au"
```

## 7) Rebuild + redeploy workflow

When you change the `env.file` or update the code:

```bash
/bin/bash scripts/prebuild.sh
flutter build web
sudo rsync -av --delete build/web/ /var/www/webmail/
```
