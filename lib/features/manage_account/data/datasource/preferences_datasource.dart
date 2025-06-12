import 'dart:ui';

abstract class PreferencesDataSource {
  Future<void> persistLanguage(Locale localeCurrent);
}