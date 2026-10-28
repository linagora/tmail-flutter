#!/bin/bash

ROOT_DIR="$PWD"
CI_LOGS="$ROOT_DIR/ci-logs"
RESET_SERVER_LOG="$CI_LOGS/backend-reset-server.log"
PATROL_LOG="$CI_LOGS/patrol-console.log"
mkdir -p "$CI_LOGS"

bash "$ROOT_DIR/scripts/ci-wait-agent-backend-free.sh" || exit 1

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
    kill "${WATCHDOG_PID:-}" 2>/dev/null || true
    kill "${KEEPER_PID:-}" 2>/dev/null || true
    # Reap them so their ports are free before the agent lock is released.
    wait "$VMSTAT_PID" "$RESET_SERVER_PID" "${WATCHDOG_PID:-}" "${KEEPER_PID:-}" 2>/dev/null || true
    bash "$ROOT_DIR/scripts/ci-backend-teardown.sh" "$CI_LOGS/backend.log"
    gzip -f "$PATROL_LOG" 2>/dev/null || true
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
# Keeper must hold a page before Patrol's setup page leaves; Patrol installs these only after the dev server is up
WEB_RUNNER_DIR=$(node scripts/ci-web-dev-server-keeper.js --web-runner-dir "$ROOT_DIR") || { echo "web_runner lookup failed"; exit 1; }
[ -d "$WEB_RUNNER_DIR" ] || { echo "web_runner dir missing: '$WEB_RUNNER_DIR'"; exit 1; }
echo "Pre-installing Patrol web_runner deps in $WEB_RUNNER_DIR..."
# Same commands as patrol_cli 4.3.1 _ensureNodeDependencies, so its own run is a no-op
(cd "$WEB_RUNNER_DIR" && npm install && npx playwright install) || { echo "web_runner deps install failed"; exit 1; }
: > "$PATROL_LOG"
bash scripts/ci-web-stall-watchdog.sh "$PATROL_LOG" "$CI_LOGS/stall-dump.log" "$$" &
WATCHDOG_PID=$!

WEB_BROWSER_ARGS='["--disable-web-security","--disable-dev-shm-usage","--disable-gpu","--lang=en-US","--accept-lang=en-US,en"]'
node scripts/ci-web-dev-server-keeper.js "http://localhost:3000" "$ROOT_DIR" "$WEB_BROWSER_ARGS" "$PATROL_LOG" > "$CI_LOGS/dev-server-keeper.log" 2>&1 &
KEEPER_PID=$!

# Full output goes to $PATROL_LOG (archived as patrol-console.log.gz); the console drops per-page dwds metadata and cumulative teardown lines.
patrol test -v \
    --tags=web \
    --device=chrome \
    --web-port=3000 \
    --web-headless=true \
    --web-server-timeout=300 \
    --web-global-timeout=4500000 \
    --show-flutter-logs \
    --flutter-command="bash scripts/ci-flutter-verbose-run.sh" \
    --web-video=retain-on-failure \
    --web-results-dir="$CI_LOGS/web-results" \
    --web-report-dir="$CI_LOGS/playwright-report" \
    --web-browser-args="$WEB_BROWSER_ARGS" \
    --dart-define=USERNAME="$BOB" \
    --dart-define=PASSWORD="$BOB" \
    --dart-define=ADDITIONAL_MAIL_RECIPIENT="$ALICE@$DOMAIN" \
    --dart-define=BASIC_AUTH_EMAIL="$BOB@$DOMAIN" \
    --dart-define=BASIC_AUTH_URL="$BASIC_AUTH_URL" \
    --dart-define=RESET_SERVER_URL="http://localhost:$RESET_PORT" 2>&1 | tee "$PATROL_LOG" | grep --line-buffered -v -E 'Loaded debug metadata|PatrolBinding: tearDown\(\): count'
TEST_EXIT_CODE=${PIPESTATUS[0]}

exit $TEST_EXIT_CODE