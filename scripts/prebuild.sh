#!/usr/bin/env bash
# fail if any commands fails
set -e
echo "Prebuild started..."
prebuild_started=$SECONDS

# Single pub get resolves the entire workspace (Dart pub workspaces)
step_started=$SECONDS
flutter pub get > /dev/null
echo "[workspace] pub get done in $(( SECONDS - step_started ))s."

# Pinned browser libs for web/index.html (web/js/vendor, gitignored)
if [ "${PREBUILD_SKIP_WEB:-0}" = 1 ]; then
   echo "[web/vendor] skipped for mobile."
else
   step_started=$SECONDS
   sh "$(dirname "$0")/fetch-web-vendor.sh"
   echo "[web/vendor] done in $(( SECONDS - step_started ))s."
fi

# Run build_runner across all workspace members in a single invocation
step_started=$SECONDS
dart run build_runner build --workspace > /dev/null
echo "[workspace] build_runner done in $(( SECONDS - step_started ))s."

# Root module: intl localization generation
root_l10n() {
   local step_started=$SECONDS
   dart run intl_generator:extract_to_arb --output-dir=./lib/l10n lib/main/localizations/app_localizations.dart
   echo "[root/l10n] extract done in $(( SECONDS - step_started ))s."
   step_started=$SECONDS
   dart run intl_generator:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/main/localizations/app_localizations.dart lib/l10n/intl*.arb
   echo "[root/l10n] generate done in $(( SECONDS - step_started ))s."
}

# Scribe module: intl localization generation
scribe_l10n() (
   echo "[scribe/l10n] Starting..."
   cd scribe
   step_started=$SECONDS
   dart run intl_generator:extract_to_arb --output-dir=./lib/scribe/ai/l10n lib/scribe/ai/localizations/scribe_localizations.dart
   echo "[scribe/l10n] extract done in $(( SECONDS - step_started ))s."
   step_started=$SECONDS
   dart run intl_generator:generate_from_arb --output-dir=lib/scribe/ai/l10n --no-use-deferred-loading lib/scribe/ai/localizations/scribe_localizations.dart lib/scribe/ai/l10n/intl*.arb
   echo "[scribe/l10n] generate done in $(( SECONDS - step_started ))s."
)

root_l10n
scribe_l10n

echo "Prebuild finished in $(( SECONDS - prebuild_started ))s."
