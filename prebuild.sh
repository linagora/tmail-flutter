#!/bin/bash
echo Pre-build ...

cd core
flutter pub get

# Install necessary pods
cd ../ios
flutter pub get && pod install

cd ../model
flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs

cd ../contact
flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs

cd ..
flutter pub get && flutter pub run intl_generator:extract_to_arb --output-dir=./lib/l10n lib/main/localizations/app_localizations.dart

flutter pub get && flutter pub run intl_generator:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/main/localizations/app_localizations.dart lib/l10n/intl*.arb

echo \[Completed\] pre-build!!!
