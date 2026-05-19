#!/bin/bash
set -euo pipefail

## Pre-requisites
#   - patrol_cli installed: dart pub global activate patrol_cli 4.3.1
#
# Usage:
#   ./scripts/patrol-web-local-integration-test-with-docker.sh

# shellcheck source=scripts/patrol-lib.sh
source "$(dirname "$0")/patrol-lib.sh"

REPORT_DIR="integration_test/report"
mkdir -p "$REPORT_DIR"
LOG_FILE="$REPORT_DIR/patrol-web-test-$(date +%Y%m%d-%H%M%S).log"
REPORT_FILE="$REPORT_DIR/patrol-web-timing-report.html"

BASIC_AUTH_URL="http://localhost"
WEBSOCKET_URL="ws://localhost"

patrol_docker_cleanup
patrol_jwt_keygen
patrol_patch_jmap_urls "$BASIC_AUTH_URL" "$WEBSOCKET_URL"

echo "Starting services via Docker..."
patrol_docker_startup

export BOB="bob"
export ALICE="alice"
export DOMAIN="example.com"
patrol_initial_provisioning

export RESET_PORT=9999

RESET_SERVER_LOG="/tmp/backend-reset-server.log"
echo "Starting backend reset server on port $RESET_PORT (logs: $RESET_SERVER_LOG)..."
RESET_PORT="$RESET_PORT" python3 scripts/backend-reset-server.py > "$RESET_SERVER_LOG" 2>&1 &
RESET_SERVER_PID=$!

cleanup() {
  echo "Cleaning up test environment..."
  kill "$RESET_SERVER_PID" 2>/dev/null || true
  patrol_finalize_report "$LOG_FILE" "$REPORT_FILE" "$RESET_SERVER_LOG"
  (cd "$BACKEND_DIR" && docker compose down)
}
trap cleanup EXIT

echo "Copying integration_test/integration_test_env.file to env.file..."
cp integration_test/integration_test_env.file env.file

echo "Building the app and running tests..."
patrol_run_timed \
    --tags=web \
    --device=chrome \
    --web-port=3000 \
    --web-browser-args='["--lang=en-US","--accept-lang=en-US,en"]' \
    --dart-define=USERNAME="$BOB" \
    --dart-define=PASSWORD="$BOB" \
    --dart-define=ADDITIONAL_MAIL_RECIPIENT="$ALICE@$DOMAIN" \
    --dart-define=BASIC_AUTH_EMAIL="$BOB@$DOMAIN" \
    --dart-define=BASIC_AUTH_URL="$BASIC_AUTH_URL" \
    --dart-define=RESET_SERVER_URL="http://localhost:$RESET_PORT"

exit $_PATROL_EXIT
