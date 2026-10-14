#!/usr/bin/env bash
# Installs every scanner, checksum- or hash-pinned, into $BIN and $VENVS. Runs without secrets.
# Usage: install-scanners.sh   env: BIN VENVS RUNNER_TEMP
set -euo pipefail
sec=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$BIN" "$VENVS"
cd "$RUNNER_TEMP"
get() { curl -sSfLO "$1"; }

u=https://github.com/gitleaks/gitleaks/releases/download/v8.30.1
get "$u/gitleaks_8.30.1_linux_x64.tar.gz"; get "$u/gitleaks_8.30.1_checksums.txt"
grep " gitleaks_8.30.1_linux_x64.tar.gz$" gitleaks_8.30.1_checksums.txt | sha256sum -c -
tar -xzf gitleaks_8.30.1_linux_x64.tar.gz -C "$BIN" gitleaks

u=https://github.com/google/osv-scanner/releases/download/v2.6.0
get "$u/osv-scanner_linux_amd64"; get "$u/osv-scanner_SHA256SUMS"
grep " osv-scanner_linux_amd64$" osv-scanner_SHA256SUMS | sha256sum -c -
install -m 755 osv-scanner_linux_amd64 "$BIN/osv-scanner"

get https://github.com/aquasecurity/trivy/releases/download/v0.70.0/trivy_0.70.0_Linux-64bit.tar.gz
echo "8b4376d5d6befe5c24d503f10ff136d9e0c49f9127a4279fd110b727929a5aa9  trivy_0.70.0_Linux-64bit.tar.gz" | sha256sum -c -
tar -xzf trivy_0.70.0_Linux-64bit.tar.gz -C "$BIN" trivy

get https://github.com/ossf/scorecard/releases/download/v5.5.0/scorecard_5.5.0_linux_amd64.tar.gz
echo "83b90a05c1540ef1390db1cd5711e5fd04be9c1d8537fb84d39d02092d6a8dff  scorecard_5.5.0_linux_amd64.tar.gz" | sha256sum -c -
tar -xzf scorecard_5.5.0_linux_amd64.tar.gz -C "$BIN" scorecard

# one venv per tool; --no-deps: the lockfiles are complete (mobsfscan's overrides semgrep's mcp/pyjwt pins)
pids=()
for t in semgrep mobsfscan zizmor; do
  { python3 -m venv "$VENVS/$t" \
      && "$VENVS/$t/bin/pip" install --quiet --require-hashes --no-deps -r "$sec/requirements-$t.txt"; } &
  pids+=($!)
done
for p in "${pids[@]}"; do wait "$p" || exit 1; done
