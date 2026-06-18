import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/loader_status.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/model/preference_option.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/model/preference_option_registry.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_local_settings_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/update_local_settings_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_local_settings_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/reveal_experimental_preferences_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/providers/experimental_preferences_revealed_provider.dart';
import 'package:tmail_ui_user/main/providers/settings/local_settings_notifier.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';
import 'package:tmail_ui_user/features/server_settings/domain/state/get_server_setting_state.dart';
import 'package:tmail_ui_user/features/server_settings/domain/state/update_server_setting_state.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/get_server_setting_interactor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class PreferencesController extends BaseController {
  PreferencesController(
    this._getServerSettingInteractor,
    this._getLocalSettingInteractor,
    this._preferenceOptionRegistry,
    this._revealExperimentalPreferencesInteractor,
  );

  final GetServerSettingInteractor _getServerSettingInteractor;
  final GetLocalSettingsInteractor _getLocalSettingInteractor;
  final PreferenceOptionRegistry _preferenceOptionRegistry;
  final RevealExperimentalPreferencesInteractor _revealExperimentalPreferencesInteractor;

  PreferenceOptionRegistry get registry => _preferenceOptionRegistry;

  /// A snapshot of all state the registered options read from.
  PreferencesContext get preferencesContext => (
        session: accountDashboardController.sessionCurrent,
        accountId: accountDashboardController.accountId.value,
        serverOptions: settingOption.value,
        localSettings: localSettings.value,
        isAIScribeAvailable: isAIScribeCapabilityAvailable,
        isAICapabilitySupported: isAICapabilitySupported,
        isLabelVisibilityEnabled:
            accountDashboardController.isLabelVisibilityEnabled.value,
      );

  Future<void> revealExperimentalPreferences() async {
    await _revealExperimentalPreferencesInteractor.execute();
    appProviderContainer.invalidate(experimentalPreferencesRevealedProvider);
  }

  final settingOption = Rxn<TMailServerSettingOptions>();
  final localSettings = Rx<PreferencesSetting>(PreferencesSetting.initial());

  AppLifecycleListener? _appLifecycleListener;
  LoaderStatus _localSettingLoaderStatus = LoaderStatus.idle;

  bool get isLoading => viewState.value.fold(
    (failure) => false, 
    (success) => success is GettingServerSetting || success is UpdatingServerSetting);

  final accountDashboardController = Get.find<ManageAccountDashBoardController>();

  bool get isAICapabilitySupported {
    return accountDashboardController.isAICapabilitySupported;
  }

  bool get isAIScribeCapabilityAvailable {
    return accountDashboardController.isAIScribeCapabilityAvailable;
  }

  @override
  void onInit() {
    super.onInit();
    _getSettingOption();

    _appLifecycleListener ??= AppLifecycleListener(
      onResume: () {
        if (_localSettingLoaderStatus == LoaderStatus.loading) {
          return;
        }
        consumeState(_getLocalSettingInteractor.execute());
      },
    );
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is GetServerSettingSuccess) {
      _updateSettingOptionValue(newSettingOption: success.settingOption);
    } else if (success is UpdateServerSettingSuccess) {
      _updateSettingOptionValue(newSettingOption: success.settingOption);
    } else if (success is GetLocalSettingsSuccess) {
      _localSettingLoaderStatus = LoaderStatus.completed;
      _updateLocalSettingOptionValue(success.preferencesSetting);
    } else if (success is UpdateLocalSettingsSuccess) {
      _updateLocalSettingOptionValue(success.preferencesSetting);
      appProviderContainer
          .read(localSettingsProvider.notifier)
          .update(success.preferencesSetting);
    } else if (success is GettingLocalSettingsState) {
      _localSettingLoaderStatus = LoaderStatus.loading;
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is GetServerSettingFailure) {
      _updateSettingOptionValue(newSettingOption: null);
    } else if (failure is GetLocalSettingsFailure) {
      _localSettingLoaderStatus = LoaderStatus.completed;
    } else if (failure is UpdateServerSettingFailure) {
      _handleUpdateServerSettingFailure();
    } else {
      super.handleFailureViewState(failure);
    }
  }

  @override
  void handleErrorViewState(Object error, StackTrace stackTrace) {
    super.handleErrorViewState(error, stackTrace);
    _localSettingLoaderStatus = LoaderStatus.completed;
  }

  void _handleUpdateServerSettingFailure() {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).an_error_occurred);
    }
  }

  void _updateSettingOptionValue({required TMailServerSettingOptions? newSettingOption}) {
    settingOption.value = newSettingOption;
  }

  void _updateLocalSettingOptionValue(PreferencesSetting preferencesSetting) {
    localSettings.value = preferencesSetting;
  }

  void _getSettingOption() {
    consumeState(_getLocalSettingInteractor.execute());
    final accountId = accountDashboardController.accountId.value;
    if (accountId != null) {
      consumeState(_getServerSettingInteractor.execute(accountId));
    } else {
      consumeState(Stream.value(Left(GetServerSettingFailure(NotFoundAccountIdException()))));
    }
  }

  void updateStateSettingOption(PreferenceOption option, bool currentValue) {
    consumeState(
      option.toggle(currentValue: currentValue, context: preferencesContext),
    );
  }

  @override
  void onClose() {
    _appLifecycleListener?.dispose();
    super.onClose();
  }
}