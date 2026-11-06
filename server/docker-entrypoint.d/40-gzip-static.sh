#!/bin/sh
set -e
# Mounted files like assets/env.file need a fresh .gz for gzip_static on.
gzip -k -r -f /usr/share/nginx/html/
