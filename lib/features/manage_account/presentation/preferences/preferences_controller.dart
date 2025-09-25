import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/loader_status.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/spam_report_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/thread_detail_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_local_settings_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/update_local_settings_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_local_settings_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/update_local_settings_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/preferences_option_type.dart';
import 'package:tmail_ui_user/features/server_settings/domain/state/get_server_setting_state.dart';
import 'package:tmail_ui_user/features/server_settings/domain/state/update_server_setting_state.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/get_server_setting_interactor.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/update_server_setting_interactor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class PreferencesController extends BaseController {
  PreferencesController(
    this._getServerSettingInteractor,
    this._updateServerSettingInteractor,
    this._getLocalSettingInteractor,
    this._updateLocalSettingsInteractor,
  );

  final GetServerSettingInteractor _getServerSettingInteractor;
  final UpdateServerSettingInteractor _updateServerSettingInteractor;
  final GetLocalSettingsInteractor _getLocalSettingInteractor;
  final UpdateLocalSettingsInteractor _updateLocalSettingsInteractor;

  final settingOption = Rxn<TMailServerSettingOptions>();
  final localSettings = Rx<PreferencesSetting>(PreferencesSetting.initial());

  AppLifecycleListener? _appLifecycleListener;
  LoaderStatus _localSettingLoaderStatus = LoaderStatus.idle;

  bool get isLoading => viewState.value.fold(
    (failure) => false, 
    (success) => success is GettingServerSetting || success is UpdatingServerSetting);

  final _manageAccountDashBoardController = Get.find<ManageAccountDashBoardController>();

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
    final accountId = _manageAccountDashBoardController.accountId.value;
    if (accountId != null) {
      consumeState(_getServerSettingInteractor.execute(accountId));
    } else {
      consumeState(Stream.value(Left(GetServerSettingFailure(NotFoundAccountIdException()))));
    }
  }

  void updateStateSettingOption(
    PreferencesOptionType optionType,
    bool isEnabled,
  ) {
    if (optionType.isLocal) {
      _updateLocalPreferencesSetting(optionType, isEnabled);
    } else {
      _updateServerPreferencesSetting(optionType, isEnabled);
    }
  }

  void _updateLocalPreferencesSetting(
    PreferencesOptionType optionType,
    bool isEnabled,
  ) {
    PreferencesConfig? config;
    switch(optionType) {
      case PreferencesOptionType.thread:
        config = ThreadDetailConfig(isEnabled: !isEnabled);
        break;
      case PreferencesOptionType.spamReport:
        config = SpamReportConfig(isEnabled: !isEnabled);
        break;
      default:
        break;
    }

    if (config != null) {
      consumeState(_updateLocalSettingsInteractor.execute(config));
    }
  }

  void _updateServerPreferencesSetting(
    PreferencesOptionType optionType,
    bool isEnabled,
  ) {
    TMailServerSettingOptions? newSettingOption;
    switch(optionType) {
      case PreferencesOptionType.readReceipt:
        newSettingOption = settingOption.value?.copyWith(
          alwaysReadReceipts: !isEnabled,
        );
        break;
      case PreferencesOptionType.senderPriority:
        newSettingOption = settingOption.value?.copyWith(
          displaySenderPriority: !isEnabled,
        );
        break;
      default:
        break;
    }

    final session = _manageAccountDashBoardController.sessionCurrent;
    final accountId = _manageAccountDashBoardController.accountId.value;
    if (session != null && accountId != null && newSettingOption != null) {
      consumeState(
        _updateServerSettingInteractor.execute(
          session,
          accountId,
          newSettingOption,
        ),
      );
    } else {
      consumeState(
        Stream.value(
          Left(UpdateServerSettingFailure(NotFoundAccountIdException())),
        ),
      );
    }
  }


  @override
  void onClose() {
    _appLifecycleListener?.dispose();
    super.onClose();
  }
}