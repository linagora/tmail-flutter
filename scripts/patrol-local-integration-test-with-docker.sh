#!/bin/bash
set -euo pipefail

## Pre-requisites
#   - patrol_cli installed: dart pub global activate patrol_cli 4.3.1
#   - ADB installed (Android SDK platform-tools)
#   - A local Android emulator running (e.g. via Android Studio AVD)
#
# Usage:
#   ./scripts/patrol-local-integration-test-with-docker.sh

# shellcheck source=scripts/patrol-lib.sh
source "$(dirname "$0")/patrol-lib.sh"

REPORT_DIR="integration_test/report"
mkdir -p "$REPORT_DIR"
LOG_FILE="$REPORT_DIR/patrol-test-$(date +%Y%m%d-%H%M%S).log"
REPORT_FILE="$REPORT_DIR/patrol-timing-report.html"
RESET_SERVER_LOG="$REPORT_DIR/backend-reset-server.log"
RESET_PORT=9999

# 10.0.2.2 is the QEMU alias for the host machine — the Android emulator uses this
# to reach tmail-backend which is bound to host port 80.
BASIC_AUTH_URL="http://10.0.2.2"

patrol_docker_cleanup
patrol_jwt_keygen
patrol_patch_jmap_urls "http://10.0.2.2" "ws://10.0.2.2"

echo "Starting tmail-backend via Docker..."
patrol_docker_startup tmail-backend

export BOB="bob"
export ALICE="alice"
export DOMAIN="example.com"
patrol_initial_provisioning

_T=$(_now_ms)
echo "Starting backend reset server on port $RESET_PORT (logs: $RESET_SERVER_LOG)..."
RESET_PORT="$RESET_PORT" python3 scripts/backend-reset-server.py > "$RESET_SERVER_LOG" 2>&1 &
RESET_SERVER_PID=$!
sleep 1
_record_phase "reset_server_start" "$_T"

cleanup() {
  echo "Cleaning up test environment..."
  kill "$RESET_SERVER_PID" 2>/dev/null || true
  local _T
  _T=$(_now_ms)
  (cd "$BACKEND_DIR" && docker compose down)
  _record_phase "docker_teardown" "$_T"
  patrol_finalize_report "$LOG_FILE" "$REPORT_FILE" "$RESET_SERVER_LOG"
}
trap cleanup EXIT

echo "Building the app and running tests..."
patrol_run_timed \
    --hide-test-steps \
    --dart-define=USERNAME="$BOB" \
    --dart-define=PASSWORD="$BOB" \
    --dart-define=ADDITIONAL_MAIL_RECIPIENT="$ALICE@$DOMAIN" \
    --dart-define=BASIC_AUTH_EMAIL="$BOB@$DOMAIN" \
    --dart-define=BASIC_AUTH_URL="$BASIC_AUTH_URL" \
    --dart-define=RESET_SERVER_URL="http://10.0.2.2:$RESET_PORT"

exit $_PATROL_EXIT
