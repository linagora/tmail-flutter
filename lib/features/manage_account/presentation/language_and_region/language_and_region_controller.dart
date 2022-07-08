
import 'dart:ui';

import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/save_language_app_interactor.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

class LanguageAndRegionController extends BaseController {

  final SaveLanguageAppInteractor _saveLanguageAppInteractor;

  final listSupportedLanguages = <Locale>[].obs;
  final languageSelected = LocalizationService.defaultLocale.obs;

  LanguageAndRegionController(this._saveLanguageAppInteractor);

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

    _saveLanguage(languageSelected.value);
  }

  void _saveLanguage(Locale localeCurrent) {
    consumeState(_saveLanguageAppInteractor.execute(localeCurrent));
  }
}