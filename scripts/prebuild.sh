#!/usr/bin/env bash
# fail if any commands fails
set -e
echo "Prebuild started..."

# Add additional modules to the end of this, seperated by space
modules=("core" "model" "contact" "forward" "rule_filter" "fcm" "email_recovery" "server_settings" "scribe" "labels")

for mod in "${modules[@]}"; do
    (
        cd "$mod"
        flutter pub get > /dev/null 2>&1
        dart run build_runner build --delete-conflicting-outputs > /dev/null 2>&1
        echo "[$mod] Done."
    )
done

# For Cozy
cd cozy
flutter pub get
cd ../
echo "[cozy] Done."

# For the parent module
flutter pub get > /dev/null 2>&1
dart run build_runner build --delete-conflicting-outputs > /dev/null 2>&1 &&
    dart run intl_generator:extract_to_arb --output-dir=./lib/l10n lib/main/localizations/app_localizations.dart > /dev/null 2>&1 &&
    dart run intl_generator:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/main/localizations/app_localizations.dart lib/l10n/intl*.arb > /dev/null 2>&1
echo "[root] Done."

# For scribe module localizations
echo "[scribe/l10n] Starting..."
(
   cd scribe
   dart run intl_generator:extract_to_arb --output-dir=./lib/scribe/ai/l10n lib/scribe/ai/localizations/scribe_localizations.dart > /dev/null 2>&1 &&
      dart run intl_generator:generate_from_arb --output-dir=lib/scribe/ai/l10n --no-use-deferred-loading lib/scribe/ai/localizations/scribe_localizations.dart lib/scribe/ai/l10n/intl*.arb > /dev/null 2>&1
)
echo "[scribe/l10n] Done."

echo "Prebuild finished."
