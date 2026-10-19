#!/usr/bin/env bash
# Regenerates the hash-pinned requirements-{semgrep,mobsfscan,report,uv}.txt from their *.in inputs.
# Existing pins are kept as uv preferences, so a Dependabot version bump is honoured and only hashes
# and affected transitive pins change. requirements-zizmor.txt has no deps; Dependabot keeps it whole.
# Usage: compile-requirements.sh   needs: uv
set -euo pipefail
cd "$(dirname "$0")"
flags="--generate-hashes --python-version 3.12 --python-platform x86_64-manylinux_2_28"

# overrides.txt follows the versions Dependabot writes into the mobsfscan lockfile
while IFS= read -r pin; do
  locked=$(grep -i -m1 "^${pin%%==*}==" requirements-mobsfscan.txt | cut -d' ' -f1 || true)
  [ -z "$locked" ] || sed -i.bak "s/^${pin}\$/${locked}/" overrides.txt
done < <(grep -E '^[A-Za-z0-9_.-]+==' overrides.txt)
rm -f overrides.txt.bak

# compile <name> [extra uv args]: <name>.in -> requirements-<name>.txt with a reproducible header
compile() {
  local name=$1 out=requirements-$1.txt; shift
  # keep only name==version as preferences: uv would otherwise reuse the old hashes for a bumped pin
  grep -E '^[A-Za-z0-9_.-]+==' "$out" | cut -d' ' -f1 > "$out.pins" || true
  mv "$out.pins" "$out"
  # shellcheck disable=SC2086
  uv pip compile $flags "$@" --no-header --quiet "$name.in" -o "$out"
  { echo "# uv pip compile $flags${*:+ $*} $name.in"
    [ $# -eq 0 ] || echo "# overrides.txt: $(grep -E '^[A-Za-z0-9_.-]+==' overrides.txt | paste -sd, - | sed 's/,/, /g') (why: see overrides.txt)"
    cat "$out"; } > "$out.tmp"
  mv "$out.tmp" "$out"
}

compile semgrep
compile mobsfscan --override overrides.txt
compile report
compile uv
