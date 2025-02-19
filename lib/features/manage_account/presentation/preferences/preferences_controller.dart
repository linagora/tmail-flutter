import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/setting_option_type.dart';
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
  );

  final GetServerSettingInteractor _getServerSettingInteractor;
  final UpdateServerSettingInteractor _updateServerSettingInteractor;

  final settingOption = Rxn<TMailServerSettingOptions>();

  bool get isLoading => viewState.value.fold(
    (failure) => false, 
    (success) => success is GettingServerSetting || success is UpdatingServerSetting);

  final _manageAccountDashBoardController = Get.find<ManageAccountDashBoardController>();

  @override
  void onInit() {
    super.onInit();
    _getSettingOption();
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is GetServerSettingSuccess) {
      _updateSettingOptionValue(newSettingOption: success.settingOption);
    } else if (success is UpdateServerSettingSuccess) {
      _updateSettingOptionValue(newSettingOption: success.settingOption);
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is GetServerSettingFailure) {
      _updateSettingOptionValue(newSettingOption: null);
    } else if (failure is UpdateServerSettingFailure) {
      _handleUpdateServerSettingFailure();
    } else {
      super.handleFailureViewState(failure);
    }
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

  void _getSettingOption() {
    final accountId = _manageAccountDashBoardController.accountId.value;
    if (accountId != null) {
      consumeState(_getServerSettingInteractor.execute(accountId));
    } else {
      consumeState(Stream.value(Left(GetServerSettingFailure(NotFoundAccountIdException()))));
    }
  }

  void updateStateSettingOption(SettingOptionType optionType, bool isEnabled) {
    TMailServerSettingOptions? newSettingOption;
    switch(optionType) {
      case SettingOptionType.readReceipt:
        newSettingOption = settingOption.value?.copyWith(
          alwaysReadReceipts: !isEnabled,
        );
        break;
      case SettingOptionType.senderPriority:
        newSettingOption = settingOption.value?.copyWith(
          displaySenderPriority: !isEnabled,
        );
        break;
      default:
        break;
    }

    final accountId = _manageAccountDashBoardController.accountId.value;
    if (accountId != null && newSettingOption != null) {
      consumeState(_updateServerSettingInteractor.execute(
        accountId,
        newSettingOption,
      ));
    } else {
      consumeState(Stream.value(Left(UpdateServerSettingFailure(NotFoundAccountIdException()))));
    }
  }
}