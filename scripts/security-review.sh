#!/usr/bin/env bash
# Local security review: same prompts as the CI release scan, answered by your own LLM agent.
# Usage: bash scripts/security-review.sh [--base <ref>] [--scan] [--agent "<cmd>"] <area|all|list>
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
sec=.github/security
usage="usage: bash scripts/security-review.sh [--base <ref>] [--scan] [--agent \"<cmd>\"] <area|all|list>"
base="" scan=false agent=""
while (( $# )); do
  case "$1" in
    --base) base=$(git rev-parse --verify "${2:?$usage}^{commit}"); shift 2 ;;
    --scan) scan=true; shift ;;
    --agent) agent=${2:?$usage}; shift 2 ;;
    -h|--help) echo "$usage"; exit 0 ;;
    *) break ;;
  esac
done
target=${1:?$usage}
command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }
areas=$(jq -r '"changes", .[].area' "$sec/areas.json")
case "$target" in
  list) echo "$areas"; exit 0 ;;
  all) selected=$areas ;;
  *) grep -qx -- "$target" <<< "$areas" || { echo "unknown area: $target (try: list)" >&2; exit 2; }
     selected=$target ;;
esac
# default range: previous release tag..HEAD, like the CI release scan
[[ -n "$base" ]] || base=$(git describe --tags --abbrev=0 --match 'v[0-9]*.[0-9]*.[0-9]*' HEAD^ 2>/dev/null || true)

run_tool() {
  if ! command -v "$1" >/dev/null; then echo "skip: $1 not installed" >&2; return; fi
  "$@" || echo "note: $1 exited non-zero (findings or error)" >&2
}

run_scanners() {
  local dir=.security-review/scan range=HEAD
  rm -rf "$dir" && mkdir -p "$dir"
  [[ -z "$base" ]] || range="$base..HEAD"
  run_tool gitleaks git --log-opts="$range" --redact --exit-code 0 --report-format sarif --report-path "$dir/gitleaks.sarif" .
  run_tool trivy fs --scanners vuln,misconfig --severity HIGH,CRITICAL --ignore-unfixed --format sarif --output "$dir/trivy.sarif" .
  run_tool osv-scanner scan source -r --format sarif --output "$dir/osv.sarif" .
  run_tool semgrep scan --metrics=off --config p/default --config p/secrets --config p/javascript \
    --config p/dockerfile --config p/github-actions --sarif --output "$dir/semgrep.sarif" .
  run_tool mobsfscan --sarif -o "$dir/mobsfscan.sarif" android ios
  local files=("$dir"/*.sarif)
  [[ -e "${files[0]}" ]] || files=()
  bash "$sec/sarif-digest.sh" ${files[@]+"${files[@]}"} > "$dir/findings.json"
  echo "scanner findings: $(jq length "$dir/findings.json") (SARIF in $dir)"
}

mkdir -p .security-review
findings=""
if $scan; then run_scanners; findings=.security-review/scan/findings.json; fi
for area in $selected; do
  BASE="$base" FINDINGS="$findings" bash "$sec/prepare-review.sh" "$area"
  prompt=".security-review/prompt-$area.md"
  if [[ -z "$agent" ]]; then echo "prompt ready: $prompt"; continue; fi
  read -ra cmd <<< "$agent"
  echo "reviewing $area with ${cmd[0]}..."
  "${cmd[@]}" "$(cat "$prompt")" > ".security-review/report-$area.md" \
    || echo "agent failed on $area; partial output in .security-review/report-$area.md" >&2
done
[[ -z "$agent" ]] || echo "reports: .security-review/report-*.md"
