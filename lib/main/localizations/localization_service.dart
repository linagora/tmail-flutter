
import 'dart:ui';

import 'package:get/get.dart';

class LocalizationService extends Translations {

  static const defaultLocale = Locale('en', 'US');
  static const fallbackLocale = Locale('en', 'US');

  static final supportedLanguageCodes = [
    'fr',
    'en',
    'vi',
    'ru'
  ];

  static const List<Locale> supportedLocales = [
    Locale('fr', 'FR'),
    Locale('en', 'US'),
    Locale('vi', 'VN'),
    Locale('ru', 'RU')
  ];

  static final locale = _getLocaleFromLanguage();

  static void changeLocale(String langCode) {
    final locale = _getLocaleFromLanguage(langCode: langCode);
    Get.updateLocale(locale);
  }

  static Locale _getLocaleFromLanguage({String? langCode}) {
    final lang = langCode ?? Get.deviceLocale?.languageCode;

    final localeSelected = supportedLocales
        .firstWhereOrNull((locale) => locale.languageCode == lang);

    return localeSelected ?? Get.locale ?? defaultLocale;
  }

  @override
  Map<String, Map<String, String>> get keys => {};
}