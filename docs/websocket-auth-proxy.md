# WebSocket Authentication Proxy Configuration

This document explains how to configure a reverse proxy to enable WebSocket push notifications with JMAP servers that don't support ticket-based authentication (like Stalwart).

## Background

### The Browser WebSocket Limitation

Browsers cannot set custom HTTP headers (like `Authorization: Bearer <token>`) on WebSocket connections. This is a fundamental limitation of the WebSocket API:

```javascript
// This is NOT possible in browsers:
const ws = new WebSocket('wss://server/ws', {
  headers: { 'Authorization': 'Bearer token' }  // ❌ Not supported
});
```

### Server Authentication Approaches

Different JMAP servers handle this limitation differently:

| Server | Authentication Method | Proxy Required |
|--------|----------------------|----------------|
| **Apache James** | Ticket-based (`?ticket=...`) | No |
| **Stalwart** | Bearer token header | Yes |
| **Cyrus** | Bearer token header | Yes |
| **Other RFC 8887** | Bearer token header | Yes |

### How TMail Solves This

TMail uses a **Strategy Pattern** to support multiple authentication methods:

1. **TicketAuthStrategy**: For James servers - requests a ticket via POST, then connects with `?ticket=`
2. **TokenAuthStrategy**: For OIDC servers - passes `access_token` as query parameter
3. **BasicAuthStrategy**: For Basic auth - passes `authorization` as query parameter

For non-James servers, a reverse proxy must convert query parameters to headers.

## Reverse Proxy Configuration

### Nginx Configuration

```nginx
# WebSocket proxy for Stalwart/RFC 8887 JMAP servers
location /jmap/ws {
    # Extract access_token from query string and set as Authorization header
    set $auth_header "";
    if ($arg_access_token) {
        set $auth_header "Bearer $arg_access_token";
    }
    if ($arg_authorization) {
        set $auth_header $arg_authorization;
    }

    proxy_pass http://stalwart:8080/jmap/ws;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    # Set Authorization header from query parameter
    proxy_set_header Authorization $auth_header;

    # WebSocket timeouts
    proxy_read_timeout 86400;
    proxy_send_timeout 86400;
}
```

### Caddy Configuration

```caddyfile
example.com {
    # WebSocket proxy with auth header injection
    handle /jmap/ws* {
        # Use request matcher to extract token
        @has_token query access_token=*

        reverse_proxy @has_token stalwart:8080 {
            header_up Authorization "Bearer {query.access_token}"
            header_up -access_token
        }

        # Fallback for requests without token
        reverse_proxy stalwart:8080
    }
}
```

### Traefik Configuration

```yaml
# traefik.yml
http:
  routers:
    jmap-ws:
      rule: "PathPrefix(`/jmap/ws`)"
      service: stalwart
      middlewares:
        - ws-auth

  middlewares:
    ws-auth:
      plugin:
        queryToHeader:
          paramName: "access_token"
          headerName: "Authorization"
          headerPrefix: "Bearer "

  services:
    stalwart:
      loadBalancer:
        servers:
          - url: "http://stalwart:8080"
```

### HAProxy Configuration

```haproxy
frontend https
    bind *:443 ssl crt /etc/ssl/certs/cert.pem

    # WebSocket detection
    acl is_websocket hdr(Upgrade) -i websocket
    acl is_jmap_ws path_beg /jmap/ws

    use_backend stalwart_ws if is_websocket is_jmap_ws
    default_backend stalwart_http

backend stalwart_ws
    # Extract access_token and set Authorization header
    http-request set-header Authorization "Bearer %[urlp(access_token)]" if { urlp(access_token) -m found }

    server stalwart stalwart:8080
```

## Security Considerations

### Token Exposure in URLs

Query parameters may appear in:
- Server access logs
- Browser history
- Proxy logs
- Network monitoring tools

**Mitigations:**
1. Use short-lived access tokens with refresh tokens
2. Configure log redaction for sensitive parameters
3. Always use HTTPS/WSS
4. Implement token rotation

### Log Redaction Example (Nginx)

```nginx
# Redact access_token from logs
log_format redacted '$remote_addr - $remote_user [$time_local] '
                    '"$request_uri_redacted" $status $body_bytes_sent';

map $request_uri $request_uri_redacted {
    ~^(.*)access_token=[^&]*(.*)$ "$1access_token=[REDACTED]$2";
    default $request_uri;
}

access_log /var/log/nginx/access.log redacted;
```

## Testing the Configuration

### 1. Verify Proxy is Working

```bash
# Test WebSocket upgrade with token
curl -i -N \
  -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Version: 13" \
  -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
  "https://your-server/jmap/ws?access_token=YOUR_TOKEN"
```

### 2. Check Server Receives Authorization Header

```bash
# On the mail server, check logs for Authorization header
journalctl -u stalwart -f | grep -i authorization
```

### 3. Test Full Connection from TMail

1. Open TMail web application
2. Open browser DevTools → Network tab
3. Filter by "WS" (WebSocket)
4. Verify connection is established
5. Check for push notifications when new mail arrives

## Troubleshooting

### Connection Fails with 401

**Cause:** Authorization header not being set or token is invalid.

**Check:**
1. Verify proxy is extracting query parameter correctly
2. Check token is valid and not expired
3. Ensure proxy is URL-decoding the token

### Connection Closes Immediately

**Cause:** WebSocket upgrade not being forwarded properly.

**Check:**
1. Verify `Upgrade: websocket` header is forwarded
2. Check `Connection: upgrade` header is set
3. Ensure HTTP/1.1 is being used (not HTTP/2 for WebSocket)

### No Push Notifications

**Cause:** Server may not support push or capability detection issue.

**Check:**
1. Verify server has WebSocket capability in JMAP session
2. Check `supportsPush` is not explicitly `false`
3. Verify WebSocket connection stays open (check for timeouts)

## Related Resources

- [RFC 8887 - JMAP over WebSocket](https://datatracker.ietf.org/doc/html/rfc8887)
- [Stalwart JMAP Documentation](https://stalw.art/docs/jmap/)
- [TMail Flutter WebSocket Implementation](../lib/features/push_notification/data/datasource/strategies/)
