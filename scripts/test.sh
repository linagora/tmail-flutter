#!/usr/bin/env bash

set -eux

# Write the machine-readable report straight to a file instead of redirecting
# stdout: `flutter test` always runs an implicit `pub get` first, and that output
# would otherwise be captured into the report and invalidate the JSON. Keeping
# stdout free also leaves failure details visible in the CI log.
REPORT="test-report-$MODULES.json"

if [[ "$MODULES" == "default" ]]; then
    flutter test --file-reporter="json:$REPORT"
else
    flutter test --file-reporter="json:$REPORT" "$MODULES"
fi
