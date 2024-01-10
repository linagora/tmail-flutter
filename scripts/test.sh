#!/usr/bin/env bash

set -eux

if [[ "$MODULES" == "default" ]]; then
    flutter test -r json > test-report-"$MODULES".json
else
    flutter test -r json "$MODULES" > test-report-"$MODULES".json
fi
