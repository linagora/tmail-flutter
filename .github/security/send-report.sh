#!/usr/bin/env bash
# Emails a report file to the private GitLab project's owners/maintainers.
# Usage: send-report.sh <body-file>   (MAIL_FROM = bare address)   env: GITLAB_TOKEN GITLAB_PROJECT SMTP_URL SMTP_USER SMTP_PASSWORD MAIL_FROM MAIL_SUBJECT
set -euo pipefail
: "${SMTP_URL:?}" "${SMTP_USER:?}" "${SMTP_PASSWORD:?}" "${MAIL_FROM:?}" "${MAIL_SUBJECT:?}"
body=${1:?usage: send-report.sh <body-file>}
# capture first so a GitLab API failure stops the script instead of looking like "no recipients"
list=$(bash "$(dirname "$0")/gitlab-maintainers.sh")
mapfile -t rcpts < <(sort -u <<< "$list" | sed '/^$/d')
if (( ${#rcpts[@]} == 0 )); then
  echo "::error::No GitLab owner/maintainer has a public email; report not sent."
  exit 1
fi
args=()
for r in "${rcpts[@]}"; do args+=(--mail-rcpt "$r"); done
mail=$(mktemp)
trap 'rm -f "$mail"' EXIT
{
  printf 'From: %s\r\nTo: %s\r\nSubject: %s\r\nDate: %s\r\nMIME-Version: 1.0\r\nContent-Type: text/plain; charset=UTF-8\r\nContent-Transfer-Encoding: base64\r\n\r\n' \
    "$MAIL_FROM" "$(IFS=,; echo "${rcpts[*]}")" "$MAIL_SUBJECT" "$(date -R)"
  # base64: no bare LF, no over-long lines
  base64 < "$body" | sed 's/$/\r/'
} > "$mail"
# credentials via stdin config, not argv; escape \ and " for curl's quoted values
cred=$(printf '%s:%s' "$SMTP_USER" "$SMTP_PASSWORD" | sed 's/[\\"]/\\&/g')
printf 'user = "%s"\n' "$cred" \
  | curl -sS --fail --retry 3 --ssl-reqd -K - --url "$SMTP_URL" \
      --mail-from "$MAIL_FROM" "${args[@]}" --upload-file "$mail"
echo "Report emailed to ${#rcpts[@]} recipient(s)."
