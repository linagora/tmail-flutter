#!/usr/bin/env sh
# Injects Sentry config from env vars into pubspec.yaml sentry: block.
# Must be called from the repo root BEFORE flutter build.
#
# Required : SENTRY_PROJECT, SENTRY_ORG
# Optional : SENTRY_RELEASE (default: pubspec version, e.g. 0.28.3)
#            SENTRY_DIST    (default: GITHUB_SHA if set, else empty)
# Auth     : SENTRY_AUTH_TOKEN — consumed by sentry_dart_plugin; not written here.

set -eu

SENTRY_PROJECT="${SENTRY_PROJECT:-}"
SENTRY_ORG="${SENTRY_ORG:-}"

if [ -z "${SENTRY_PROJECT}" ] || [ -z "${SENTRY_ORG}" ]; then
  echo "Skipping Sentry configuration: SENTRY_PROJECT or SENTRY_ORG not set."
  exit 0
fi

if [ -z "${GITHUB_SHA:-}" ] && [ -z "${SENTRY_DIST:-}" ]; then
  echo "Skipping Sentry configuration: GITHUB_SHA is required for SENTRY_DIST when SENTRY_DIST is not explicitly set."
  exit 0
fi

_pubspec_ver=$(grep "^version:" pubspec.yaml | tr -d ' ' | cut -d: -f2)
SENTRY_RELEASE="${SENTRY_RELEASE:-$(echo "${_pubspec_ver}" | cut -d'+' -f1)}"
SENTRY_DIST="${SENTRY_DIST:-${GITHUB_SHA}}"

echo "Configuring Sentry: release=${SENTRY_RELEASE} dist=${SENTRY_DIST} url_prefix=~/"

perl -pi -e "s|^  project:.*|  project: ${SENTRY_PROJECT}|" pubspec.yaml
perl -pi -e "s|^  org:.*|  org: ${SENTRY_ORG}|" pubspec.yaml
perl -pi -e "s|^  release:.*|  release: ${SENTRY_RELEASE}|" pubspec.yaml
perl -pi -e "s|^  dist:.*|  dist: \"${SENTRY_DIST}\"|" pubspec.yaml
perl -pi -e 's|^  url_prefix:.*|  url_prefix: ~/|' pubspec.yaml
