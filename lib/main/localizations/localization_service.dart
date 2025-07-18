import 'package:core/utils/app_logger.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/main/localizations/language_code_constants.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef OnServerLanguageApplied = Function(Locale locale);

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

  static void changeLocale(Locale newLocale) {
    log('LocalizationService::changeLocale(): New locale is $newLocale');
    Get.updateLocale(newLocale);
  }

  static Locale getInitialLocale() {
    try {
      final cachedLocale = _getCachedLocale();
      if (cachedLocale != null) return cachedLocale;

      final deviceLocale = _getDeviceLocale();
      if (_isSupportedLocale(deviceLocale)) return deviceLocale;

      return defaultLocale;
    } catch (e) {
      logError('LocalizationService::getInitialLocale:Exception is $e');
      return defaultLocale;
    }
  }

  static Locale? _getCachedLocale() {
    try {
      final languageCacheManager = getBinding<LanguageCacheManager>();
      return languageCacheManager?.getStoredLanguage();
    } catch (e) {
      logError('LocalizationService::getCachedLocale: Exception: $e');
      return null;
    }
  }

  static Locale _getDeviceLocale() =>
      WidgetsBinding.instance.platformDispatcher.locale;

  static String supportedLocalesToLanguageTags() {
    final listLanguageTags = supportedLocales.map((locale) => locale.toLanguageTag()).join(', ');
    log('LocalizationService::supportedLocalesToLanguageTags:listLanguageTags: $listLanguageTags');
    return listLanguageTags;
  }

  static void initializeAppLanguage({
    String? serverLanguage,
    OnServerLanguageApplied? onServerLanguageApplied,
  }) {
    log('LocalizationService::initializeAppLanguage:Server language: $serverLanguage');
    try {
      // From server
      if (serverLanguage != null &&
          _useServerLocale(
            languageCode: serverLanguage,
            onServerLanguageApplied: onServerLanguageApplied,
          )) {
        return;
      }

      if (_useCachedLocale()) return;

      if (_useDeviceLocale()) return;

      _useDefaultLocale();
    } catch (e) {
      logError('LocalizationService::initializeAppLanguage: Exception: $e');
      _useDefaultLocale();
    }
  }

  static void _useDefaultLocale() {
    final currentLocale = Get.locale;
    if (currentLocale == null || !_isSupportedLocale(currentLocale)) {
      changeLocale(defaultLocale);
    }
  }

  static bool _useDeviceLocale() {
    final deviceLocale = _getDeviceLocale();
    log('LocalizationService::_useDeviceLocale: Device locale is $deviceLocale');
    if (_isSupportedLocale(deviceLocale)) {
      changeLocale(deviceLocale);
      return true;
    }
    return false;
  }

  static bool _useCachedLocale() {
    final cachedLocale = _getCachedLocale();
    log('LocalizationService::_useCachedLocale: Cached locale is $cachedLocale');
    if (cachedLocale != null && _isSupportedLocale(cachedLocale)) {
      changeLocale(cachedLocale);
      return true;
    }
    return false;
  }

  static bool _useServerLocale({
    required String languageCode,
    required OnServerLanguageApplied? onServerLanguageApplied,
  }) {
    final serverLocale = _findSupportedLocale(languageCode);
    log('LocalizationService::_useServerLocale: Server locale is $serverLocale');
    if (serverLocale != null && _isSupportedLocale(serverLocale)) {
      changeLocale(serverLocale);
      onServerLanguageApplied?.call(serverLocale);
      return true;
    }
    return false;
  }

  static bool _isSupportedLocale(Locale locale) {
    return supportedLocales
        .any((supported) => supported.languageCode == locale.languageCode);
  }

  static Locale? _findSupportedLocale(String languageCode) {
    return supportedLocales.firstWhereOrNull(
        (supported) => supported.languageCode == languageCode);
  }

  @override
  Map<String, Map<String, String>> get keys => {};
}
