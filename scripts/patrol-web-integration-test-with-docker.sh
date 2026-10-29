#!/bin/bash

ROOT_DIR="$PWD"
CI_LOGS="$ROOT_DIR/ci-logs"
RESET_SERVER_LOG="$CI_LOGS/backend-reset-server.log"
PATROL_LOG="$CI_LOGS/patrol-console.log"
BACKEND_READY_FIFO=
mkdir -p "$CI_LOGS"

timing() {
    echo "[timing $(date -u +%FT%TZ)] +${SECONDS}s $*"
}

timing "agent backend wait started"
bash "$ROOT_DIR/scripts/ci-wait-agent-backend-free.sh" || exit 1
timing "agent backend available"

{
    echo "=== agent ==="; uname -a; nproc; free -h; lscpu | head -20
    docker info --format 'docker: {{.NCPU}} CPU, {{.MemTotal}} B'
    google-chrome --version || chromium --version
} 2>&1 | tee "$CI_LOGS/agent.txt"
vmstat -t 5 > "$CI_LOGS/vmstat.log" 2>&1 &
VMSTAT_PID=$!

cleanup() {
    echo "Cleaning up test environment..."
    kill "${BACKEND_SETUP_PID:-}" 2>/dev/null || true
    wait "${BACKEND_SETUP_PID:-}" 2>/dev/null || true
    kill "$VMSTAT_PID" 2>/dev/null || true
    kill "${RESET_SERVER_PID:-}" 2>/dev/null || true
    kill "${WATCHDOG_PID:-}" 2>/dev/null || true
    kill "${KEEPER_PID:-}" 2>/dev/null || true
    kill "${BOOT_PROBE_PID:-}" 2>/dev/null || true
    # Reap them so their ports are free before the agent lock is released.
    wait "$VMSTAT_PID" "${RESET_SERVER_PID:-}" "${WATCHDOG_PID:-}" "${KEEPER_PID:-}" "${BOOT_PROBE_PID:-}" 2>/dev/null || true
    rm -f "$BACKEND_READY_FIFO"
    [ -z "${BACKEND_READY_DIR:-}" ] || rmdir "$BACKEND_READY_DIR"
    bash "$ROOT_DIR/scripts/ci-backend-teardown.sh" "$CI_LOGS/backend.log"
    gzip -f "$PATROL_LOG" 2>/dev/null || true
}
trap cleanup EXIT
trap 'exit 143' TERM
trap 'exit 130' INT

# Forward traffic to tmail-backend
export BASIC_AUTH_URL="http://localhost"
export WEBSOCKET_URL="ws://localhost"
export BOB="bob"
export ALICE="alice"
export DOMAIN="example.com"
export RESET_PORT=9999

start_backend() {
    # Finish the active command before teardown can remove its containers.
    trap 'exit 1' TERM INT
    timing "backend setup started"
    cd "$ROOT_DIR/backend-docker" || return 1
    docker compose down || true

    echo "Generating keys for tmail-backend..."
    openssl genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:4096 -out jwt_privatekey || return 1
    openssl rsa -in jwt_privatekey -pubout -out jwt_publickey || return 1

    # James must report URLs reachable by the browser.
    sed -i.bak "s|url.prefix=.*|url.prefix=$BASIC_AUTH_URL|" jmap.properties || return 1
    sed -i.bak "s|websocket.url.prefix=.*|websocket.url.prefix=$WEBSOCKET_URL|" jmap.properties || return 1

    echo "Starting services and adding users..."
    docker compose up -d || return 1
    until (docker compose logs tmail-backend | grep -i "JAMES server started"); do
        echo "Waiting for tmail-backend to start..."
        sleep 2
    done
    docker exec tmail-backend ./root/conf/integration_test/provisioning.sh || return 1
    printf 'ready\n' > "$BACKEND_READY_FIFO" || return 1
    timing "backend provisioned"
}

BACKEND_READY_DIR=$(mktemp -d) || exit 1
BACKEND_READY_FIFO="$BACKEND_READY_DIR/ready"
mkfifo "$BACKEND_READY_FIFO" || exit 1
start_backend &
BACKEND_SETUP_PID=$!

# A sibling process keeps the reset server directly owned and reaped by this shell.
(
    IFS= read -r ready < "$BACKEND_READY_FIFO" || exit 1
    [ "$ready" = ready ] || exit 1
    exec python3 scripts/backend-reset-server.py
) > "$RESET_SERVER_LOG" 2>&1 &
RESET_SERVER_PID=$!

timing "patrol CLI install started"
echo "Installing patrol CLI..."
dart pub global activate patrol_cli 4.3.1 || exit 1
timing "patrol CLI installed"

echo "Copying integration_test/integration_test_env.file to env.file..."
cp integration_test/integration_test_env.file env.file || exit 1

echo "Building the app and running tests..."
# Keeper must hold a page before Patrol's setup page leaves; Patrol installs these only after the dev server is up
WEB_RUNNER_DIR=$(node scripts/ci-web-dev-server-keeper.js --web-runner-dir "$ROOT_DIR") || { echo "web_runner lookup failed"; exit 1; }
[ -d "$WEB_RUNNER_DIR" ] || { echo "web_runner dir missing: '$WEB_RUNNER_DIR'"; exit 1; }
echo "Pre-installing Patrol web_runner deps in $WEB_RUNNER_DIR..."
timing "web_runner dependencies install started"
# Same commands as patrol_cli 4.3.1 _ensureNodeDependencies, so its own run is a no-op
(cd "$WEB_RUNNER_DIR" && npm install && npx playwright install) || { echo "web_runner deps install failed"; exit 1; }
timing "web_runner dependencies installed"

BACKEND_STATUS=0
wait "$BACKEND_SETUP_PID" || BACKEND_STATUS=$?
BACKEND_SETUP_PID=
[ "$BACKEND_STATUS" -eq 0 ] || exit "$BACKEND_STATUS"
while ! grep -q "Listening on port $RESET_PORT" "$RESET_SERVER_LOG"; do
    kill -0 "$RESET_SERVER_PID" 2>/dev/null || { echo "backend reset server failed to start"; exit 1; }
    sleep 1
done
timing "backend reset server ready"

: > "$PATROL_LOG"
bash scripts/ci-web-stall-watchdog.sh "$PATROL_LOG" "$CI_LOGS/stall-dump.log" "$$" "$RESET_SERVER_LOG" &
WATCHDOG_PID=$!
bash scripts/ci-web-boot-stall-probe.sh "$PATROL_LOG" "$CI_LOGS/boot-stall-dump.log" "http://localhost:3000" &
BOOT_PROBE_PID=$!

WEB_BROWSER_ARGS='["--disable-web-security","--disable-dev-shm-usage","--disable-gpu","--lang=en-US","--accept-lang=en-US,en"]'
node scripts/ci-web-dev-server-keeper.js "http://localhost:3000" "$ROOT_DIR" "$WEB_BROWSER_ARGS" "$PATROL_LOG" > "$CI_LOGS/dev-server-keeper.log" 2>&1 &
KEEPER_PID=$!

# Full output goes to $PATROL_LOG (archived as patrol-console.log.gz); the console drops per-page dwds metadata and cumulative teardown lines.
timing "patrol tests started"
# Allow page setup time so the Dart timeout can report first.
patrol test -v \
    --web-timeout=300000 \
    --tags=web \
    --device=chrome \
    --web-port=3000 \
    --web-headless=true \
    --web-server-timeout=300 \
    --web-global-timeout=4500000 \
    --web-workers="${WEB_WORKERS:-3}" \
    --show-flutter-logs \
    --flutter-command="bash scripts/ci-flutter-verbose-run.sh" \
    --web-video="${WEB_VIDEO:-off}" \
    --web-results-dir="$CI_LOGS/web-results" \
    --web-report-dir="$CI_LOGS/playwright-report" \
    --web-browser-args="$WEB_BROWSER_ARGS" \
    --dart-define=USERNAME="$BOB" \
    --dart-define=PASSWORD="$BOB" \
    --dart-define=ADDITIONAL_MAIL_RECIPIENT="$ALICE@$DOMAIN" \
    --dart-define=BASIC_AUTH_EMAIL="$BOB@$DOMAIN" \
    --dart-define=BASIC_AUTH_URL="$BASIC_AUTH_URL" \
    --dart-define=RESET_SERVER_URL="http://localhost:$RESET_PORT" 2>&1 | tee >(perl -MPOSIX -pe 'BEGIN { $| = 1 } $_ = strftime("%T ", localtime) . $_' > "$PATROL_LOG") | grep --line-buffered -v -E 'Loaded debug metadata|PatrolBinding: tearDown\(\): count'
TEST_EXIT_CODE=${PIPESTATUS[0]}
timing "patrol tests finished (exit $TEST_EXIT_CODE)"

exit $TEST_EXIT_CODE
