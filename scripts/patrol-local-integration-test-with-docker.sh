#!/bin/bash
set -euo pipefail

## Pre-requisites
#   - patrol_cli installed: dart pub global activate patrol_cli 4.3.1
#   - ADB installed (Android SDK platform-tools)
#   - A local Android emulator running (e.g. via Android Studio AVD)
#
# Usage:
#   ./scripts/patrol-local-integration-test-with-docker.sh

# Stop previous backend environment if any
cd backend-docker || exit 1
docker compose down || true
cd ..

cd backend-docker || exit 1

# Generate JWT keys if not already present
if [[ ! -f jwt_privatekey ]]; then
    echo "Generating keys for tmail-backend..."
    openssl genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:4096 -out jwt_privatekey
    openssl rsa -in jwt_privatekey -pubout -out jwt_publickey
fi

# 10.0.2.2 is the QEMU alias for the host machine — the Android emulator uses this
# to reach tmail-backend which is bound to host port 80.
# Edit the sed commands if not using MacOS
sed -i '' "s|url.prefix=.*|url.prefix=http://10.0.2.2|" jmap.properties
sed -i '' "s|websocket.url.prefix=.*|websocket.url.prefix=ws://10.0.2.2|" jmap.properties

echo "Starting tmail-backend via Docker..."
docker compose up -d tmail-backend

# Wait for tmail-backend
until (docker compose logs tmail-backend | grep -i "JAMES server started"); do
    echo "Waiting for tmail-backend to start..."
    sleep 2
done
export BOB="bob"
export ALICE="alice"
export DOMAIN="example.com"

docker exec tmail-backend /root/conf/integration_test/provisioning.sh >/dev/null 2>&1

cd ..

# 10.0.2.2 is QEMU's hardcoded alias for the host — reaches tmail-backend on port 80
export BASIC_AUTH_URL="http://10.0.2.2"
export RESET_PORT=9999

RESET_SERVER_LOG="/tmp/backend-reset-server.log"
echo "Starting backend reset server on port $RESET_PORT (logs: $RESET_SERVER_LOG)..."
WORK_DIR="$(pwd)" RESET_PORT="$RESET_PORT" python3 scripts/backend-reset-server.py > "$RESET_SERVER_LOG" 2>&1 &
RESET_SERVER_PID=$!

cleanup() {
    echo "Cleaning up test environment..."
    kill "$RESET_SERVER_PID" 2>/dev/null || true
    cd backend-docker || exit 0
    docker compose down
    cd ..
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