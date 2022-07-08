
import 'dart:ui';

import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

class LanguageAndRegionController extends BaseController {

  final listSupportedLanguages = <Locale>[].obs;
  final languageSelected = LocalizationService.defaultLocale.obs;

  @override
  void onReady() {
    _setUpSupportedLanguages();
    super.onReady();
  }

  @override
  void onDone() {}

  @override
  void onError(error) {}

  void _setUpSupportedLanguages() {
    listSupportedLanguages.value = LocalizationService.supportedLocales;

    final currentLocale = Get.locale;
    if (currentLocale != null) {
      languageSelected.value = currentLocale;
    } else {
      languageSelected.value = LocalizationService.defaultLocale;
    }
  }

  void selectLanguage(Locale? selectedLocale) {
    languageSelected.value = selectedLocale ?? LocalizationService.defaultLocale;
    LocalizationService.changeLocale(languageSelected.value.languageCode);
  }
}