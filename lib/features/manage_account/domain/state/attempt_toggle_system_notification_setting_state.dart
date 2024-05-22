import 'package:tmail_ui_user/features/manage_account/domain/state/notification_setting_state.dart';

class AttemptingToggleSystemNotificationSetting extends NotificationSettingHandling {}

class AttemptToggleSystemNotificationSettingSuccess extends NotificationSettingSuccess {
  final bool isEnabled;

  AttemptToggleSystemNotificationSettingSuccess(this.isEnabled);
}

class AttemptToggleSystemNotificationSettingFailure extends NotificationSettingFailure {}