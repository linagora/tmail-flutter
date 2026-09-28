#!/usr/bin/env bash

set -euo pipefail

: "${MODULES:?MODULES must be set to default or a package path}"

has_default_tests=$(python3 scripts/test-platforms.py has-default-tests "$MODULES")
if [[ "$has_default_tests" != "true" && "$has_default_tests" != "false" ]]; then
    printf 'ERROR: Unexpected test discovery result for %s: %s\n' \
        "$MODULES" "$has_default_tests" >&2
    exit 1
fi

# Write the machine-readable report straight to a file instead of redirecting
# stdout: `flutter test` always runs an implicit `pub get` first, and that output
# would otherwise be captured into the report and invalidate the JSON. Keeping
# stdout free also leaves failure details visible in the CI log.
REPORT="test-report-${MODULES//\//-}.json"

vm_status=0
if [[ "$has_default_tests" == "true" ]]; then
    args=(test --no-fail-fast "--file-reporter=json:$REPORT")
    if [[ "$MODULES" == "default" ]]; then
        printf 'Running Flutter tests for root package\n'
    else
        args+=("$MODULES")
        printf 'Running Flutter tests for package %s\n' "$MODULES"
    fi

    if flutter "${args[@]}"; then
        printf 'Flutter VM tests passed for %s\n' "$MODULES"
    else
        vm_status=$?
        printf 'ERROR: Flutter VM tests failed for %s (exit code %d)\n' \
            "$MODULES" "$vm_status" >&2
    fi
else
    printf 'No VM tests for %s\n' "$MODULES"
fi

annotated_status=0
if python3 scripts/test-platforms.py run-annotated "$MODULES"; then
    printf 'Annotated platform tests passed for %s\n' "$MODULES"
else
    annotated_status=$?
    printf 'ERROR: Annotated platform tests failed for %s (exit code %d)\n' \
        "$MODULES" "$annotated_status" >&2
fi

if (( vm_status != 0 || annotated_status != 0 )); then
    printf 'ERROR: Test run failed for %s (VM exit: %d; annotated exit: %d)\n' \
        "$MODULES" "$vm_status" "$annotated_status" >&2
    exit 1
fi
