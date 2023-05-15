#!/usr/bin/env bash
# fail if any commands fails
set -e
# debug log
set -x

cd core
flutter pub get

## Install necessary pods
# cd ../ios
# flutter pub get && pod install

cd ../model
flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs

cd ../contact
flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs

cd ../forward
flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs

cd ../rule_filter
flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs

cd ../fcm
flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs

cd ..
flutter pub get \
    && flutter pub run build_runner build --delete-conflicting-outputs \
    && flutter pub run intl_generator:extract_to_arb --output-dir=./lib/l10n lib/main/localizations/app_localizations.dart \
    && flutter pub run intl_generator:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/main/localizations/app_localizations.dart lib/l10n/intl*.arb
