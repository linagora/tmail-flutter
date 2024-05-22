import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/state/base_ui_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/attempt_toggle_system_notification_setting_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_app_notification_setting_cache_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/notification_setting_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/toggle_app_notification_setting_cache_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/attempt_toggle_system_notification_setting_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_app_notification_setting_cache_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/toggle_app_notification_setting_cache_interactor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class NotificationController extends BaseController {
  final GetAppNotificationSettingCacheInteractor _getAppNotificationSettingCacheInteractor;
  final ToggleAppNotificationSettingCacheInteractor _toggleAppNotificationSettingCacheInteractor;
  final AttemptToggleSystemNotificationSettingInteractor _attemptToggleSystemNotificationSettingInteractor;

  NotificationController(
    this._getAppNotificationSettingCacheInteractor,
    this._toggleAppNotificationSettingCacheInteractor,
    this._attemptToggleSystemNotificationSettingInteractor);

  final appNotificationSettingEnabled = Rxn<bool>();

  bool get loading => viewState.value.fold(
    (failure) => false,
    (success) => success is NotificationSettingHandling);

  @override
  void onInit() {
    super.onInit();
    _getAppNotificationSettingCache();
  }

  @override
  void onClose() {
    dispatchState(Right(UIClosedState()));
    super.onClose();
  }

  @override
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
    if (success is GetAppNotificationSettingCacheSuccess) {
      appNotificationSettingEnabled.value = success.isEnabled;
    } else if (success is ToggleAppNotificationSettingCacheSuccess) {
      appNotificationSettingEnabled.toggle();
    } else if (success is AttemptToggleSystemNotificationSettingSuccess) {
      appNotificationSettingEnabled.value = success.isEnabled;
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is GetAppNotificationSettingCacheFailure
        || failure is AttemptToggleSystemNotificationSettingFailure) {
      appNotificationSettingEnabled.value = false;
    } else if (failure is ToggleAppNotificationSettingCacheFailure) {
      _handleToggleAppNotificationSettingCacheFailure();
    }
  }

  void _getAppNotificationSettingCache() {
    consumeState(_getAppNotificationSettingCacheInteractor.execute());
  }

  void toggleAppNotificationSetting() {
    if (loading) return;
    if (appNotificationSettingEnabled.value == null) return;
    
    consumeState(_toggleAppNotificationSettingCacheInteractor
        .execute(!appNotificationSettingEnabled.value!));
  }

  void _handleToggleAppNotificationSettingCacheFailure() {
    if (currentContext != null) {
      showConfirmDialogAction(currentContext!,
        AppLocalizations.of(currentContext!).doYouWantToEnableNotificationInSetting,
        AppLocalizations.of(currentContext!).yes,
        onConfirmAction: () {
          consumeState(_attemptToggleSystemNotificationSettingInteractor.execute());
        },
        showAsBottomSheet: true,
        title: AppLocalizations.of(currentContext!).cantTurnOnNotification,
        cancelTitle: AppLocalizations.of(currentContext!).no,
        icon: SvgPicture.asset(imagePaths.icNotification, width: 50, height: 50),
      );
    }
  }
}