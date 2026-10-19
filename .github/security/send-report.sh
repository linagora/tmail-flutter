#!/usr/bin/env bash
# Emails a report (plain text + HTML) to the private GitLab project's owners/maintainers.
# Usage: send-report.sh <body.md> <body.html>   (MAIL_FROM = bare address)   env: GITLAB_TOKEN GITLAB_PROJECT SMTP_URL SMTP_USER SMTP_PASSWORD MAIL_FROM MAIL_SUBJECT
set -euo pipefail
: "${SMTP_URL:?}" "${SMTP_USER:?}" "${SMTP_PASSWORD:?}" "${MAIL_FROM:?}" "${MAIL_SUBJECT:?}"
body=${1:?usage: send-report.sh <body.md> <body.html>}
html=${2:?usage: send-report.sh <body.md> <body.html>}
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
to=$(printf '%s,' "${rcpts[@]}"); to=${to%,}
boundary="=_sec_$(openssl rand -hex 12)"
part() { # <content-type> <file>
  printf -- '--%s\r\nContent-Type: %s; charset=UTF-8\r\nContent-Transfer-Encoding: base64\r\n\r\n' "$boundary" "$1"
  # base64: no bare LF, no over-long lines
  base64 < "$2" | sed 's/$/\r/'
}
{
  printf 'From: %s\r\nTo: %s\r\nSubject: %s\r\nDate: %s\r\nMIME-Version: 1.0\r\nContent-Type: multipart/alternative; boundary="%s"\r\n\r\n' \
    "$MAIL_FROM" "$to" "$MAIL_SUBJECT" "$(date -R)" "$boundary"
  # clients show the last part they support: plain text first, HTML preferred
  part text/plain "$body"
  part text/html "$html"
  printf -- '--%s--\r\n' "$boundary"
} > "$mail"
# credentials via stdin config, not argv; escape \ and " for curl's quoted values
cred=$(printf '%s:%s' "$SMTP_USER" "$SMTP_PASSWORD" | sed 's/[\\"]/\\&/g')
printf 'user = "%s"\n' "$cred" \
  | curl -sS --fail --retry 3 --ssl-reqd -K - --url "$SMTP_URL" \
      --mail-from "$MAIL_FROM" "${args[@]}" --upload-file "$mail"
echo "Report emailed to ${#rcpts[@]} recipient(s)."
