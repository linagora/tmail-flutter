import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/server_settings/domain/state/get_server_setting_state.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

extension InitializeAppLanguage on MailboxDashBoardController {
  void initializeAppLanguage(GetServerSettingSuccess success) {
    final serverLanguage = success.settingOption.language;

    const supportedLocales = LocalizationService.supportedLocales;
    final currentLocale = Get.locale;
    final serverLocale = supportedLocales
      .firstWhereOrNull((locale) => locale.languageCode == serverLanguage);
    final cachedLocale = LocalizationService.getCachedLocale();
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    
    // From server
    if (serverLocale != null && supportedLocales.contains(serverLocale)) {
      LocalizationService.changeLocale(serverLocale.languageCode);
      if (saveLanguageInteractor != null) {
        consumeState(saveLanguageInteractor!.execute(serverLocale));
      }
      return;
    }
    
    // From cache
    if (cachedLocale != null && supportedLocales.contains(cachedLocale)) {
      LocalizationService.changeLocale(cachedLocale.languageCode);
      return;
    } 
    
    // From device
    if (supportedLocales.contains(deviceLocale)) {
      LocalizationService.changeLocale(deviceLocale.languageCode);
      return;
    } 
    
    // Default
    if (currentLocale == null || !supportedLocales.contains(currentLocale)) {
      LocalizationService.changeLocale(
        LocalizationService.defaultLocale.languageCode,
      );
      return;
    }
  }
}