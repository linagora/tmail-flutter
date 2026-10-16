#!/usr/bin/env bash
# Runs one opencode review area and encrypts its report the moment it ends.
# Usage: run-llm-area.sh <area>   env: OPENCODE_CONFIG LLM_* REPORT_PUBLIC_KEY OUT RUNNER_TEMP
set -uo pipefail
area=${1:?usage: run-llm-area.sh <area>}
bin="$RUNNER_TEMP/opencode/node_modules/.bin/opencode"
home="$RUNNER_TEMP/opencode-$area"
# own session store per process: parallel runs never share one
export XDG_DATA_HOME="$home/data" XDG_STATE_HOME="$home/state" XDG_CACHE_HOME="$home/cache"
mkdir -p "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME" "$OUT/llm-status"
report=".security-review/llm-$area.md"
timeout 40m "$bin" run "$(cat ".security-review/prompt-$area.md")" > "$report" 2> "$home/stderr.log"
code=$?
echo "$code" > "$OUT/llm-status/$area"
echo "LLM area $area: exit $code"
{
  echo "## LLM review: $area"; echo
  if [[ -s "$report" ]]; then cat "$report"; else echo "(no output)"; fi
  if (( code != 0 )); then
    reason=""; [[ $code != 124 ]] || reason=" (40m timeout)"
    printf '\n**opencode exited with code %s%s; the output above may be incomplete.**\n' "$code" "$reason"
    # stderr and the session go only into the encrypted report: run logs are public
    printf '\n### stderr (last 40 lines)\n\n~~~~\n'; tail -n 40 "$home/stderr.log"; printf '~~~~\n'
    sid=$("$bin" session list --format json --max-count 1 2>/dev/null | jq -r '.[0].id // empty')
    if [[ -n "$sid" ]]; then
      printf '\n### Session text before the failure (last 200 lines)\n\n~~~~\n'
      "$bin" export "$sid" 2>/dev/null \
        | jq -r '.messages[] | select(.info.role == "assistant") | .parts[] | select(.type == "text") | .text' \
        | tail -n 200
      printf '~~~~\n'
    fi
  fi
} | bash "$(dirname "$0")/seal.sh" "$OUT/llm-$area.enc"
