#!/usr/bin/env bash
# Runs every test of one package: the VM tests, then the @TestOn('chrome') suites on Chrome.
# MODULES is "default" for the root package, otherwise the package folder.
#
# CI supports exactly two platform declarations, each alone on its line: @TestOn('vm') and
# @TestOn('chrome'). Any other platform metadata (another selector, @OnPlatform, a per-test
# testOn/onPlatform, an import prefix) fails the run, so a test is never skipped in silence.
# Every phase runs even if an earlier one failed; the script fails at the end.

set -euo pipefail

: "${MODULES:?MODULES must be set to default or a package folder}"

# Whole names only, so an identifier such as forPreviewEmailOnPlatform is not metadata.
PLATFORM_METADATA='(^|[^[:alnum:]_])(TestOn|testOn|OnPlatform|onPlatform)([^[:alnum:]_]|$)'
SUPPORTED_TEST_ON="@TestOn\(['\"](vm|chrome)['\"]\)$"
CHROME_TEST_ON="^@TestOn\(['\"]chrome['\"]\)$"

package_dir=$([[ "$MODULES" == "default" ]] && echo . || echo "$MODULES")
# Write the machine-readable reports straight to files instead of redirecting stdout:
# `flutter test` runs an implicit `pub get` first, and that output would otherwise be
# captured into the report and invalidate the JSON. Keeping stdout free also leaves failure
# details visible in the CI log.
REPORT="$PWD/test-report-$MODULES.json"
CHROME_REPORT="$PWD/test-report-$MODULES-chrome.json"

guard_status=0
unsupported=$(cd "$package_dir" && grep -rnE "$PLATFORM_METADATA" --include='*_test.dart' test \
    | grep -vE "^[^:]+:[0-9]+:$SUPPORTED_TEST_ON" || true)
if [[ -n "$unsupported" ]]; then
    guard_status=1
    printf "ERROR: unsupported platform metadata in %s. CI runs only a line that is exactly @TestOn('vm') or @TestOn('chrome'):\n%s\n" \
        "$MODULES" "$unsupported" >&2
fi

# The root package also owns the dev-only MCP host tests, kept next to their code.
vm_targets=()
if [[ "$MODULES" == "default" && -d tmail-mcp/test ]]; then
    vm_targets=(test tmail-mcp/test)
fi

vm_status=0
printf 'Running VM tests for %s\n' "$MODULES"
(cd "$package_dir" && flutter test "--file-reporter=json:$REPORT" ${vm_targets[@]+"${vm_targets[@]}"}) \
    || vm_status=$?

chrome_tests=()
while IFS= read -r test_file; do
    chrome_tests+=("$test_file")
done < <(cd "$package_dir" && grep -rlE "$CHROME_TEST_ON" --include='*_test.dart' test | sort)

chrome_status=0
if (( ${#chrome_tests[@]} > 0 )); then
    printf 'Running %d Chrome test file(s) for %s\n' "${#chrome_tests[@]}" "$MODULES"
    (cd "$package_dir" && flutter test --platform chrome "--file-reporter=json:$CHROME_REPORT" "${chrome_tests[@]}") \
        || chrome_status=$?
fi

if (( guard_status != 0 || vm_status != 0 || chrome_status != 0 )); then
    printf 'ERROR: tests failed for %s (platform metadata: %d, VM exit: %d, Chrome exit: %d)\n' \
        "$MODULES" "$guard_status" "$vm_status" "$chrome_status" >&2
    exit 1
fi
printf 'All tests passed for %s\n' "$MODULES"
