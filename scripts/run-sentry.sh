#!/usr/bin/env sh
# Runs sentry_dart_plugin after flutter build web.
# Injects Debug IDs into main.dart.js and uploads source maps to Sentry.
# Skipped silently if required env vars are absent.
# Fails the build if the plugin exits with an error — a deployed build with
# un-uploaded source maps is worse than a failed build, because the JS will
# contain Debug IDs that point to nothing in Sentry.

set -e

if [ -n "${SENTRY_ORG:-}" ] && [ -n "${SENTRY_PROJECT:-}" ] && [ -n "${SENTRY_AUTH_TOKEN:-}" ]; then
  echo "Running sentry_dart_plugin (Debug ID injection + source map upload)..."
  dart run sentry_dart_plugin
else
  echo "Skipping sentry_dart_plugin: SENTRY_ORG, SENTRY_PROJECT, or SENTRY_AUTH_TOKEN not set."
fi
