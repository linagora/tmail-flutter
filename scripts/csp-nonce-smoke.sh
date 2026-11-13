#!/usr/bin/env bash
# Serves web/index.html through the production nginx config and checks that every
# entry path gets a fresh script nonce matching its CSP headers.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
image=$(sed -n 's/^FROM \(nginx:[^ ]*\).*/\1/p' "$root/Dockerfile")
name="csp-nonce-smoke-$$"

cleanup() { docker rm -f "$name" >/dev/null 2>&1 || true; }
trap cleanup EXIT

docker run -d --name "$name" -p 127.0.0.1::80 \
  -e CSP_FRAME_ANCESTORS="'self'" \
  -v "$root/server/nginx.conf:/etc/nginx/nginx.conf:ro" \
  -v "$root/server/csp-headers.conf.template:/etc/nginx/csp-headers.conf.template:ro" \
  -v "$root/server/docker-entrypoint.d/21-render-csp-headers.sh:/docker-entrypoint.d/21-render-csp-headers.sh:ro" \
  -v "$root/server/docker-entrypoint.d/25-csp-report-uri.sh:/docker-entrypoint.d/25-csp-report-uri.sh:ro" \
  -v "$root/web/index.html:/usr/share/nginx/html/index.html:ro" \
  "$image" >/dev/null
base="http://$(docker port "$name" 80/tcp | head -n 1)"

for _ in $(seq 1 30); do
  curl -fs -o /dev/null "$base/" && break
  sleep 0.5
done

fail() { echo "FAIL $1: $2" >&2; docker logs "$name" >&2 || true; exit 1; }

# Prints the body nonce of one request after checking it against both CSP headers.
check() {
  local path=$1 response headers body nonce header policy
  response=$(curl -fsS -D - "$base$path") || fail "$path" "request failed"
  headers=${response%%$'\r\n\r\n'*}
  body=${response#*$'\r\n\r\n'}
  [[ $body != *__CSP_NONCE__* ]] || fail "$path" "placeholder left in body"
  nonce=$(printf '%s' "$body" | sed -n 's/.*<script src="flutter_bootstrap.js" nonce="\([^"]*\)".*/\1/p' | head -n 1)
  [[ -n $nonce ]] || fail "$path" "no nonce on flutter_bootstrap.js"
  for header in Content-Security-Policy Content-Security-Policy-Report-Only; do
    policy=$(printf '%s\n' "$headers" | grep -i "^$header:" | head -n 1)
    [[ -n $policy ]] || fail "$path" "missing $header"
    [[ $policy == *"'nonce-$nonce'"* ]] || fail "$path" "$header nonce differs from the body"
    printf '%s' "$policy" | grep -o "script-src[^;]*" | grep -q "unsafe-inline" \
      && fail "$path" "$header script-src allows unsafe-inline"
    printf '%s' "$policy" | grep -o "script-src[^;]*" \
      | grep -Fq "sha256-+M0fGRkOqgYlCQCff9oNQn6k6a7Si4Et8iofLMceadE=" \
      || fail "$path" "$header script-src missing printing layoutPdf sha256"
  done
  printf '%s' "$nonce"
}

for path in / /index.html /dashboard; do
  first=$(check "$path")
  second=$(check "$path")
  [[ $first != "$second" ]] || fail "$path" "nonce reused across requests"
  echo "ok $path"
done
