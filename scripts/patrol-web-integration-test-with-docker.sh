#!/bin/bash

ROOT_DIR="$PWD"
CI_LOGS="$ROOT_DIR/ci-logs"
RESET_SERVER_LOG="/tmp/backend-reset-server.log"
mkdir -p "$CI_LOGS"

{
    echo "=== agent ==="; uname -a; nproc; free -h; lscpu | head -20
    docker info --format 'docker: {{.NCPU}} CPU, {{.MemTotal}} B'
    google-chrome --version || chromium --version
} 2>&1 | tee "$CI_LOGS/agent.txt"
vmstat -t 5 > "$CI_LOGS/vmstat.log" 2>&1 &
VMSTAT_PID=$!

cleanup() {
    echo "Cleaning up test environment..."
    kill "$VMSTAT_PID" 2>/dev/null || true
    kill "$RESET_SERVER_PID" 2>/dev/null || true
    # Reap them so their ports are free before the agent lock is released.
    wait "$VMSTAT_PID" "$RESET_SERVER_PID" 2>/dev/null || true
    cd "$ROOT_DIR/backend-docker" || return 0
    docker compose logs --no-color --timestamps > "$CI_LOGS/backend.log" 2>&1 || true
    cp "$RESET_SERVER_LOG" "$CI_LOGS/" 2>/dev/null || true
    docker compose down
    cd "$ROOT_DIR"
}
trap cleanup EXIT

## Pre-requisites
# Install patrol CLI
echo "Installing patrol CLI..."
dart pub global activate patrol_cli 4.3.1

# Stop previous environment if any
cd backend-docker
docker compose down || true

# Forward traffic to tmail-backend
export BASIC_AUTH_URL="http://localhost"
export WEBSOCKET_URL="ws://localhost"

# Generate keys for tmail backend
echo "Generating keys for tmail-backend..."
openssl genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:4096 -out jwt_privatekey
openssl rsa -in jwt_privatekey -pubout -out jwt_publickey

# Replace jmap.properties URLs so James reports the correct public base URL
# in its JMAP session responses (the app uses these URLs for subsequent requests).
sed -i.bak "s|url.prefix=.*|url.prefix=$BASIC_AUTH_URL|" jmap.properties
sed -i.bak "s|websocket.url.prefix=.*|websocket.url.prefix=$WEBSOCKET_URL|" jmap.properties

echo "Starting services and adding users..."
docker compose up -d
# Wait till the service is started to add users
until (docker compose logs tmail-backend | grep -i "JAMES server started"); do
    echo "Waiting for tmail-backend to start..."
    sleep 2
done
export BOB="bob"
export ALICE="alice"
export DOMAIN="example.com"

docker exec tmail-backend ./root/conf/integration_test/provisioning.sh

cd ..

export RESET_PORT=9999

echo "Starting backend reset server on port $RESET_PORT (logs: $RESET_SERVER_LOG)..."
RESET_PORT="$RESET_PORT" python3 scripts/backend-reset-server.py > "$RESET_SERVER_LOG" 2>&1 &
RESET_SERVER_PID=$!

echo "Copying integration_test/integration_test_env.file to env.file..."
cp integration_test/integration_test_env.file env.file

echo "Building the app and running tests..."
patrol test -v \
    --tags=web \
    --device=chrome \
    --web-port=3000 \
    --web-headless=true \
    --web-server-timeout=300 \
    --show-flutter-logs \
    --web-video=retain-on-failure \
    --web-results-dir="$CI_LOGS/web-results" \
    --web-report-dir="$CI_LOGS/playwright-report" \
    --web-browser-args='["--disable-web-security","--disable-dev-shm-usage","--disable-gpu","--lang=en-US","--accept-lang=en-US,en"]' \
    --dart-define=USERNAME="$BOB" \
    --dart-define=PASSWORD="$BOB" \
    --dart-define=ADDITIONAL_MAIL_RECIPIENT="$ALICE@$DOMAIN" \
    --dart-define=BASIC_AUTH_EMAIL="$BOB@$DOMAIN" \
    --dart-define=BASIC_AUTH_URL="$BASIC_AUTH_URL" \
    --dart-define=RESET_SERVER_URL="http://localhost:$RESET_PORT"
TEST_EXIT_CODE=$?

exit $TEST_EXIT_CODE