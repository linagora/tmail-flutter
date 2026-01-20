## Configuration for SERVER_URL

### Context
- TMail connects to a JMAP-compatible mail server backend
- The `SERVER_URL` environment variable specifies the backend server address
- This URL is used for all API requests including OIDC discovery, JMAP operations, and WebSocket connections

### How to Configure

Set `SERVER_URL` in the `env.file` at the project root:

```
SERVER_URL=https://your-jmap-server.example.com/
```

**Important**: Include the trailing slash (`/`) in the URL.

### OIDC Discovery

When OIDC authentication is enabled, TMail derives the OIDC discovery URLs from `SERVER_URL`:

1. `{SERVER_URL}.well-known/openid-configuration`
2. `{SERVER_URL}.well-known/oidc-configuration`

The app also attempts WebFinger-based discovery using the email domain.

### Platform-Specific Notes

#### Web
The `SERVER_URL` is bundled into the web application at build time. To change it:
- Edit `env.file` and rebuild, OR
- Mount a custom env file at runtime (see [Docker Deployment](docker_deployment.md))

#### Mobile (Android/iOS)
The `SERVER_URL` is bundled into the mobile app at build time. Users can also enter a custom server URL on the login screen.

### Common Issues

#### localhost URLs in Production

**Symptom**: OIDC errors pointing to `localhost`:
```
Failed to load resource: localhost/.well-known/openid-configuration
```

**Cause**: `SERVER_URL` defaults to `http://localhost/` in the repository's `env.file`.

**Solution**: Set `SERVER_URL` to your actual JMAP server URL before building.

#### CORS Errors

**Symptom**: Browser console shows CORS policy errors.

**Cause**: The JMAP server doesn't allow requests from your web app's origin.

**Solution**: Configure CORS on your JMAP server to allow the web app's domain.

#### WebSocket Connection Failures

**Symptom**: Real-time updates don't work, WebSocket errors in console.

**Cause**: The server URL scheme or WebSocket endpoint is misconfigured.

**Solution**:
1. Ensure `SERVER_URL` uses HTTPS for secure WebSocket (`wss://`)
2. Verify the JMAP server supports WebSocket push
3. Check reverse proxy WebSocket configuration

### Related Configuration

- [OIDC Configuration](oidc_configuration.md) - OIDC client settings
- [Docker Deployment](docker_deployment.md) - Container deployment options
- [WebSocket Echo Ping](ws_echo_ping_configuration.md) - WebSocket keep-alive settings
