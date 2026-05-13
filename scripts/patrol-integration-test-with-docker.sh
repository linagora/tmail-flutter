#!/bin/bash
# CI integration test script.
# The Android emulator is managed by reactivecircus/android-emulator-runner
# and is already running when this script executes.
#
# Usage:
#   ./scripts/patrol-integration-test-with-docker.sh
set -e

echo "Installing patrol CLI..."
dart pub global activate patrol_cli 4.3.1

cd backend-docker

openssl genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:4096 -out jwt_privatekey 2>/dev/null
openssl rsa -in jwt_privatekey -pubout -out jwt_publickey 2>/dev/null

# 10.0.2.2 is the QEMU alias for the host machine inside the Android emulator.
sed -i.bak "s|url.prefix=.*|url.prefix=http://10.0.2.2|" jmap.properties
sed -i.bak "s|websocket.url.prefix=.*|websocket.url.prefix=ws://10.0.2.2|" jmap.properties

echo "Starting tmail-backend..."
docker compose up -d tmail-backend --quiet-pull
# Cap the wait so a stuck backend fails fast instead of consuming the runner timeout.
deadline=$(( SECONDS + 180 ))
until docker compose logs tmail-backend 2>/dev/null | grep -qi "JAMES server started"; do
    if (( SECONDS >= deadline )); then
        echo "tmail-backend did not start within 180s; recent logs:"
        docker compose logs --tail=200 tmail-backend
        exit 1
    fi
    echo "Waiting for tmail-backend..."
    sleep 2
done

export BOB="bob"
export ALICE="alice"
export DOMAIN="example.com"

docker exec tmail-backend /root/conf/integration_test/provisioning.sh >/dev/null 2>&1

cd ..

export BASIC_AUTH_URL="http://10.0.2.2"
export RESET_PORT=9999

RESET_SERVER_LOG="/tmp/backend-reset-server.log"
echo "Starting backend reset server on port $RESET_PORT (logs: $RESET_SERVER_LOG)..."
RESET_PORT="$RESET_PORT" python3 scripts/backend-reset-server.py > "$RESET_SERVER_LOG" 2>&1 &
RESET_SERVER_PID=$!

cleanup() {
    echo "Cleaning up..."
    kill "$ADB_WATCHDOG_PID" 2>/dev/null || true
    kill "$RESET_SERVER_PID" 2>/dev/null || true
    cd backend-docker
    docker compose down --remove-orphans 2>/dev/null
    cd ..
    # Stop the emulator before it can respawn crashpad_handler during its own
    # graceful-shutdown sequence — that respawn is the root cause of the hang.
    adb emu kill 2>/dev/null || true
    sleep 2
    # crashpad_handler ignores SIGTERM; use SIGKILL directly. Retry a few
    # times to catch any instance that was mid-spawn when the emulator died.
    for _i in 1 2 3; do
        pkill -SIGKILL crashpad_handler 2>/dev/null || break
        sleep 1
    done
}
trap cleanup EXIT

adb_watchdog() {
    local fail_count=0
    while sleep 5; do
        if ! adb -s emulator-5554 shell echo ok >/dev/null 2>&1; then
            (( fail_count++ )) || true
            # Require 2 consecutive failures (~10s) before acting to avoid
            # killing on a transient ADB blip during heavy test execution.
            if (( fail_count >= 2 )); then
                echo "ADB watchdog: emulator-5554 gone for $((fail_count * 5))s."
                echo "ADB watchdog: killing Gradle JVM to unblock patrol teardown..."
                # "adb uninstall" runs inside the Gradle JVM via DDMLIB (not a
                # separate adb process), so we must kill Gradle directly.
                pkill -SIGKILL -f "GradleMain" 2>/dev/null || true
                pkill -SIGKILL -f "GradleDaemon" 2>/dev/null || true
                # One-shot: break so the watchdog doesn't keep firing after acting.
                break
            fi
        else
            fail_count=0
        fi
    done
}
adb_watchdog &
ADB_WATCHDOG_PID=$!

echo "Running Patrol tests..."
flutter build apk --config-only --quiet
patrol test \
    --exclude-tags=web \
    --dart-define=USERNAME="$BOB" \
    --dart-define=PASSWORD="$BOB" \
    --dart-define=ADDITIONAL_MAIL_RECIPIENT="$ALICE@$DOMAIN" \
    --dart-define=BASIC_AUTH_EMAIL="$BOB@$DOMAIN" \
    --dart-define=BASIC_AUTH_URL="$BASIC_AUTH_URL" \
    --dart-define=RESET_SERVER_URL="http://10.0.2.2:$RESET_PORT"
