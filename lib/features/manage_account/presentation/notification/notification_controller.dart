import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_notification_setting_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_notification_setting_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/toggle_notification_setting_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_controller.dart';

class NotificationController extends FullLifeCycleController with FullLifeCycleMixin {
  final GetNotificationSettingInteractor _getNotificationSettingInteractor;
  final ToggleNotificationSettingInteractor _toggleNotificationSettingInteractor;

  NotificationController(
    this._getNotificationSettingInteractor,
    this._toggleNotificationSettingInteractor);

  final notificationSettingEnabled = Rxn<bool>();
  final settingsController = Get.find<SettingsController>();

  @override
  Future<void> onInit() async {
    super.onInit();
    await _getNotificationSetting();
  }

  Future<void> _getNotificationSetting() async {
    final userName = settingsController.manageAccountDashboardController.sessionCurrent?.username;
    if (userName == null) {
      notificationSettingEnabled.value = false;
      return;
    }
    final getNotificationSettingState = await _getNotificationSettingInteractor
      .execute(userName).last;
    getNotificationSettingState.fold(
      (failure) {
        notificationSettingEnabled.value = false;
      }, (success) {
        notificationSettingEnabled.value = success is GetNotificationSettingSuccess
          ? success.isEnabled
          : false;
      });
  }

  Future<void> toggleNotificationSetting() async {
    if (notificationSettingEnabled.value == null) return;
    
    await _toggleNotificationSettingInteractor.execute().last;
  }
  
  @override
  void onDetached() {}
  
  @override
  void onInactive() {}
  
  @override
  void onPaused() {}
  
  @override
  Future<void> onResumed() => _getNotificationSetting();
  
  @override
  void onHidden() {}
}