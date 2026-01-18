# WebSocket Authentication Proxy for JMAP Push Notifications

## Problem

TMail Flutter (and most browser-based JMAP clients) cannot use WebSocket push notifications with Stalwart Mail Server and other RFC 8887-compliant servers due to an authentication mismatch:

1. **Browser limitation**: The WebSocket API cannot set custom HTTP headers (like `Authorization`)
2. **Server requirement**: Requires `Authorization: Bearer <token>` header per RFC 8887
3. **TMail workaround**: Passes the access token as a query parameter (`?access_token=...`)

This results in WebSocket connections failing with HTTP 401 Unauthorized unless a proxy rewrites the authentication.

## Solution

A reverse proxy (nginx/OpenResty with Lua) sits between your TLS terminator and the mail server to transform the authentication:

```
Browser → TLS Proxy → ws-auth-proxy → Mail Server
          (HTTPS)    (token→header)   (WebSocket)
```

The proxy:
1. Extracts `access_token` from the query string
2. URL-decodes it (tokens contain `+` and `/` which get encoded as `%2B` and `%2F`)
3. Sets it as `Authorization: Bearer <decoded_token>` header
4. Forwards the WebSocket upgrade request to the mail server

## Server Types

### James Server (Linagora)

James uses a proprietary ticket-based authentication mechanism. TMail automatically detects this and uses ticket auth - **no proxy required**.

**How it works:**

1. TMail detects the `com:linagora:params:jmap:ws:ticket` capability in the JMAP session
2. Before connecting to WebSocket, TMail calls the ticket endpoint to obtain a one-time ticket:
   ```
   POST /jmap/ws/ticket
   Authorization: Bearer <access_token>
   ```
3. James returns a short-lived ticket (valid for ~60 seconds)
4. TMail connects to WebSocket with the ticket as query parameter:
   ```
   wss://james-server/jmap/ws?ticket=<ticket>
   ```
5. James validates the ticket and upgrades to WebSocket

**Capability detection:**
```json
{
  "capabilities": {
    "urn:ietf:params:jmap:core": { ... },
    "urn:ietf:params:jmap:websocket": {
      "supportsPush": true,
      "url": "wss://james-server/jmap/ws"
    },
    "com:linagora:params:jmap:ws:ticket": {}
  }
}
```

The presence of `com:linagora:params:jmap:ws:ticket` triggers ticket-based auth instead of token-based auth.

### Stalwart and Other RFC 8887 Servers

These servers follow the standard RFC 8887 specification which requires the `Authorization: Bearer` header. Since browsers can't set WebSocket headers, **the proxy is required**.

**Capability detection:**
```json
{
  "capabilities": {
    "urn:ietf:params:jmap:core": { ... },
    "urn:ietf:params:jmap:websocket": {
      "supportsPush": true,
      "url": "wss://mail-server/jmap/ws"
    }
  }
}
```

Without the James ticket capability, TMail passes the access token as a query parameter which must be converted to a header by the proxy.

## Proxy Configuration

### OpenResty (nginx + Lua)

```nginx
worker_processes 1;

events {
    worker_connections 1024;
}

http {
    # Case-sensitive header value - some servers require "Upgrade" not "upgrade"
    map $http_upgrade $connection_upgrade {
        default Upgrade;
        '' close;
    }

    server {
        listen 80;

        location /jmap/ws {
            # Extract and decode the access_token query parameter
            set_by_lua_block $auth_header {
                local token = ngx.var.arg_access_token
                if token and token ~= "" then
                    local decoded = ngx.unescape_uri(token)
                    return "Bearer " .. decoded
                end
                return ""
            }

            # Set Authorization header for the upstream server
            proxy_set_header Authorization $auth_header;

            # WebSocket upgrade headers
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
            proxy_set_header Host $host;

            # Timeouts for long-lived connections
            proxy_read_timeout 86400s;
            proxy_send_timeout 86400s;

            # Forward to mail server
            proxy_pass http://mail-server:8080;
        }

        # Proxy other JMAP requests normally
        location /jmap {
            proxy_pass http://mail-server:8080;
            proxy_set_header Host $host;
        }

        location /.well-known/ {
            proxy_pass http://mail-server:8080;
            proxy_set_header Host $host;
        }
    }
}
```

### Docker Compose Example

```yaml
services:
  ws-auth-proxy:
    image: openresty/openresty:alpine
    container_name: ws-auth-proxy
    volumes:
      - ./nginx-ws-proxy.conf:/usr/local/openresty/nginx/conf/nginx.conf:ro
    ports:
      - "8080:80"
    depends_on:
      - mail-server

  mail-server:
    image: stalwartlabs/mail-server:latest
    # ... your mail server config
```

## Critical Details

### Case Sensitivity Bug

Some mail servers reject WebSocket upgrades if the `Connection` header value is lowercase:
- `Connection: upgrade` → HTTP 400 "WebSocket upgrade failed"
- `Connection: Upgrade` → HTTP 101 Switching Protocols

The nginx `map` directive ensures the correct case.

### URL Encoding

OAuth tokens contain base64 characters that get URL-encoded:
- `+` → `%2B`
- `/` → `%2F`
- `=` → `%3D`

The Lua `ngx.unescape_uri()` function decodes these before setting the Authorization header.

### HTTP/2 Incompatibility

WebSocket requires the HTTP/1.1 upgrade mechanism. If your TLS terminator (Traefik, nginx, etc.) negotiates HTTP/2, WebSocket will fail. Configure your TLS options to force HTTP/1.1 for WebSocket routes:

**Traefik example:**
```yaml
tls:
  options:
    http1only:
      alpnProtocols:
        - http/1.1
```

## Testing

```bash
# Test WebSocket upgrade through the proxy
curl -v \
  -H "Upgrade: websocket" \
  -H "Connection: Upgrade" \
  -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
  -H "Sec-WebSocket-Version: 13" \
  "http://localhost:8080/jmap/ws?access_token=YOUR_URL_ENCODED_TOKEN"

# Expected: HTTP/1.1 101 Switching Protocols
```

## Troubleshooting

1. **401 Unauthorized**: Token not being extracted or decoded correctly
   - Check proxy logs for the token extraction
   - Verify the token is URL-encoded in the request

2. **400 Bad Request**: Case-sensitivity issue with Upgrade/Connection headers
   - Ensure the `map` directive uses capital "Upgrade"

3. **502 Bad Gateway**: Proxy can't reach the mail server
   - Check network connectivity between containers
   - Verify the upstream server address

4. **Connection closes immediately**: HTTP/2 negotiation issue
   - Force HTTP/1.1 in your TLS terminator configuration

## Related

- [RFC 8887 - JMAP over WebSocket](https://datatracker.ietf.org/doc/html/rfc8887)
- [Stalwart Mail Server](https://stalw.art/)
- [OpenResty](https://openresty.org/)
