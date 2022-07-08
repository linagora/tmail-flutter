
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

class LanguageCacheManager {
  static const keyLanguageCode = 'LANGUAGE_CODE';
  static const keyCountryCode = 'COUNTRY_CODE';

  final SharedPreferences _sharedPreferences;

  LanguageCacheManager(this._sharedPreferences);

  Future<void> persistLanguage(Locale localeCurrent) async {
    await Future.wait([
      _sharedPreferences.setString(keyLanguageCode, localeCurrent.languageCode),
      _sharedPreferences.setString(keyCountryCode, localeCurrent.countryCode ?? '')
    ]);
  }
}