#!/bin/bash
# Usage: memory-leak-check.sh <web|android>
# Runs the memory-tagged Patrol tests in profile mode against one local backend,
# collects samples through ci-memory-sidecar.js and applies the leak rules.
# Android expects a booted emulator (emulator-5554).
set -uo pipefail

PLATFORM="${1:?usage: memory-leak-check.sh <web|android>}"
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
WEBSOCKET_URL="ws://$HOST"
export BASIC_AUTH_URL="http://$HOST"
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
    [ -f backend-docker/jmap.properties.bak ] && mv backend-docker/jmap.properties.bak backend-docker/jmap.properties
    rm -f backend-docker/jwt_privatekey backend-docker/jwt_publickey
    [ -f "$CI_LOGS/env.file.backup" ] && mv "$CI_LOGS/env.file.backup" env.file
    return 0
}
if [ -f backend-docker/jmap.properties.bak ] || [ -f "$CI_LOGS/env.file.backup" ]; then
    echo "Leftovers of an interrupted run (backend-docker/jmap.properties.bak or env.file.backup): restore them first."
    exit 2
fi
[ -f env.file ] && cp env.file "$CI_LOGS/env.file.backup"
trap cleanup EXIT

export PATH="$PATH:$HOME/.pub-cache/bin"
dart pub global activate patrol_cli 4.3.1 || exit 1

cd backend-docker || exit 1
docker compose down || true
openssl genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:4096 -out jwt_privatekey || exit 1
openssl rsa -in jwt_privatekey -pubout -out jwt_publickey || exit 1
# James reports this prefix in its JMAP session, and the app follows it.
sed -i.bak "s|url.prefix=.*|url.prefix=$BASIC_AUTH_URL|" jmap.properties
sed -i.bak2 "s|websocket.url.prefix=.*|websocket.url.prefix=$WEBSOCKET_URL|" jmap.properties
rm -f jmap.properties.bak2
docker compose up -d || exit 1
for attempt in $(seq 1 150); do
    docker compose logs tmail-backend | grep -qi "JAMES server started" && break
    if [ "$attempt" -eq 150 ]; then
        echo "tmail-backend did not start in 5 minutes"
        docker compose logs --tail 50 tmail-backend
        exit 1
    fi
    echo "Waiting for tmail-backend to start..."
    sleep 2
done
docker exec tmail-backend ./root/conf/integration_test/provisioning.sh > /dev/null 2>&1 || exit 1
cd "$ROOT_DIR" || exit 1

RESET_PORT="$RESET_PORT" python3 scripts/backend-reset-server.py > "$CI_LOGS/backend-reset-server.log" 2>&1 &
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

# Local debugging only, e.g. MEMORY_PATROL_ARGS="--show-flutter-logs --target integration_test/tests/memory/<test>.dart"
read -r -a EXTRA_PATROL_ARGS <<< "${MEMORY_PATROL_ARGS:-}"

# A hung instrumentation prints nothing, so kill patrol on silence, not on a fixed budget.
# The Gradle build is silent for up to ~6 min; test steps print every few seconds.
BUILD_IDLE_LIMIT=600
TEST_IDLE_LIMIT=240
run_android_test() {
    local target="$1"
    local pid_file="$CI_LOGS/patrol.pid"
    : > "$CI_LOGS/patrol-android.log"
    bash -c 'echo $$ > "$1"; shift; exec "$@"' _ "$pid_file" \
        patrol test -v --profile --show-flutter-logs --target "$target" --device=emulator-5554 \
        ${EXTRA_PATROL_ARGS[@]+"${EXTRA_PATROL_ARGS[@]}"} "${DART_DEFINES[@]}" 2>&1 |
    {
        local limit=$BUILD_IDLE_LIMIT line patrol_pid
        while true; do
            if IFS= read -r -t "$limit" line; then
                printf '%s\n' "$line" | tee -a "$CI_LOGS/patrol-android.log"
                case "$line" in *"Starting "*" tests on"*) limit=$TEST_IDLE_LIMIT ;; esac
            elif [ $? -gt 128 ]; then
                echo "No patrol output for ${limit}s: killing the hung run" | tee -a "$CI_LOGS/patrol-android.log"
                patrol_pid=$(cat "$pid_file" 2>/dev/null)
                if [ -n "$patrol_pid" ]; then
                    pkill -TERM -P "$patrol_pid" 2>/dev/null
                    kill -TERM "$patrol_pid" 2>/dev/null
                fi
                return 124
            else
                break
            fi
        done
    }
}

if [ "$PLATFORM" = web ]; then
    cp integration_test/integration_test_env.file env.file
    # Fixed debug port: the sidecar finds the app tab over CDP.
    WEB_BROWSER_ARGS='["--disable-web-security","--disable-dev-shm-usage","--disable-gpu","--lang=en-US","--accept-lang=en-US,en","--remote-debugging-port=9333"]'
    # Timeouts nest: Dart test 12 min < Playwright 15 min.
    patrol test -v --profile --tags=memory --device=chrome --web-port=3000 \
        --web-headless=true --web-server-timeout=300 --web-timeout=900000 \
        --web-global-timeout=3300000 --web-browser-args="$WEB_BROWSER_ARGS" \
        ${EXTRA_PATROL_ARGS[@]+"${EXTRA_PATROL_ARGS[@]}"} "${DART_DEFINES[@]}"
    PATROL_EXIT=$?
else
    export ANDROID_TEST_BUILD_TYPE=profile
    PATROL_EXIT=0
    # One patrol run per test: the Android orchestrator sometimes kills the next test's
    # process while it removes the previous task, which hangs or crashes the whole run.
    for target in integration_test/tests/memory/*_test.dart; do
        for attempt in 1 2; do
            run_android_test "$target"
            exit_code=$?
            [ "$exit_code" -eq 0 ] && break
            # Retry only when the instrumentation died; a failed test keeps its failure.
            grep -q -E "Test instrumentation process crashed|Test run failed to complete|killing the hung run" \
                "$CI_LOGS/patrol-android.log" || break
            echo "Instrumentation died during $target (attempt $attempt)"
        done
        [ "$exit_code" -ne 0 ] && PATROL_EXIT=$exit_code
    done
fi

if [ "$PLATFORM" = android ] && [ "$PATROL_EXIT" -ne 0 ]; then
    adb -s emulator-5554 logcat -d -t 20000 > "$CI_LOGS/logcat.txt" 2>&1 || true
fi

python3 -I scripts/memory-leak-report.py "$MEMORY_DIR" integration_test/memory/memory_rules.json
REPORT_EXIT=$?

[ "$PATROL_EXIT" -ne 0 ] && exit "$PATROL_EXIT"
exit "$REPORT_EXIT"
