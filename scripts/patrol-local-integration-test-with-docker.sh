#!/bin/bash
set -euo pipefail

## Pre-requisites
#   - patrol_cli installed: dart pub global activate patrol_cli 4.3.1
#   - ADB installed (Android SDK platform-tools)
#   - A local Android emulator running (e.g. via Android Studio AVD)
#
# Usage:
#   ./scripts/patrol-local-integration-test-with-docker.sh

# Each test leases a fresh tmail-backend container from the reset server (slots on ports 8100+).
POOL_SIZE="${POOL_SIZE:-3}"

cd backend-docker || exit 1

# Generate JWT keys if not already present
if [[ ! -f jwt_privatekey ]]; then
    echo "Generating keys for tmail-backend..."
    openssl genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:4096 -out jwt_privatekey
    openssl rsa -in jwt_privatekey -pubout -out jwt_publickey
fi
cd ..

export BOB="bob"
export ALICE="alice"
export DOMAIN="example.com"

# 10.0.2.2 is QEMU's hardcoded alias for the host — reaches the backend slots on ports 8100+
export BASIC_AUTH_URL="http://10.0.2.2:8100"
export RESET_PORT=9999

RESET_SERVER_LOG="/tmp/backend-reset-server.log"
echo "Starting backend reset server on port $RESET_PORT (logs: $RESET_SERVER_LOG)..."
POOL_URLS=$(python3 -c 'import sys; print(",".join(f"http://10.0.2.2:{8100 + i}" for i in range(int(sys.argv[1]))))' "$POOL_SIZE")
RESET_PORT="$RESET_PORT" POOL_SIZE="$POOL_SIZE" POOL_URLS="$POOL_URLS" POOL_LOG_DIR=/tmp WORK_DIR="$PWD" \
    python3 scripts/backend-reset-server.py > "$RESET_SERVER_LOG" 2>&1 &
RESET_SERVER_PID=$!
deadline=$(( SECONDS + 300 ))
until grep -q "pool ready" "$RESET_SERVER_LOG"; do
    if ! kill -0 "$RESET_SERVER_PID" 2>/dev/null || (( SECONDS >= deadline )); then
        echo "ERROR: backend pool did not become ready:"
        tail -n 50 "$RESET_SERVER_LOG"
        exit 1
    fi
    sleep 1
done

cleanup() {
    echo "Cleaning up test environment..."
    # SIGTERM makes the reset server remove its backend containers.
    kill "$RESET_SERVER_PID" 2>/dev/null || true
    wait "$RESET_SERVER_PID" 2>/dev/null || true
}
trap cleanup EXIT

echo "Building the app and running tests..."
flutter build apk --config-only
patrol test \
    --hide-test-steps \
    --dart-define=USERNAME="$BOB" \
    --dart-define=PASSWORD="$BOB" \
    --dart-define=ADDITIONAL_MAIL_RECIPIENT="$ALICE@$DOMAIN" \
    --dart-define=BASIC_AUTH_EMAIL="$BOB@$DOMAIN" \
    --dart-define=BASIC_AUTH_URL="$BASIC_AUTH_URL" \
    --dart-define=RESET_SERVER_URL="http://10.0.2.2:$RESET_PORT"