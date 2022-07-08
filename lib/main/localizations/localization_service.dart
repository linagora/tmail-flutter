
import 'dart:ui';

import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';

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