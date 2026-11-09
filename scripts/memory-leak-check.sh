#!/bin/bash
# Usage: memory-leak-check.sh <web|android>
# Runs the memory-tagged Patrol tests in profile mode, one leased backend slot per test,
# collects samples through ci-memory-sidecar.js and applies the leak rules.
# Android expects a booted emulator (emulator-5554).
set -uo pipefail

PLATFORM="${1:?usage: memory-leak-check.sh <web|android>}"
if [ "$PLATFORM" = android ] && [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    echo "Android needs Bash 4+: Bash 3.2 (macOS /bin/bash) reports a read timeout as EOF, so the hang watchdog never fires." >&2
    exit 2
fi
ROOT_DIR="$PWD"
CI_LOGS="${CI_LOGS:-$ROOT_DIR/ci-logs}"
MEMORY_DIR="$CI_LOGS/memory"
mkdir -p "$MEMORY_DIR"
rm -f "$MEMORY_DIR"/*

case "$PLATFORM" in
    web) HOST=localhost ;;
    android) HOST=10.0.2.2 ;; # the emulator's alias for the host
    *) echo "unknown platform: $PLATFORM"; exit 2 ;;
esac
RESET_PORT=9999
SIDECAR_PORT=9998
export BASIC_AUTH_URL="http://$HOST:8100"
export MEMORY_OUT_DIR="$MEMORY_DIR"
export MEMORY_SIDECAR_PORT="$SIDECAR_PORT"

RESET_SERVER_PID=""
SIDECAR_PID=""

cleanup() {
    echo "Cleaning up memory check..."
    cd "$ROOT_DIR" || return 0
    [ -n "$SIDECAR_PID" ] && kill "$SIDECAR_PID" 2>/dev/null
    [ -n "$RESET_SERVER_PID" ] && kill "$RESET_SERVER_PID" 2>/dev/null
    wait "$SIDECAR_PID" "$RESET_SERVER_PID" 2>/dev/null
    bash "$ROOT_DIR/scripts/ci-backend-teardown.sh" "$CI_LOGS/backend.log"
    rm -f backend-docker/jwt_privatekey backend-docker/jwt_publickey
    [ -f "$CI_LOGS/env.file.backup" ] && mv "$CI_LOGS/env.file.backup" env.file
    return 0
}
if [ -f "$CI_LOGS/env.file.backup" ]; then
    echo "Leftover of an interrupted run ($CI_LOGS/env.file.backup): restore it first."
    exit 2
fi
[ -f env.file ] && cp env.file "$CI_LOGS/env.file.backup"
trap cleanup EXIT

export PATH="$PATH:$HOME/.pub-cache/bin"
dart pub global activate patrol_cli 4.3.1 || exit 1

cd backend-docker || exit 1
openssl genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:4096 -out jwt_privatekey || exit 1
openssl rsa -in jwt_privatekey -pubout -out jwt_publickey || exit 1
cd "$ROOT_DIR" || exit 1

# Every test leases a fresh slot; the second slot boots while a test runs.
POOL_SIZE=2
POOL_URLS=$(python3 -c 'import sys; print(",".join(f"http://{sys.argv[1]}:{8100 + i}" for i in range(int(sys.argv[2]))))' "$HOST" "$POOL_SIZE") || exit 1
# Four heavy sends (about 14 MB each) stay in bob's Sent folder; the default quota is 50 MB.
RESET_PORT="$RESET_PORT" POOL_SIZE="$POOL_SIZE" POOL_URLS="$POOL_URLS" POOL_LOG_DIR="$CI_LOGS" WORK_DIR="$ROOT_DIR" \
    POOL_BOB_QUOTA_BYTES=200000000 \
    python3 scripts/backend-reset-server.py > "$CI_LOGS/backend-reset-server.log" 2>&1 &
RESET_SERVER_PID=$!
node --experimental-websocket scripts/ci-memory-sidecar.js > "$CI_LOGS/memory-sidecar.log" 2>&1 &
SIDECAR_PID=$!

DART_DEFINES=(
    --dart-define=USERNAME=bob
    --dart-define=PASSWORD=bob
    --dart-define=ADDITIONAL_MAIL_RECIPIENT=alice@example.com
    --dart-define=BASIC_AUTH_EMAIL=bob@example.com
    --dart-define=BASIC_AUTH_URL="$BASIC_AUTH_URL"
    --dart-define=RESET_SERVER_URL="http://$HOST:$RESET_PORT"
    --dart-define=MEMORY_SIDECAR_URL="http://$HOST:$SIDECAR_PORT"
)

# Web only, local debugging, e.g. MEMORY_PATROL_ARGS="--target integration_test/tests/memory/<test>.dart"
read -r -a EXTRA_PATROL_ARGS <<< "${MEMORY_PATROL_ARGS:-}"

source "$ROOT_DIR/scripts/memory-leak-android-run.sh"

if [ "$PLATFORM" = web ]; then
    cp integration_test/integration_test_env.file env.file
    # Fixed debug port: the sidecar finds the app tab over CDP.
    WEB_BROWSER_ARGS='["--disable-web-security","--disable-dev-shm-usage","--disable-gpu","--lang=en-US","--accept-lang=en-US,en","--remote-debugging-port=9333"]'
    # Timeouts nest: Dart test 12 min < Playwright 15 min.
    # Same flutter wrapper as the other web suites: CanvasKit is served locally, and the app logs reach $CI_LOGS.
    patrol test -v --profile --tags=memory --device=chrome --web-port=3000 \
        --web-headless=true --web-server-timeout=300 --web-timeout=900000 \
        --web-global-timeout=3300000 --web-browser-args="$WEB_BROWSER_ARGS" \
        --show-flutter-logs --flutter-command="bash scripts/ci-flutter-verbose-run.sh" \
        ${EXTRA_PATROL_ARGS[@]+"${EXTRA_PATROL_ARGS[@]}"} "${DART_DEFINES[@]}" 2>&1 \
        | tee "$CI_LOGS/patrol-web.log"
    PATROL_EXIT=${PIPESTATUS[0]}
else
    run_android_tests
fi

if [ "$PLATFORM" = android ] && [ "$PATROL_EXIT" -ne 0 ]; then
    adb -s emulator-5554 logcat -d -t 20000 > "$CI_LOGS/logcat.txt" 2>&1 || true
fi

python3 -I scripts/memory-leak-report.py "$MEMORY_DIR" integration_test/memory/memory_rules.json
REPORT_EXIT=$?

[ "$PATROL_EXIT" -ne 0 ] && exit "$PATROL_EXIT"
exit "$REPORT_EXIT"
