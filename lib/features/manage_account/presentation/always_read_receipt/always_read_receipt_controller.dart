import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/server_settings/domain/state/get_always_read_receipt_setting_state.dart';
import 'package:tmail_ui_user/features/server_settings/domain/state/update_always_read_receipt_setting_state.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/get_always_read_receipt_setting_interactor.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/update_always_read_receipt_setting_interactor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class AlwaysReadReceiptController extends BaseController {
  AlwaysReadReceiptController(
    this._getAlwaysReadReceiptSettingInteractor,
    this._updateAlwaysReadReceiptSettingInteractor,
  );

  final GetAlwaysReadReceiptSettingInteractor _getAlwaysReadReceiptSettingInteractor;
  final UpdateAlwaysReadReceiptSettingInteractor _updateAlwaysReadReceiptSettingInteractor;

  final alwaysReadReceipt = true.obs;
  bool get isLoading => viewState.value.fold(
    (failure) => false, 
    (success) => success is GettingAlwaysReadReceiptSetting || success is UpdatingAlwaysReadReceiptSetting);
  final _manageAccountDashBoardController = Get.find<ManageAccountDashBoardController>();

  @override
  void onInit() {
    super.onInit();

    _getCurrentAlwaysReadReceiptSetting();
  }

  @override
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
    if (success is GetAlwaysReadReceiptSettingSuccess) {
      _getAlwaysReadReceiptSettingSuccess(success);
    } else if (success is UpdateAlwaysReadReceiptSettingSuccess) {
      _updateAlwaysReadReceiptSettingSuccess(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is GetAlwaysReadReceiptSettingFailure) {
      _getAlwaysReadReceiptSettingFailure();
    } else if (failure is UpdateAlwaysReadReceiptSettingFailure) {
      _updateAlwaysReadReceiptSettingFailure();
    }
  }

  void _updateAlwaysReadReceiptValue(bool value) {
    alwaysReadReceipt.value = value;
  }

  void _updateAlwaysReadReceiptSettingFailure() {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).an_error_occurred);
    }
  }

  void _updateAlwaysReadReceiptSettingSuccess(
    UpdateAlwaysReadReceiptSettingSuccess success
  ) {
    _updateAlwaysReadReceiptValue(success.alwaysReadReceiptIsEnabled);
  }

  void toggleAlwaysReadReceipt() {
    if (isLoading) return;
    final accountId = _manageAccountDashBoardController.accountId.value;
    if (accountId != null) {
      consumeState(_updateAlwaysReadReceiptSettingInteractor.execute(
        accountId,
        !alwaysReadReceipt.value));
    }
  }

  void _getAlwaysReadReceiptSettingFailure() {
    alwaysReadReceipt.value = true;
  }

  void _getAlwaysReadReceiptSettingSuccess(
    GetAlwaysReadReceiptSettingSuccess success
  ) {
    _updateAlwaysReadReceiptValue(success.alwaysReadReceiptEnabled);
  }

  void _getCurrentAlwaysReadReceiptSetting() {
    final accountId = _manageAccountDashBoardController.accountId.value;
    if (accountId != null) {
      consumeState(_getAlwaysReadReceiptSettingInteractor.execute(accountId));
    }
  }
}