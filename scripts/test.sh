#!/usr/bin/env bash

set -eux

# MODULES=default runs the root suite; any other value targets that package path.
if [[ "$MODULES" == "default" ]]; then
    flutter test -r json > test-report-"$MODULES".json
else
    flutter test -r json "$MODULES" > test-report-"$MODULES".json
fi
