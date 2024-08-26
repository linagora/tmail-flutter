#!/usr/bin/env bash
# fail if any commands fails
set -e
# debug log
set -x

cd core
fvm flutter pub get

## Install necessary pods
# cd ../ios
# fvm flutter pub get && pod install

cd ../model
fvm flutter pub get && fvm dart run build_runner build --delete-conflicting-outputs

cd ../contact
fvm flutter pub get && fvm dart run build_runner build --delete-conflicting-outputs

cd ../forward
fvm flutter pub get && fvm dart run build_runner build --delete-conflicting-outputs

cd ../rule_filter
fvm flutter pub get && fvm dart run build_runner build --delete-conflicting-outputs

cd ../fcm
fvm flutter pub get && fvm dart run build_runner build --delete-conflicting-outputs

cd ../email_recovery
fvm flutter pub get && fvm dart run build_runner build --delete-conflicting-outputs

cd ../server_settings
fvm flutter pub get && fvm dart run build_runner build --delete-conflicting-outputs

cd ..
fvm flutter pub get \
    && fvm dart run build_runner build --delete-conflicting-outputs \
    && fvm dart run intl_generator:extract_to_arb --output-dir=./lib/l10n lib/main/localizations/app_localizations.dart \
    && fvm dart run intl_generator:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/main/localizations/app_localizations.dart lib/l10n/intl*.arb
