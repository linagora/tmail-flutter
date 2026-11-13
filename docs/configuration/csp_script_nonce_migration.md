## Migrating to the per-request script nonce CSP

### What changes
Enforcing `script-src` no longer allows `'unsafe-inline'`. Each response gets a fresh nonce (`$request_id`). Nginx rewrites `__CSP_NONCE__` in `index.html` to that value. Flutter bootstrap, the composer, the mail viewer and print HTML stamp the same nonce on their own scripts. `printing` 5.12.0 `layoutPdf` still injects a fixed no-nonce inline helper, so `script-src` also allows `'sha256-+M0fGRkOqgYlCQCff9oNQn6k6a7Si4Et8iofLMceadE='`.

Without the nginx rewrite and matching CSP header, the app still boots, but scripts stamped with `__CSP_NONCE__` are blocked, so the viewer, composer and print break silently.

### Who must change

| Deployment | Action |
|---|---|
| Stock `linagora/tmail-web` image (default `nginx.conf` from the image) | Upgrade the image. No extra config. |
| Helm chart `linagora/tmail-frontend` with the stock image and no custom nginx mount | Upgrade the image tag or digest only. `extraEnv` for `CSP_*` stays as today. No new chart values. |
| Custom `nginx.conf` mounted over the image | Keep `include /etc/nginx/csp-headers.conf;` on every `server` / `location` that declares its own `add_header`. Keep the exact `location = /index.html` block that runs `sub_filter '__CSP_NONCE__' '$request_id'` with `gzip_static off`, `etag off` and `if_modified_since off`. Copy that block from this repo's `server/nginx.conf`. |
| Custom `/etc/nginx/csp-headers.conf` mount | Use a template that puts `'nonce-$request_id'` (and the printing sha256 source) in both enforcing and report-only `script-src`, and drop `'unsafe-inline'` from `script-src`. |
| Proxy or CDN in front of the app | Do not cache `index.html` (or any document that still holds `__CSP_NONCE__` or an old nonce). The body nonce must match the CSP header of the same response. |

### Migration steps
1. Inventory mounts of `nginx.conf` and `csp-headers.conf`, and any CDN rule that caches HTML.
2. Align custom nginx with `server/nginx.conf` and `server/csp-headers.conf.template` from the release (nonce `sub_filter` + headers without `script-src 'unsafe-inline'`).
3. Roll out the new `linagora/tmail-web` image (Helm: bump the image, leave chart values unless you mount a custom conf).
4. Confirm one HTML response: both CSP headers carry `'nonce-<value>'`, the body has `nonce="<value>"` on `flutter_bootstrap.js`, no `__CSP_NONCE__` remains, and `script-src` has no `unsafe-inline`.
5. Smoke the browser console under the enforced policy for boot, composer, mail viewer and PDF print (`Printing.layoutPdf`).

### Rollback
Revert to the previous image tag. Custom confs that already dropped `unsafe-inline` must restore it or keep the nonce wiring if they stay on the new app bits.
