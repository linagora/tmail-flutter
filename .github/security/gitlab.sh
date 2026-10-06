#!/usr/bin/env bash
# Private report sink on ci.linagora.com.
# Usage: gitlab.sh issue <title> <body-file>   (prints the new issue iid)
#        gitlab.sh note <iid> <body-file>
set -euo pipefail
: "${GITLAB_TOKEN:?}" "${GITLAB_PROJECT:?}"
api="https://ci.linagora.com/api/v4/projects/$(jq -rn --arg p "$GITLAB_PROJECT" '$p | @uri')"
post() {
  curl -sSf --retry 3 -H "PRIVATE-TOKEN: $GITLAB_TOKEN" -H "Content-Type: application/json" \
    --data-binary @- "$api/$1"
}
case "${1:-}" in
  issue) jq -n --arg t "$2" --rawfile d "$3" '{title: $t, description: $d, confidential: true, labels: "security-nightly"}' \
           | post issues | jq -r .iid ;;
  note) jq -n --rawfile b "$3" '{body: $b}' | post "issues/$2/notes" > /dev/null ;;
  *) echo "usage: gitlab.sh issue|note ..." >&2; exit 2 ;;
esac
