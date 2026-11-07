## Configuration Content Security Policy (web)

### Context
- The `linagora/tmail-web` image sends a `Content-Security-Policy` header on every page.
- By default the app only trusts its own origin. It cannot be embedded by another site,
  cannot frame other sites and cannot load scripts from a CDN.
- Deployments that embed Twake Mail (Twake Workplace / Cozy), use the Drive picker,
  load the Cozy bridge or use a non-https backend must list
  those origins with the variables below.
- A second header, `Content-Security-Policy-Report-Only`, applies the same policy
  without `'unsafe-inline'`. It blocks nothing; it only reports.

### How to config
Set environment variables on the web container. Each value is a space-separated list
of CSP sources and is appended to the matching directive.

| Variable | Directive | Default | Needed when |
|---|---|---|---|
| `CSP_FRAME_ANCESTORS` | `frame-ancestors` (replaces) | `'self'` | Twake Mail is embedded by another site (Twake Workplace / Cozy) |
| `CSP_FRAME_SRC` | `frame-src` | empty | Drive picker (Cozy intents) |
| `CSP_SCRIPT_SRC` | `script-src` | empty | Cozy bridge from jsdelivr |
| `CSP_CONNECT_SRC` | `connect-src` | empty | Backend on `http://` / `ws://` (https and wss are already allowed) |
| `CSP_IMG_SRC` | `img-src` | empty | Showing `http:` images in mails (https is already allowed) |
| `CSP_REPORT_URI` | `report-uri` of the report-only header | empty | Collecting violation reports |

Each source needs scheme, host and port: `http://localhost` only allows port 80.
`CSP_FRAME_ANCESTORS` replaces the default, so keep `'self'` in it.
`CSP_REPORT_URI` must be a single http or https URL.

#### Twake Workplace / Cozy (Helm chart `linagora/tmail-frontend`)
The chart passes `extraEnv` to the container; no chart change is needed.
```yaml
extraEnv:
  - name: CSP_FRAME_ANCESTORS
    value: "'self' https://*.mycozy.cloud"
  - name: CSP_FRAME_SRC
    value: "https://*.mycozy.cloud"
  - name: CSP_SCRIPT_SRC
    value: "https://cdn.jsdelivr.net/npm/cozy-external-bridge@1.3.0/"
```
Keep the bridge version in sync with the one the app loads.

#### Docker / docker-compose
```bash
docker run -e CSP_FRAME_ANCESTORS="'self' https://*.mycozy.cloud" \
           -e CSP_FRAME_SRC="https://*.mycozy.cloud" \
           -e CSP_SCRIPT_SRC="https://cdn.jsdelivr.net/npm/cozy-external-bridge@1.3.0/" \
           linagora/tmail-web:<version>
```
Local backend on port 8000: `CSP_CONNECT_SRC="http://localhost:8000 ws://localhost:8000"`.

### Upgrading from a version without CSP
Set the variables **before or together with** the new image. Without them:
- `CSP_FRAME_ANCESTORS` missing: the embedded app shows a blank frame.
- `CSP_FRAME_SRC` missing: the Drive picker does not open.
- `CSP_SCRIPT_SRC` missing: the Cozy bridge does not load (duplicate header, no Drive, no history sync).

Older images ignore `CSP_*`, so the variables can be added first.

### Limits
- The variables are applied by the image entrypoint at start. A custom command must
  start with `nginx`.
- With a read-only root filesystem the entrypoint cannot rewrite the headers: the
  defaults baked in the image are used and `CSP_*` is ignored. Mount your own
  `/etc/nginx/csp-headers.conf` instead.
- A mounted custom `nginx.conf` must keep `include /etc/nginx/csp-headers.conf;` in
  every `server` / `location` that declares its own `add_header`, or the page is
  served without the policy.
- `script-src` keeps `'unsafe-inline'` because the mail viewer and the composer
  render through `srcdoc` iframes. The policy protects against clickjacking,
  plugins, `<base>` and form exfiltration; it is not an XSS barrier.
