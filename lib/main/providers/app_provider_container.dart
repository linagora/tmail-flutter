import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/main/providers/shared_preferences_provider.dart';

/// Singleton [ProviderContainer] shared between the [ProviderScope] and
/// non-widget code (e.g. GetX controllers / services).
///
/// Must be initialized via [initAppProviderContainer] before any access.
/// The app entry point (main_entry.dart) guarantees this before any widget renders.
ProviderContainer? _appProviderContainer;

ProviderContainer get appProviderContainer {
  assert(
    _appProviderContainer != null,
    'appProviderContainer accessed before initAppProviderContainer()',
  );
  return _appProviderContainer!;
}

void initAppProviderContainer(SharedPreferences prefs) {
  _appProviderContainer = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );
}
