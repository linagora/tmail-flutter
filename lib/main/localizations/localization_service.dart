
import 'dart:ui';

import 'package:core/utils/app_logger.dart';
import 'package:flutter/widgets.dart';
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
      final localeStored = languageCacheManager?.getStoredLanguage();
      log('LocalizationService::_getLocaleFromLanguage():localeStored: $localeStored');
      final localeSelected = supportedLocales.firstWhereOrNull(
        (locale) => locale.languageCode == langCode,
      );
      return localeSelected ?? localeStored ?? Get.deviceLocale ?? defaultLocale;
    } catch (e) {
      logError('LocalizationService::getLocaleFromLanguage: Exception: $e');
      return Get.deviceLocale ?? defaultLocale;
    }
  }

  static Locale? getCachedLocale() {
    try {
      final languageCacheManager = getBinding<LanguageCacheManager>();
      return languageCacheManager?.getStoredLanguage();
    } catch (e) {
      logError('LocalizationService::getCachedLocale: Exception: $e');
      return null;
    }
  }

  static String supportedLocalesToLanguageTags() {
    final listLanguageTags = supportedLocales.map((locale) => locale.toLanguageTag()).join(', ');
    log('LocalizationService::supportedLocalesToLanguageTags:listLanguageTags: $listLanguageTags');
    return listLanguageTags;
  }

  static void initializeAppLanguage({
    String? serverLanguage,
    void Function(Locale locale)? onServerLanguageApplied,
  }) {
    final currentLocale = Get.locale;
    try {
      final serverLocale = supportedLocales
        .firstWhereOrNull((locale) => locale.languageCode == serverLanguage);
      final cachedLocale = getCachedLocale();
      
      // From server
      if (serverLocale != null && supportedLocales.contains(serverLocale)) {
        changeLocale(serverLocale.languageCode);
        onServerLanguageApplied?.call(serverLocale);
        return;
      }
      
      // From cache
      if (cachedLocale != null && supportedLocales.contains(cachedLocale)) {
        changeLocale(cachedLocale.languageCode);
        return;
      } 
      
      // From device
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      if (supportedLocales.contains(deviceLocale)) {
        changeLocale(deviceLocale.languageCode);
        return;
      } 
      
      // Default
      if (currentLocale == null || !supportedLocales.contains(currentLocale)) {
        changeLocale(defaultLocale.languageCode);
        return;
      }
    } catch (e) {
      logError('LocalizationService::initializeAppLanguage: Exception: $e');
      // Default
      if (currentLocale == null || !supportedLocales.contains(currentLocale)) {
        changeLocale(defaultLocale.languageCode);
        return;
      }
    }
  }

  @override
  Map<String, Map<String, String>> get keys => {};
}
