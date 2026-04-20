# Backend Setup for Development

This guide covers two ways to run Twake Mail against a backend: spinning up the local Docker backend, or pointing the app at a remote server.

---

## Option A: Local Backend with Docker

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and Docker Compose installed
- Port **80** available on your machine

### 1. Start the backend

```bash
cd backend-docker
docker compose up -d
```

The container will start and expose the JMAP HTTP endpoint on port 80.

> **Note:** The backend uses an in-memory store — all data is lost when the container stops.

### 2. Provision test users

The backend comes with a provisioning script that creates test accounts (`alice`, `bob`, `brian`, `charlotte`, `david`, `emma`) all at `example.com` with their name as the password:

```bash
docker exec tmail-backend bash /root/conf/integration_test/provisioning.sh
```

Sample credentials:
| Email | Password |
|-------|----------|
| `alice@example.com` | `alice` |
| `bob@example.com` | `bob` |

### 3. Configure `env.file`

Edit `env.file` in the project root:

```dotenv
SERVER_URL=http://localhost/
DOMAIN_REDIRECT_URL=http://localhost:3000
WEB_OIDC_CLIENT_ID=teammail-web
OIDC_SCOPES=openid,profile,email,offline_access
```

> The local backend uses **Basic Auth** (not OIDC). The login screen accepts email/password directly — no SSO setup needed.

### 4. Run the app

```bash
# Web (most convenient for local dev)
/bin/bash scripts/prebuild.sh
flutter run -d chrome
```

Log in with any provisioned user (e.g., `alice@example.com` / `alice`).

---

## Option B: Connect to a Remote Backend

### 1. Obtain backend details

Ask the backend team for:

| Field | What to ask | Example |
|-------|-------------|---------|
| `SERVER_URL` | JMAP server base URL | `https://jmap.example.com` |
| `DOMAIN_REDIRECT_URL` | **Tell them** your local origin so they register it as an allowed redirect URI on the OIDC provider | `http://localhost:2025` (must match `--web-port`) |
| `WEB_OIDC_CLIENT_ID` | OIDC client ID for web | `teammail-web-dev` |
| `OIDC_SCOPES` | Required OIDC scopes | `openid,profile,email,offline_access` |

### 2. Update `env.file`

```dotenv
SERVER_URL=https://jmap.example.com
DOMAIN_REDIRECT_URL=http://localhost:2025
WEB_OIDC_CLIENT_ID=teammail-web-dev
OIDC_SCOPES=openid,profile,email,offline_access
```

Optional fields:

```dotenv
APP_GRID_AVAILABLE=supported          # shows app grid sidebar
FCM_AVAILABLE=supported               # enables push notifications
SENTRY_ENABLED=false
SENTRY_DSN=
```

See `docs/configuration/` for full details on each flag.

### 3. Build and run

**Web:**
```bash
/bin/bash scripts/prebuild.sh

# Port must match DOMAIN_REDIRECT_URL and the redirect URI registered on the OIDC provider.
# --disable-web-security bypasses CORS restrictions during local dev.
flutter run -d chrome \
  --web-port=2025 \
  --web-browser-flag --disable-web-security
```

> **`--web-port`** must match the port in `DOMAIN_REDIRECT_URL` and the redirect URI registered with your OIDC provider. If you change the port, update both places.

---

## Configuration Reference

| File | Purpose |
|------|---------|
| `env.file` | Runtime config for web — server URL, OIDC, feature flags |
| `backend-docker/docker-compose.yaml` | Local backend service definition |
| `backend-docker/jmap.properties` | JMAP server tunables (auth strategy, WebSocket prefix) |
| `backend-docker/openpaas.properties` | OpenPaaS / DAV integration (contacts, calendar) |
| `docs/configuration/oidc_configuration.md` | OIDC setup for web and mobile |
| `docs/configuration/fcm_configuration.md` | Firebase push notification setup |

---

## Troubleshooting

**App shows "Server not found" or network error**
- Check `SERVER_URL` in `env.file` — no trailing slash issues, correct protocol (`http` vs `https`).
- For local Docker: confirm the container is running: `docker ps | grep tmail-backend`.

**Login fails on local backend**
- Ensure provisioning ran: `docker exec tmail-backend bash /root/conf/integration_test/provisioning.sh`
- The local backend authenticates with **Basic Auth** (email + password), not OIDC.

**OIDC redirect loop on remote backend**
- Verify `DOMAIN_REDIRECT_URL` matches the redirect URI registered in your OIDC provider exactly.
- Verify `WEB_OIDC_CLIENT_ID` matches the client registered in your OIDC provider.

