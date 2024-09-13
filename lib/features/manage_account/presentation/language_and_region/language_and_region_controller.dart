
import 'dart:ui';

import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/save_language_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/save_language_interactor.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

class LanguageAndRegionController extends BaseController {

  final SaveLanguageInteractor _saveLanguageInteractor;

  final languageSelected = LocalizationService.defaultLocale.obs;

  LanguageAndRegionController(this._saveLanguageInteractor);

  @override
  void onReady() {
    _setUpSupportedLanguages();
    super.onReady();
  }

  @override
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
    if (success is SaveLanguageSuccess) {
      LocalizationService.changeLocale(success.localeStored.languageCode);
    }
  }

  void _setUpSupportedLanguages() {
    final currentLocale = Get.locale;
    log('LanguageAndRegionController::_setUpSupportedLanguages():currentLocale: $currentLocale');
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