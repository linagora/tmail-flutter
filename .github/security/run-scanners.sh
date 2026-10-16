#!/usr/bin/env bash
# Runs every scanner in parallel; writes encrypted digests and results.json to $OUT.
# Usage: run-scanners.sh   env: BIN VENVS OUT BASE REPO EVENT GH_TOKEN REPORT_PUBLIC_KEY(optional) RUNNER_TEMP
set -uo pipefail
sec=$(cd "$(dirname "$0")" && pwd)
sarif="$RUNNER_TEMP/sarif"; logs="$RUNNER_TEMP/scan-logs"
mkdir -p "$sarif" "$logs" "$OUT"
export sec sarif

scan_gitleaks() {
  local range=HEAD code
  if [[ -n "${BASE:-}" ]] && git cat-file -e "$BASE^{commit}" 2>/dev/null; then range="$BASE..HEAD"; fi
  "$BIN/gitleaks" git --log-opts="$range" --redact --exit-code 2 \
    --report-format sarif --report-path "$sarif/gitleaks.sarif" .
  code=$?
  [[ $code -ne 2 ]] || touch "$sarif/gitleaks.found"
  [[ $code -eq 0 || $code -eq 2 ]]
}
scan_trivy() {
  local code
  # exit 5 = vulns found; 1 = trivy itself failed (e.g. DB download)
  "$BIN/trivy" fs --scanners vuln --severity HIGH,CRITICAL --ignore-unfixed \
    --format sarif --output "$sarif/trivy-vuln.sarif" --exit-code 5 .
  code=$?
  [[ $code -ne 5 ]] || touch "$sarif/trivy.found"
  (( code == 0 || code == 5 )) || return "$code"
  # misconfig is advisory; run after vuln so the two never race on trivy's cache
  "$BIN/trivy" fs --scanners misconfig --severity HIGH,CRITICAL \
    --format sarif --output "$sarif/trivy-misconfig.sarif" --exit-code 0 .
}
scan_osv() {
  "$BIN/osv-scanner" scan source -r --format sarif --output "$sarif/osv.sarif" .
  (( $? <= 1 )) # 1 = vulns found (advisory)
}
scan_semgrep() {
  PATH="$VENVS/semgrep/bin:$PATH" semgrep scan --metrics=off \
    --config p/default --config p/secrets --config p/javascript \
    --config p/dockerfile --config p/github-actions \
    --sarif --output "$sarif/semgrep.sarif" .
}
scan_mobsfscan() {
  local canary="$RUNNER_TEMP/mobsfscan-canary"
  export PATH="$VENVS/mobsfscan/bin:$PATH"
  # canary: a known-bad line must be flagged, or the semgrep engine broke silently
  mkdir -p "$canary"
  printf 'class Canary {\n  void f(android.webkit.WebView w) {\n    w.setWebContentsDebuggingEnabled(true);\n  }\n}\n' > "$canary/Canary.java"
  mobsfscan --json -o "$canary.json" "$canary" > /dev/null
  jq -e '.results.webview_debugging' "$canary.json" > /dev/null \
    || { echo "mobsfscan canary not flagged: engine broken"; return 1; }
  # non-zero exit means findings; a missing SARIF file means the scanner broke
  mobsfscan --sarif -o "$sarif/mobsfscan.sarif" android ios > /dev/null
  test -s "$sarif/mobsfscan.sarif"
}
scan_zizmor() {
  # sarif output exits 0 with findings, so non-zero means zizmor itself failed
  "$VENVS/zizmor/bin/zizmor" --format sarif . > "$sarif/zizmor.sarif"
}
scan_scorecard() {
  # same target choice as scorecard-action: PRs scan the checkout, releases the repo via API
  local target=(--repo="github.com/$REPO")
  [[ "$EVENT" != "pull_request" ]] || target=(--local=.)
  ENABLE_SARIF=1 GITHUB_AUTH_TOKEN="$GH_TOKEN" "$BIN/scorecard" "${target[@]}" --format=sarif \
    --show-details --policy="$sec/scorecard-policy.yml" > "$sarif/scorecard.sarif"
}
export -f scan_gitleaks scan_trivy scan_osv scan_semgrep scan_mobsfscan scan_zizmor scan_scorecard

tools=(gitleaks trivy osv semgrep mobsfscan zizmor scorecard)
pids=()
for t in "${tools[@]}"; do
  # scanners are third-party code: only zizmor and scorecard get the GitHub token
  drop=()
  [[ $t == zizmor || $t == scorecard ]] || drop=(-u GH_TOKEN)
  env ${drop[@]+"${drop[@]}"} timeout 20m bash -c "scan_$t" > "$logs/$t.log" 2>&1 &
  pids+=($!)
done

results='{}'
for i in "${!tools[@]}"; do
  t=${tools[$i]}
  if wait "${pids[$i]}"; then status=success; else status=failure; fi
  echo "$t: $status"
  # scanner logs carry finding counts: public only when the tool itself failed
  [[ $status == success ]] || { echo "::group::$t log"; cat "$logs/$t.log"; echo "::endgroup::"; }
  files=()
  for f in "$sarif/$t"*.sarif; do [[ ! -s "$f" ]] || files+=("$f"); done
  digest="$RUNNER_TEMP/findings-$t.json"
  if ! bash "$sec/sarif-digest.sh" ${files[@]+"${files[@]}"} > "$digest"; then
    status=failure
    echo '[]' > "$digest"
  fi
  found=false; [[ ! -e "$sarif/$t.found" ]] || found=true
  # artifacts of a public repo are downloadable: ship only ciphertext
  [[ -z "${REPORT_PUBLIC_KEY:-}" ]] || bash "$sec/seal.sh" "$OUT/findings-$t.enc" < "$digest"
  results=$(jq -c --arg t "$t" --arg s "$status" --argjson c "$(jq length "$digest")" --argjson f "$found" \
    '.[$t] = {status: $s, count: $c, found: $f}' <<< "$results")
done
# the LLM "changes" area triages these five (llm-task-changes.md names them)
for t in gitleaks trivy osv semgrep mobsfscan; do cat "$RUNNER_TEMP/findings-$t.json"; done \
  | jq -s 'add // []' > "$RUNNER_TEMP/findings.json"
echo "$results" > "$OUT/results.json"
