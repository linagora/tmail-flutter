#!/bin/bash
# Sourced by memory-leak-check.sh. Expects CI_LOGS and DART_DEFINES; sets PATROL_EXIT.
# Builds the memory tests once, then runs each test with `am instrument` on the same APKs.
# Without the Android Test Orchestrator there is no task removal racing the next test.

ANDROID_SERIAL=emulator-5554
ANDROID_PACKAGE=com.linagora.android.teammail
APP_APK=build/app/outputs/apk/profile/app-profile.apk
TEST_APK=build/app/outputs/apk/androidTest/profile/app-profile-androidTest.apk
# The instrumentation prints nothing when hung; the app's flutter logs show test progress.
TEST_IDLE_LIMIT=240
# Cap for an app that keeps logging while wedged; above the 12 min Dart test timeout.
TEST_MAX_SECONDS=780

build_and_install_android_tests() {
    export ANDROID_TEST_BUILD_TYPE=profile
    patrol build android -v --profile --target integration_test/tests/memory --tags=memory \
        "${DART_DEFINES[@]}" || return 1
    adb -s "$ANDROID_SERIAL" install -r -t "$APP_APK" || return 1
    adb -s "$ANDROID_SERIAL" install -r -t "$TEST_APK" || return 1
}

# Reads instrumentation + flutter logs; kills the app on silence so the run ends.
watch_android_test() {
    local line start=$SECONDS
    while true; do
        if IFS= read -r -t "$TEST_IDLE_LIMIT" line; then
            printf '%s\n' "$line" | tee -a "$CI_LOGS/patrol-android.log"
            [ $((SECONDS - start)) -gt "$TEST_MAX_SECONDS" ] || continue
            echo "Test ran over ${TEST_MAX_SECONDS}s: killing the hung run" | tee -a "$CI_LOGS/patrol-android.log"
        elif [ $? -gt 128 ]; then
            echo "No test output for ${TEST_IDLE_LIMIT}s: killing the hung run" | tee -a "$CI_LOGS/patrol-android.log"
        else
            # A last line without a newline is still data (e.g. the OK line).
            [ -n "$line" ] && printf '%s\n' "$line" | tee -a "$CI_LOGS/patrol-android.log"
            return 0
        fi
        adb -s "$ANDROID_SERIAL" shell am force-stop "$ANDROID_PACKAGE" < /dev/null
        pkill -f "adb -s $ANDROID_SERIAL shell am instrument" 2>/dev/null
        return 124
    done
}

# Returns 0 only when exactly one test ran and passed.
run_android_test() {
    local name
    name=$(basename "$1" .dart)
    : > "$CI_LOGS/patrol-android.log"
    # `pm clear` resets runtime permissions; granting contacts keeps the composer free of the dialog.
    adb -s "$ANDROID_SERIAL" shell pm clear "$ANDROID_PACKAGE" || return 1
    adb -s "$ANDROID_SERIAL" shell pm grant "$ANDROID_PACKAGE" android.permission.READ_CONTACTS || return 1
    adb -s "$ANDROID_SERIAL" logcat -c
    {
        adb -s "$ANDROID_SERIAL" logcat -v time flutter:I '*:S' &
        local logcat_pid=$!
        adb -s "$ANDROID_SERIAL" shell am instrument -w -e tests_regex "$name" \
            "$ANDROID_PACKAGE.test/pl.leancode.patrol.PatrolJUnitRunner" < /dev/null
        kill "$logcat_pid" 2>/dev/null
    } 2>&1 | watch_android_test
    grep -q "^OK (1 test)" "$CI_LOGS/patrol-android.log"
}

run_android_tests() {
    PATROL_EXIT=0
    if ! build_and_install_android_tests; then
        echo "Building or installing the Android memory tests failed"
        PATROL_EXIT=1
        return
    fi
    local target attempt exit_code
    for target in integration_test/tests/memory/*_test.dart; do
        for attempt in 1 2; do
            run_android_test "$target"
            exit_code=$?
            [ "$exit_code" -eq 0 ] && break
            # Retry only when the instrumentation died; a failed test keeps its failure.
            grep -q -E "Process crashed|INSTRUMENTATION_FAILED|killing the hung run" \
                "$CI_LOGS/patrol-android.log" || break
            [ "$attempt" -eq 1 ] && echo "Instrumentation died during $target: retrying once"
        done
        [ "$exit_code" -ne 0 ] && PATROL_EXIT=$exit_code
    done
    return 0
}
