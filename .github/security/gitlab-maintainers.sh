#!/usr/bin/env bash
# Prints public emails of the private GitLab project's owners/maintainers (access level >= 40).
set -euo pipefail
: "${GITLAB_TOKEN:?}" "${GITLAB_PROJECT:?}"
api=https://ci.linagora.com/api/v4
get() { curl -sSf --retry 3 -H "PRIVATE-TOKEN: $GITLAB_TOKEN" "$api/$1"; }
project=$(jq -rn --arg p "$GITLAB_PROJECT" '$p | @uri')
# members/all is paginated: read until a page comes back empty
members='[]'
for (( page = 1; ; page++ )); do
  batch=$(get "projects/$project/members/all?per_page=100&page=$page")
  [[ $(jq length <<< "$batch") -gt 0 ]] || break
  members=$(jq -c --argjson b "$batch" '. + $b' <<< "$members")
done
# filter client-side: the members API ignores min_access_level
ids=$(jq -r '.[] | select(.state == "active" and .access_level >= 40) | .id' <<< "$members")
missing=0
while read -r id; do
  [[ -n "$id" ]] || continue
  email=$(get "users/$id" | jq -r '.public_email // ""')
  # header-safe address only: it goes into the To: line
  if [[ "$email" =~ ^[^[:space:],\<\>\"]+@[^[:space:],\<\>\"]+$ ]]; then
    echo "$email"
  else
    missing=$((missing + 1))
  fi
done <<< "$ids"
(( missing == 0 )) || echo "$missing owner/maintainer(s) have no public GitLab email and were not mailed." >&2
