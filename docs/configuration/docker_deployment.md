## Docker Deployment Configuration

### Context
- TMail web application can be deployed using Docker
- The application requires environment configuration to connect to a JMAP backend server
- Configuration is bundled at build time via `env.file`, but can be overridden at runtime

### Environment Variables

The main configuration file is `env.file` at the project root. Key variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `SERVER_URL` | JMAP backend server URL (with trailing slash) | `https://mail.example.com/` |
| `DOMAIN_REDIRECT_URL` | URL for OIDC redirects | `https://webmail.example.com` |
| `WEB_OIDC_CLIENT_ID` | OIDC client ID for web app | `teammail-web` |
| `OIDC_SCOPES` | Comma-separated OIDC scopes | `openid,profile,email,offline_access` |
| `APP_GRID_AVAILABLE` | Enable app grid dashboard | `supported` or `unsupported` |
| `FCM_AVAILABLE` | Enable Firebase push notifications | `supported` or `unsupported` |

### Deployment Methods

#### Method 1: Build-time Configuration (Recommended for production images)

Edit `env.file` before building the Docker image:

```bash
# Edit env.file
SERVER_URL=https://mail.example.com/
DOMAIN_REDIRECT_URL=https://webmail.example.com
WEB_OIDC_CLIENT_ID=your-oidc-client-id

# Build the image
docker build -t tmail-web:latest .

# Run the container
docker run -d -p 8080:80 --name tmail-web tmail-web:latest
```

Access the application at `http://localhost:8080`

#### Method 2: Runtime Configuration (Mount env file)

Use the official image and mount a custom environment file at runtime:

```bash
# Create your production env file
cat > env.prod.file << 'EOF'
SERVER_URL=https://mail.example.com/
DOMAIN_REDIRECT_URL=https://webmail.example.com
WEB_OIDC_CLIENT_ID=your-oidc-client-id
OIDC_SCOPES=openid,profile,email,offline_access
APP_GRID_AVAILABLE=supported
FCM_AVAILABLE=unsupported
EOF

# Run with mounted env file
docker run -d -p 8080:80 \
  --mount type=bind,source="$(pwd)"/env.prod.file,target=/usr/share/nginx/html/assets/env.file \
  --name tmail-web \
  linagora/tmail-web:latest
```

This method allows using the same Docker image with different configurations.

### Docker Compose Example

For a complete deployment with a JMAP backend (e.g., Stalwart):

```yaml
version: "3"

services:
  tmail-web:
    image: linagora/tmail-web:latest
    ports:
      - "8080:80"
    volumes:
      - ./env.prod.file:/usr/share/nginx/html/assets/env.file:ro
    depends_on:
      - mail-server

  mail-server:
    image: stalwartlabs/stalwart:latest
    ports:
      - "443:443"
      - "25:25"
      - "587:587"
      - "993:993"
    volumes:
      - stalwart-data:/opt/stalwart

volumes:
  stalwart-data:
```

### Troubleshooting

#### OIDC Discovery Errors to localhost

**Symptom**: Browser console shows errors like:
```
Failed to load resource: net::ERR_CONNECTION_REFUSED localhost/.well-known/openid-configuration
```

**Cause**: The `SERVER_URL` in `env.file` is set to `http://localhost/` (the default value).

**Solution**:
1. Update `env.file` with your actual JMAP server URL
2. Rebuild the Docker image, OR
3. Mount a corrected env file at runtime (see Method 2 above)

#### Application Stuck on Loading Screen

**Cause**: Usually indicates `SERVER_URL` is not configured correctly or the JMAP server is unreachable.

**Debug steps**:
1. Check browser console for OIDC/network errors
2. Verify `SERVER_URL` points to a valid JMAP server
3. Ensure the JMAP server's `.well-known/jmap` endpoint is accessible
4. Check CORS configuration on the JMAP server

### Reverse Proxy Configuration

When deploying behind a reverse proxy (nginx, Traefik, etc.), ensure:

1. WebSocket connections are properly proxied for real-time updates
2. The `X-Forwarded-Proto` header is set for HTTPS detection
3. Large request bodies are allowed for email attachments

Example nginx configuration:
```nginx
location / {
    proxy_pass http://tmail-web:80;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

### Related Documentation

- [OIDC Configuration](oidc_configuration.md)
- [FCM Configuration](fcm_configuration.md)
- [WebSocket Echo Ping](ws_echo_ping_configuration.md)
