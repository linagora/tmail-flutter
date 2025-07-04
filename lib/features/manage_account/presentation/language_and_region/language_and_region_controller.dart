import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_settings/server_settings/capability_server_settings.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/save_language_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/save_language_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/save_language_to_server_settings_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/language/context_item_language_action.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class LanguageAndRegionController extends BaseController {

  final SaveLanguageInteractor _saveLanguageInteractor;
  final SaveLanguageToServerSettingsInteractor saveLanguageToServerSettingsInteractor;

  final listSupportedLanguages = <Locale>[].obs;
  final languageSelected = LocalizationService.defaultLocale.obs;

  final manageAccountDashBoardController = Get.find<ManageAccountDashBoardController>();

  LanguageAndRegionController(
    this._saveLanguageInteractor,
    this.saveLanguageToServerSettingsInteractor,
  );

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
    languageSelected.value = selectedLocale ?? LocalizationService.defaultLocale;
    _saveLanguage(languageSelected.value);
  }

  void _saveLanguage(Locale localeCurrent) {
    consumeState(_saveLanguageInteractor.execute(localeCurrent));

    final session = manageAccountDashBoardController.sessionCurrent;
    final accountId = manageAccountDashBoardController.accountId.value;
    if (accountId == null ||
        session == null ||
        !capabilityServerSettings.isSupported(session, accountId) ||
        session.isLanguageReadOnly(accountId)) return;

    consumeState(saveLanguageToServerSettingsInteractor.execute(
      accountId,
      localeCurrent,
    ));
  }

  void openLanguageContextMenu(BuildContext context) {
    final contextMenuActions = listSupportedLanguages.map((language) {
      return ContextItemLanguageAction(
        language,
        languageSelected.value,
        AppLocalizations.of(context),
        imagePaths,
      );
    }).toList();

    openBottomSheetContextMenuAction(
      key: const Key('language_context_menu'),
      context: context,
      itemActions: contextMenuActions,
      onContextMenuActionClick: (menuAction) {
        popBack();
        selectLanguage(menuAction.action);
      },
    );
  }
}