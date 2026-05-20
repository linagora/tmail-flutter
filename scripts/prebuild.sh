#!/usr/bin/env bash
# fail if any commands fails
set -e
echo "Prebuild started..."

# Single pub get resolves the entire workspace (Dart pub workspaces)
flutter pub get > /dev/null 2>&1
echo "[workspace] pub get done."

# Run build_runner across all workspace members in a single invocation
dart run build_runner build --workspace --delete-conflicting-outputs > /dev/null 2>&1
echo "[workspace] build_runner done."

# Root module: intl localization generation
dart run intl_generator:extract_to_arb --output-dir=./lib/l10n lib/main/localizations/app_localizations.dart > /dev/null 2>&1 &&
    dart run intl_generator:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/main/localizations/app_localizations.dart lib/l10n/intl*.arb > /dev/null 2>&1
echo "[root] Done."

# Scribe module: intl localization generation
echo "[scribe/l10n] Starting..."
(
   cd scribe
   dart run intl_generator:extract_to_arb --output-dir=./lib/scribe/ai/l10n lib/scribe/ai/localizations/scribe_localizations.dart > /dev/null 2>&1 &&
      dart run intl_generator:generate_from_arb --output-dir=lib/scribe/ai/l10n --no-use-deferred-loading lib/scribe/ai/localizations/scribe_localizations.dart lib/scribe/ai/l10n/intl*.arb > /dev/null 2>&1
)
echo "[scribe/l10n] Done."

echo "Prebuild finished."
