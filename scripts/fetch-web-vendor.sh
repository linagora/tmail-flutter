#!/usr/bin/env sh
# Downloads pinned browser libs into web/js/vendor, before `flutter build web`.
# Tarballs are checked against npm's published integrity hash, so a rebuild cannot pull in different code.

set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/web/js/vendor"
STAMP="$OUT/.pins"
DOTLOTTIE_SHA=sha512-oNv/+bVnmBY3DILdY+ehBWk15Q76m8OByq8gPDpyEQwHf0kRJ6GUO074X1m8WPgvPKw0o8dYnz+UrbOFhZmmqA==
PICA_SHA=sha512-dCeCJUOQs/aV7W5v2OLxUYq4gtGQ67C5QeLm253hAbBJj91iSivGaa/p2ApfTQqRtNhbCQU8+43T5jbyAOEInA==
PINS="$DOTLOTTIE_SHA $PICA_SHA"

# Already fetched at these pins: nothing to do
if [ -f "$STAMP" ] && [ "$(cat "$STAMP")" = "$PINS" ]; then
  echo "web/js/vendor up to date, skipping download"
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# fetch <name> <tarball-url> <integrity>: extracts the package into $tmp/<name>
fetch() {
  curl -fsSL -o "$tmp/$1.tgz" "$2"
  actual="sha512-$(openssl dgst -sha512 -binary "$tmp/$1.tgz" | openssl base64 -A)"
  if [ "$actual" != "$3" ]; then
    echo "error: integrity mismatch for $1" >&2
    echo "  expected $3" >&2
    echo "  actual   $actual" >&2
    exit 1
  fi
  mkdir -p "$tmp/$1"
  tar -xzf "$tmp/$1.tgz" -C "$tmp/$1"
}

fetch dotlottie \
  https://registry.npmjs.org/@dotlottie/player-component/-/player-component-2.7.12.tgz \
  "$DOTLOTTIE_SHA"
fetch pica \
  https://registry.npmjs.org/pica/-/pica-10.0.3.tgz \
  "$PICA_SHA"

rm -rf "$OUT"
mkdir -p "$OUT/dotlottie-player"
cp "$tmp"/dotlottie/package/dist/*.mjs "$OUT/dotlottie-player/"
cp "$tmp/dotlottie/package/LICENSE" "$OUT/dotlottie-player/LICENSE"
cp "$tmp/pica/package/dist/pica.min.js" "$OUT/pica.min.js"
cp "$tmp/pica/package/LICENSE" "$OUT/pica.LICENSE"
printf '%s' "$PINS" > "$STAMP"
