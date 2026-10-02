#!/bin/bash
#
# Builds the web app image start.sh runs, from the working tree, with the release Dockerfile.
# The backend image is pulled by start.sh.
#
#   scripts/qa-environment/build.sh    # once, and whenever the code under test changes
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# host network: pub get fails from the default bridge network on some hosts
docker build --network host -t tmail-web-qa -f "$REPO_DIR/Dockerfile" "$REPO_DIR"
