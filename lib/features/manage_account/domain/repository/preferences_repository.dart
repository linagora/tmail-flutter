import 'dart:ui';

abstract class PreferencesRepository {
  Future<void> persistLanguage(Locale localeCurrent);
}