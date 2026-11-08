#!/bin/sh
set -e
# [ -w ] is true for root on a read-only mount. Keep the headers baked at build.
if ! probe=$(mktemp /etc/nginx/.w.XXXXXX 2>/dev/null); then
  echo "warning: /etc/nginx is not writable; using the CSP headers baked into the image. Runtime CSP_* values are ignored." >&2
  exit 0
fi
rm -f "$probe"

envsubst '${CSP_FRAME_ANCESTORS} ${CSP_FRAME_SRC} ${CSP_SCRIPT_SRC} ${CSP_CONNECT_SRC} ${CSP_IMG_SRC}' \
  < /etc/nginx/csp-headers.conf.template > /etc/nginx/csp-headers.conf
