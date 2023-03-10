
import 'dart:ui';

import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/save_language_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/save_language_interactor.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

class LanguageAndRegionController extends BaseController {

  final SaveLanguageInteractor _saveLanguageInteractor;

  final listSupportedLanguages = <Locale>[].obs;
  final languageSelected = LocalizationService.defaultLocale.obs;
  final isLanguageMenuOverlayOpen = RxBool(false);

  LanguageAndRegionController(this._saveLanguageInteractor);

  @override
  void onReady() {
    _setUpSupportedLanguages();
    super.onReady();
  }

  @override
  void onDone() {
    viewState.value.fold(
        (failure) => null,
        (success) {
            if (success is SaveLanguageSuccess) {
              LocalizationService.changeLocale(success.localeStored.languageCode);
            }
        });
  }

  void _setUpSupportedLanguages() {
    listSupportedLanguages.value = LocalizationService.supportedLocales;

    final currentLocale = Get.locale;
    log('LanguageAndRegionController::_setUpSupportedLanguages():currentLocale: $currentLocale');
    if (currentLocale != null) {
      languageSelected.value = currentLocale;
    } else {
      languageSelected.value = LocalizationService.defaultLocale;
    }
  }

  void selectLanguage(Locale? selectedLocale) {
    isLanguageMenuOverlayOpen.value = false;
    languageSelected.value = selectedLocale ?? LocalizationService.defaultLocale;
    _saveLanguage(languageSelected.value);
  }

  void _saveLanguage(Locale localeCurrent) {
    consumeState(_saveLanguageInteractor.execute(localeCurrent));
  }

  void toggleLanguageMenuOverlay() {
    isLanguageMenuOverlayOpen.toggle();
  }
}