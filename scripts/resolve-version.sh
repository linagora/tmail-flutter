#!/usr/bin/env bash
# Resolve application version from CI tag context or repository tags.
# Output format: x.y.z (without leading "v").

set -euo pipefail

explicit_input="${1:-}"

normalize_version() {
  local raw="${1:-}"
  raw="${raw#v}"
  echo "$raw"
}

is_semver_core() {
  [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

if [[ -n "$explicit_input" ]]; then
  version="$(normalize_version "$explicit_input")"
  if is_semver_core "$version"; then
    echo "$version"
    exit 0
  fi
fi

# Prefer explicit tag context from GitHub Actions.
if [[ -n "${GITHUB_REF:-}" && "${GITHUB_REF}" =~ ^refs/tags/v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  version="$(normalize_version "${GITHUB_REF#refs/tags/}")"
  echo "$version"
  exit 0
fi

if [[ "${GITHUB_REF_TYPE:-}" == "tag" && -n "${GITHUB_REF_NAME:-}" ]]; then
  version="$(normalize_version "${GITHUB_REF_NAME}")"
  if is_semver_core "$version"; then
    echo "$version"
    exit 0
  fi
fi

# Fallback: highest semver-like tag in repository.
latest_tag="$(git tag --list "v*.*.*" --sort=-version:refname | head -n 1)"
if [[ -n "$latest_tag" ]]; then
  version="$(normalize_version "$latest_tag")"
  if is_semver_core "$version"; then
    echo "$version"
    exit 0
  fi
fi

echo "Unable to resolve version from explicit input, CI tag context, or repository tags" >&2
exit 1
