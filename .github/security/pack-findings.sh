#!/usr/bin/env bash
# Publishes only the finding count; the findings travel encrypted to the private report.
# Usage: pack-findings.sh <tool> <sarif>...   env: REPORT_KEY (optional), RUNNER_TEMP, GITHUB_OUTPUT
set -euo pipefail
tool=${1:?usage: pack-findings.sh <tool> <sarif>...}; shift
sec=$(cd "$(dirname "$0")" && pwd)
digest="$RUNNER_TEMP/findings-$tool.json"
bash "$sec/sarif-digest.sh" "$@" > "$digest"
echo "count=$(jq length "$digest")" >> "$GITHUB_OUTPUT"
# artifacts of a public repo are downloadable: ship only ciphertext
if [[ -n "${REPORT_KEY:-}" ]]; then
  openssl enc -aes-256-cbc -pbkdf2 -salt -pass env:REPORT_KEY -in "$digest" -out "$RUNNER_TEMP/findings-$tool.enc"
fi
rm -f "$digest"
