#!/bin/bash

PORT=3000

echo pwd
cd core
flutter pub get

cd ../model
flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs

cd ..
flutter pub get && flutter pub run intl_generator:extract_to_arb --output-dir=./lib/l10n lib/main/localizations/app_localizations.dart

flutter pub get && flutter pub run intl_generator:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/main/localizations/app_localizations.dart lib/l10n/intl*.arb

flutter build web --dart-define=SERVER_URL='https://dev.open-paas.org'

echo 'preparing port' $PORT '...'
fuser -k 3000/tcp

cd build/web/

# Start the server
echo 'Server starting on port' $PORT '...'
python3 -m http.server $PORT