#!/usr/bin/env bash
# Scanners and LLM area audits share one runner and run in parallel.
# The LLM key never enters scanner processes; GH_TOKEN never enters opencode.
# Usage: run-scan.sh   env: LLM_ENABLED AREAS PARALLEL BASE + run-scanners.sh and run-llm-area.sh env
set -uo pipefail
sec=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$OUT" .security-review
llm_pid=""
if [[ "$LLM_ENABLED" == "true" ]]; then
  export OPENCODE_CONFIG="$RUNNER_TEMP/opencode.json"
  jq -n --arg model "$LLM_MODEL" '{
    "$schema": "https://opencode.ai/config.json",
    autoupdate: false,
    share: "disabled",
    provider: { "security-llm": {
      npm: "@ai-sdk/openai-compatible",
      name: "Security LLM",
      options: { baseURL: "{env:LLM_BASE_URL}", apiKey: "{env:LLM_API_KEY}" },
      models: { ($model): { name: $model } }
    } },
    model: ("security-llm/" + $model),
    permission: { edit: "deny", bash: "deny", webfetch: "deny", external_directory: "deny" }
  }' > "$OPENCODE_CONFIG"
  audits=$(jq -r '.[] | select(. != "changes")' <<< "$AREAS")
  for a in $audits; do bash "$sec/prepare-review.sh" "$a"; done
  # area audits don't need scanner output: start them before the scanners
  env -u GH_TOKEN xargs -r -P "$PARALLEL" -I{} bash "$sec/run-llm-area.sh" {} <<< "$audits" &
  llm_pid=$!
fi
env -u LLM_API_KEY -u LLM_BASE_URL -u LLM_MODEL bash "$sec/run-scanners.sh"
llm='{"status": "skipped", "count": 0, "found": false}'
if [[ "$LLM_ENABLED" == "true" ]]; then
  if jq -e 'index("changes")' <<< "$AREAS" > /dev/null; then
    BASE="$BASE" FINDINGS="$RUNNER_TEMP/findings.json" bash "$sec/prepare-review.sh" changes
    env -u GH_TOKEN bash "$sec/run-llm-area.sh" changes
  fi
  wait "$llm_pid"
  shopt -s nullglob
  codes=("$OUT"/llm-status/*)
  failed=0
  for c in "${codes[@]}"; do [[ "$(cat "$c")" == 0 ]] || failed=$((failed + 1)); done
  status=$([[ $failed -eq 0 && ${#codes[@]} -gt 0 ]] && echo success || echo failure)
  llm=$(jq -nc --arg s "$status" --argjson c "${#codes[@]}" '{status: $s, count: $c, found: false}')
fi
jq -c --argjson llm "$llm" '. + {"llm-review": $llm}' "$OUT/results.json" > "$OUT/results.tmp" \
  && mv "$OUT/results.tmp" "$OUT/results.json"
echo "results=$(cat "$OUT/results.json")" >> "$GITHUB_OUTPUT"
