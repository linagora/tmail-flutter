
import 'dart:ui';

import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/main/localizations/language_code_constants.dart';

class LocalizationService extends Translations {

  static const defaultLocale = Locale(LanguageCodeConstants.english, 'US');
  static const fallbackLocale = Locale(LanguageCodeConstants.english, 'US');

  static final supportedLanguageCodes = [
    LanguageCodeConstants.french,
    LanguageCodeConstants.english,
    LanguageCodeConstants.vietnamese,
    LanguageCodeConstants.russian,
    LanguageCodeConstants.arabic,
    LanguageCodeConstants.italian
  ];

  static const List<Locale> supportedLocales = [
    Locale(LanguageCodeConstants.french, 'FR'),
    Locale(LanguageCodeConstants.english, 'US'),
    Locale(LanguageCodeConstants.vietnamese, 'VN'),
    Locale(LanguageCodeConstants.russian, 'RU'),
    Locale(LanguageCodeConstants.arabic, 'TN'),
    Locale(LanguageCodeConstants.italian, 'IT')
  ];

  static final locale = _getLocaleFromLanguage();

  static void changeLocale(String langCode) {
    log('LocalizationService::changeLocale(): langCode: $langCode');
    final locale = _getLocaleFromLanguage(langCode: langCode);
    Get.updateLocale(locale);
  }

  static Locale _getLocaleFromLanguage({String? langCode}) {
    final languageCacheManager = Get.find<LanguageCacheManager>();
    final localeStored = languageCacheManager.getStoredLanguage();

    log('LocalizationService::_getLocaleFromLanguage(): localeStored: ${localeStored.toString()}');

    if (localeStored != null) {
      return localeStored;
    } else {
      final languageCodeCurrent = langCode ?? Get.deviceLocale?.languageCode;
      final localeSelected = supportedLocales
          .firstWhereOrNull((locale) => locale.languageCode == languageCodeCurrent);
      return localeSelected ?? Get.locale ?? defaultLocale;
    }
  }

  @override
  Map<String, Map<String, String>> get keys => {};
}