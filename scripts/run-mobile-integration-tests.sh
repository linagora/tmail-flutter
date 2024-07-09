#!/usr/bin/env sh

# This is to generate gradlew
flutter build apk --config-only

# Run prebuild.sh
./scripts/prebuild.sh

# This builds and uploads APK to browserstack
export BS_PROJECT=tmail-flutter
# List of supported devices: https://www.browserstack.com/list-of-browsers-and-platforms/app_automate
export BS_ANDROID_DEVICES='["Samsung Galaxy S24-14.0", "Google Pixel 8-14.0"]'
bs_android --verbose
