#!/usr/bin/env bash
# Builds .security-review/prompt-<area>.md and its inputs; shared by CI and local runs.
# Usage: prepare-review.sh <area>   env: BASE (optional ref), FINDINGS (optional findings json)
set -euo pipefail
area=${1:?usage: prepare-review.sh <area>}
sec=$(cd "$(dirname "$0")" && pwd)
cd "$(git rev-parse --show-toplevel)"
out=.security-review
prompt="$out/prompt-$area.md"
mkdir -p "$out"
cp "$sec/llm-review-prompt.md" "$prompt"
if [[ "$area" != "changes" ]]; then
  entry=$(jq -ce --arg a "$area" '.[] | select(.area == $a)' "$sec/areas.json")
  [[ -n "$entry" ]] || { echo "unknown area: $area" >&2; exit 2; }
  {
    echo; cat "$sec/llm-task-area.md"; echo
    jq -r '"Area: \(.area)\nFocus: \(.focus)\nPaths:", (.paths[] | "- \(.)")' <<< "$entry"
  } >> "$prompt"
  exit 0
fi
{ echo; cat "$sec/llm-task-changes.md"; } >> "$prompt"
base=${BASE:-}
if [[ -z "$base" ]] || ! git cat-file -e "$base^{commit}" 2>/dev/null; then
  base=$(git rev-list -n1 --before="24 hours ago" HEAD)
fi
[[ -n "$base" ]] || base=$(git rev-parse HEAD~1)
if [[ -n "${FINDINGS:-}" && -s "$FINDINGS" ]]; then
  cp "$FINDINGS" "$out/findings.json"
else
  echo '[]' > "$out/findings.json"
fi
git log --no-merges --format='%h %an %s' "$base..HEAD" > "$out/commits.txt"
git diff --stat "$base..HEAD" > "$out/diffstat.txt"
git diff -U5 "$base..HEAD" -- . \
  ':(glob,exclude)**/*.g.dart' ':(glob,exclude)**/*.mocks.dart' \
  ':(glob,exclude)**/*.arb' ':(glob,exclude)**/package-lock.json' \
  ':(glob,exclude)**/Podfile.lock' \
  > "$out/diff.patch"
