#!/usr/bin/env bash
# fail if any commands fails
set -e
# debug log
set -x

# Add additional modules to the end of this, seperated by space
modules=("core" "model" "contact" "forward" "rule_filter" "fcm" "email_recovery" "server_settings")

for mod in "${modules[@]}"; do
    (
        cd "$mod"
        flutter pub get
        dart run build_runner build --delete-conflicting-outputs
    )
done

# For the parent module
flutter pub get
dart run build_runner build --delete-conflicting-outputs &&
    dart run intl_generator:extract_to_arb --output-dir=./lib/l10n lib/main/localizations/app_localizations.dart &&
    dart run intl_generator:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/main/localizations/app_localizations.dart lib/l10n/intl*.arb
