#!/usr/bin/env bash
# Prints the markdown email body: run info, summary, scanner findings tables, LLM area reports.
# Usage: build-report.sh <summary.md> <reports-dir>   env: REPORT_KEY RUN_URL BASE SHA
set -uo pipefail
summary=${1:?usage: build-report.sh <summary.md> <reports-dir>}; dir=${2:?}
shopt -s nullglob
# opens seal.sh output with the RSA private key
dec() {
  local K
  K=$(head -n1 "$1" | openssl base64 -d -A | openssl pkeyutl -decrypt -inkey <(printf '%s\n' "$REPORT_KEY") \
    -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256) || return 1
  tail -n +2 "$1" | K=$K openssl enc -d -aes-256-cbc -pbkdf2 -a -A -pass env:K
}
printf '**Run:** %s  \n**Range:** `%s..%s`\n\n' "$RUN_URL" "${BASE:-full history}" "$SHA"
cat "$summary"
for f in "$dir"/findings-*.enc; do
  t=$(basename "$f" .enc); t=${t#findings-}
  printf '\n## %s findings\n\n' "$t"
  dec "$f" | jq -r '
    def cell: gsub("\\s+"; " ") | ltrimstr(" ") | gsub("&"; "&amp;") | gsub("<"; "&lt;")
      | gsub(">"; "&gt;") | gsub("\\|"; "\\|")
      | gsub("(?<c>[*`\\[\\]])"; "\\\(.c)");
    def clip: if length > 1000 then .[0:1000] + "…" else . end;
    if length == 0 then "None." else
      "| Level | Rule | Location | Message |", "|---|---|---|---|",
      (.[:100][] | "| \(.level) | \(.rule // "-" | cell) | \(.at | cell) | \(.text // "" | clip | cell) |"),
      (if length > 100 then "\n… \(length - 100) more not shown" else empty end)
    end' || echo "(could not decrypt $(basename "$f"))"
done
llm=("$dir"/llm-*.enc)
(( ${#llm[@]} )) || printf '\n_No LLM area reports were produced; see the run log._\n'
for f in ${llm[@]+"${llm[@]}"}; do
  # model output can carry prompt injection from commits or code: label it, defang links
  printf '\n> **Untrusted model output below.** Verify each claim; links are defanged (hxxp).\n\n'
  dec "$f" | sed -E 's#[Hh][Tt][Tt][Pp]([Ss]?)://#hxxp\1://#g' || echo "(could not decrypt $(basename "$f"))"
done
