#!/bin/bash
#
# Builds what start.sh runs, from the working tree:
# - the web app image, with the release Dockerfile;
# - with --mobile-version, the release APK of the Android app instead (Dockerfile.android, signed
#   with a key generated for the QA), in the image tmail-mobile-qa-apk: like the web app image, it
#   survives a cleaning of the working tree, for start.sh after a build skipped.
# The backend image is pulled by start.sh.
#
#   scripts/qa-environment/build.sh    # once, and whenever the code under test changes
#   scripts/qa-environment/build.sh --mobile-version
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

MOBILE=false
for arg in "$@"; do
  case "$arg" in
    --mobile-version) MOBILE=true ;;
    *) echo "Unknown argument: $arg (--mobile-version)" >&2; exit 2 ;;
  esac
done

# host network: pub get fails from the default bridge network on some hosts
if [ "$MOBILE" = true ]; then
  DOCKER_BUILDKIT=1 docker build --network host -t tmail-mobile-qa-apk \
    -f "$SCRIPT_DIR/Dockerfile.android" "$REPO_DIR"
else
  docker build --network host -t tmail-web-qa -f "$REPO_DIR/Dockerfile" "$REPO_DIR"
fi
