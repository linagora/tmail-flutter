import 'package:tmail_ui_user/features/manage_account/domain/state/notification_setting_state.dart';

class GettingAppNotificationSettingCache extends NotificationSettingHandling {}

class GetAppNotificationSettingCacheSuccess extends NotificationSettingSuccess {
  final bool isEnabled;

  GetAppNotificationSettingCacheSuccess(this.isEnabled);
}

class GetAppNotificationSettingCacheFailure extends NotificationSettingFailure {}