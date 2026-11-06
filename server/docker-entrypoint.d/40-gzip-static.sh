#!/bin/sh
set -e
# Mounted files like assets/env.file need a fresh .gz for gzip_static.
# A read-only directory, such as custom logos, cannot take a .gz file.
# Skip those files so startup still reaches nginx. Any other gzip error still stops startup.
list=$(mktemp)
find /usr/share/nginx/html -type f ! -name '*.gz' -print0 |
  while IFS= read -r -d '' file; do
    if [ -w "$(dirname "$file")" ]; then
      printf '%s\0' "$file"
    fi
  done > "$list"
if [ -s "$list" ]; then
  xargs -0 gzip -k -f < "$list"
fi
rm -f "$list"
