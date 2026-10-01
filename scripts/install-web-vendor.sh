#!/usr/bin/env sh

set -eux

# Installs pinned browser libs (web-vendor/package-lock.json) into web/js/vendor.
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODULES="$ROOT/web-vendor/node_modules"
OUT="$ROOT/web/js/vendor"

npm ci --prefix "$ROOT/web-vendor" --ignore-scripts --no-audit --no-fund

rm -rf "$OUT"
mkdir -p "$OUT/dotlottie-player"
cp "$MODULES"/@dotlottie/player-component/dist/*.mjs "$OUT/dotlottie-player/"
cp "$MODULES/@dotlottie/player-component/LICENSE" "$OUT/dotlottie-player/LICENSE"
cp "$MODULES/pica/dist/pica.min.js" "$OUT/pica.min.js"
cp "$MODULES/pica/LICENSE" "$OUT/pica.LICENSE"
