#!/usr/bin/env bash
# Runs one opencode review area and encrypts its report the moment it ends.
# A key failing on quota or auth, or silent for 10 minutes, is skipped by all areas for 10 minutes; the area reruns on the next key.
# Usage: run-llm-area.sh <area>   env: OPENCODE_CONFIG LLM_API_KEYS (one per line) LLM_* REPORT_PUBLIC_KEY OUT RUNNER_TEMP
set -uo pipefail
area=${1:?usage: run-llm-area.sh <area>}
bin="$RUNNER_TEMP/opencode/node_modules/.bin/opencode"
home="$RUNNER_TEMP/opencode-$area"
dead="$RUNNER_TEMP/llm-dead-keys"
mkdir -p "$dead" "$OUT/llm-status"
mapfile -t keys < <(tr -d ' \t\r' <<< "${LLM_API_KEYS:-}" | grep .)
# opencode processes see one key at most, never the list
unset LLM_API_KEYS
key_error='quota|rate.?limit|too many requests|resource.?exhausted|insufficient.?(quota|balance|funds|credits?)|(credit|account) balance|out of credits|billing.?(hard.?)?limit|payment required|unauthori[sz]ed|forbidden|authentication (failed|error)|invalid.{0,20}key|incorrect.{0,20}key|key not valid|valid api key|(status|code)[^0-9]{0,3}(401|402|403|429)'
report=".security-review/llm-$area.md"
partial="$RUNNER_TEMP/llm-partial-$area.md"; : > "$partial"
# one 40m budget for the area across all keys
deadline=$((SECONDS + 2400))
stall=${LLM_STALL_SECONDS:-600}
code=1; used=0; switched=""
for i in "${!keys[@]}"; do
  # a rate limit resets: a dead key is skipped for 10 minutes, then tried again
  [[ -z $(find "$dead/$i" -mmin -10 2>/dev/null) ]] || continue
  left=$((deadline - SECONDS))
  (( left > 60 )) || { code=124; break; }
  used=$((i + 1))
  # own session store per process and attempt: parallel runs never share one
  rm -rf "$home"
  export XDG_DATA_HOME="$home/data" XDG_STATE_HOME="$home/state" XDG_CACHE_HOME="$home/cache"
  mkdir -p "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"
  LLM_API_KEY=${keys[$i]} timeout "${left}s" "$bin" run "$(cat ".security-review/prompt-$area.md")" \
    > "$report" 2> "$home/stderr.log" &
  pid=$!
  # an exhausted key can make opencode wait out a long Retry-After in silence: no output for $stall s = stuck
  stalled=0 last=-1 idle=0
  while kill -0 "$pid" 2>/dev/null; do
    sleep 5
    size=$(( $(wc -c < "$report") + $(wc -c < "$home/stderr.log") ))
    if (( size != last )); then last=$size idle=0; else idle=$((idle + 5)); fi
    if (( idle >= stall )) && kill -0 "$pid" 2>/dev/null; then
      stalled=1; kill "$pid" 2>/dev/null
      echo "Key $used stalled: no output for ${stall}s (rate-limit wait?); trying the next key." >> "$home/stderr.log"
      break
    fi
  done
  wait "$pid"; code=$?
  # exit 0 wins: the audit may have finished right as the stall check fired
  if (( stalled && code != 0 )); then code=1; else
    if (( code == 0 || code == 124 )) || ! grep -Eiq "$key_error" "$home/stderr.log"; then break; fi
  fi
  touch "$dead/$i"
  # the next attempt truncates $report: keep what this key already printed
  if [[ -s "$report" ]]; then
    { printf '\n### Output of key %s before it failed\n\n' "$used"; cat "$report"; } >> "$partial"
  fi
  # key counts and quota state go only into the sealed report: run logs are public
  switched+="${switched:+, }$used"
done
if (( used == 0 )); then
  mkdir -p "$home"; : > "$report"
  echo "No usable LLM key left: all ${#keys[@]} out of quota or rejected." > "$home/stderr.log"
fi
echo "$code" > "$OUT/llm-status/$area"
echo "LLM area $area: exit $code"
{
  echo "## LLM review: $area"; echo "Key $used of ${#keys[@]}."
  [[ -z $switched ]] || echo "Out of quota or rejected: key $switched."
  echo
  if [[ -s "$report" ]]; then cat "$report"; else echo "(no output)"; fi
  [[ ! -s "$partial" ]] || cat "$partial"
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
