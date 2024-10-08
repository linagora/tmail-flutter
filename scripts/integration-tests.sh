#!/usr/bin/env bash

echo "$TEST_CREDENTIALS" >tests.env
set -o allexport && source tests.env && set +o allexport
dart pub global activate patrol_cli
flutter build apk --config-only
patrol build android -v \
    --dart-define=USERNAME="$USERNAME" \
    --dart-define=PASSWORD="$PASSWORD" \
    --dart-define=HOST_URL="$HOST_URL" \
    --dart-define=ADDITIONAL_MAIL_RECIPIENT="$ADDITIONAL_MAIL_RECIPIENT" \
    --dart-define=BASIC_AUTH_EMAIL="$BASIC_AUTH_EMAIL" \
    --dart-define=BASIC_AUTH_URL="$BASIC_AUTH_URL"
gcloud firebase test android run \
    --type instrumentation \
    --app build/app/outputs/apk/debug/app-debug.apk \
    --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
    --device 'model=oriole,version=33,locale=en,orientation=portrait' \
    --timeout 10m \
    --use-orchestrator \
    --environment-variables clearPackageData=true
