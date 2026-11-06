#!/bin/bash
# The Jenkins PATH prefix points at /opt/flutter-$FLUTTER_VERSION/bin. A missing
# directory is skipped, so the agent SDK would run instead. Fail before prebuild.
set -eu

expected="${FLUTTER_VERSION:?FLUTTER_VERSION is required}"
if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter ${expected} is required (FLUTTER_ROOT=${FLUTTER_ROOT:-unset}). flutter is not on PATH." >&2
  exit 1
fi

output="$(flutter --version 2>&1 || true)"
actual="$(printf '%s\n' "$output" | awk '$1=="Flutter" { print $2; exit }')"
if [ "$actual" != "$expected" ]; then
  echo "Flutter ${expected} is required (FLUTTER_ROOT=${FLUTTER_ROOT:-unset}). Found: ${actual:-unparsed}" >&2
  printf '%s\n' "$output" >&2
  exit 1
fi

echo "Flutter ${actual}"
