
import 'dart:ui';

import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/save_language_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/save_language_interactor.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

class LanguageAndRegionController extends BaseController {

  final SaveLanguageInteractor _saveLanguageInteractor;

  final listSupportedLanguages = <Locale>[].obs;
  final languageSelected = LocalizationService.defaultLocale.obs;

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
    _saveLanguage(languageSelected.value);
  }

  void _saveLanguage(Locale localeCurrent) {
    consumeState(_saveLanguageInteractor.execute(localeCurrent));
  }
}