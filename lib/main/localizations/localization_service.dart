
import 'dart:ui';

import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/main/localizations/language_code_constants.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class LocalizationService extends Translations {

  static const defaultLocale = Locale(LanguageCodeConstants.english, 'US');
  static const fallbackLocale = Locale(LanguageCodeConstants.english, 'US');

  static final supportedLanguageCodes = [
    LanguageCodeConstants.french,
    LanguageCodeConstants.english,
    LanguageCodeConstants.vietnamese,
    LanguageCodeConstants.russian,
    LanguageCodeConstants.arabic,
    LanguageCodeConstants.italian,
    LanguageCodeConstants.german
  ];

  static const List<Locale> supportedLocales = [
    Locale(LanguageCodeConstants.french, 'FR'),
    Locale(LanguageCodeConstants.english, 'US'),
    Locale(LanguageCodeConstants.vietnamese, 'VN'),
    Locale(LanguageCodeConstants.russian, 'RU'),
    Locale(LanguageCodeConstants.arabic, 'TN'),
    Locale(LanguageCodeConstants.italian, 'IT'),
    Locale(LanguageCodeConstants.german, 'DE')
  ];

  static void changeLocale(String langCode) {
    log('LocalizationService::changeLocale():langCode: $langCode');
    final newLocale = getLocaleFromLanguage(langCode: langCode);
    log('LocalizationService::changeLocale():newLocale: $newLocale');
    Get.updateLocale(newLocale);
  }

  static Locale getLocaleFromLanguage({String? langCode}) {
    try {
      final languageCacheManager = getBinding<LanguageCacheManager>();
      log('LocalizationService::_getLocaleFromLanguage:languageCacheManager: $languageCacheManager');
      final localeStored = languageCacheManager?.getStoredLanguage();
      log('LocalizationService::_getLocaleFromLanguage():localeStored: $localeStored');
      if (localeStored != null) {
        return localeStored;
      } else {
        final languageCodeCurrent = langCode ?? Get.deviceLocale?.languageCode;
        log('LocalizationService::_getLocaleFromLanguage():languageCodeCurrent: $languageCodeCurrent');
        final localeSelected = supportedLocales.firstWhereOrNull((locale) => locale.languageCode == languageCodeCurrent);
        return localeSelected ?? Get.deviceLocale ?? defaultLocale;
      }
    } catch (e) {
      logError('LocalizationService::getLocaleFromLanguage: Exception: $e');
      return Get.deviceLocale ?? defaultLocale;
    }
  }

  static String supportedLocalesToLanguageTags() {
    final listLanguageTags = supportedLocales.map((locale) => locale.toLanguageTag()).join(', ');
    log('LocalizationService::supportedLocalesToLanguageTags:listLanguageTags: $listLanguageTags');
    return listLanguageTags;
  }

  @override
  Map<String, Map<String, String>> get keys => {};
}
