#!/bin/sh
set -e
# Mounted files like assets/env.file need a fresh .gz for gzip_static.
# [ -w ] is true for root on a read-only mount, so probe with a real create.
# A directory that refuses the probe is skipped. Any other gzip error still stops startup.
# A read-only root often has no writable /tmp. /var/run and /var/cache/nginx are the tmpfs nginx already needs.
list=
for dir in "${TMPDIR:-/tmp}" /tmp /var/run /var/cache/nginx; do
  if list=$(mktemp "$dir/.gzip.XXXXXX" 2>/dev/null); then
    break
  fi
done
if [ -z "$list" ]; then
  echo "warning: no writable directory for the gzip list; skipping gzip_static" >&2
  exit 0
fi
find /usr/share/nginx/html -type d -print0 |
  while IFS= read -r -d '' dir; do
    probe=$(mktemp "$dir/.w.XXXXXX" 2>/dev/null) || continue
    rm -f "$probe"
    find "$dir" -maxdepth 1 -type f ! -name '*.gz' -print0
  done > "$list"
if [ -s "$list" ]; then
  xargs -0 gzip -k -f < "$list"
fi
rm -f "$list"
