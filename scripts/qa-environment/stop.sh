#!/bin/bash
#
# Stops the QA environment started by start.sh. The backend stores everything in memory: its data
# is gone once stopped.
#
#   scripts/qa-environment/stop.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

QA_PROJECT="${QA_PROJECT:-tmail-qa}"

# compose interpolates the whole file even to stop it
export TMAIL_BACKEND_IMAGE=unused QA_JMAP_PORT=0 QA_WEB_PORT=0
docker compose -p "$QA_PROJECT" -f "$SCRIPT_DIR/docker-compose.yaml" down --volumes
echo "==> QA environment '$QA_PROJECT' stopped"
