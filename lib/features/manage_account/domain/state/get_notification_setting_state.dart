import 'package:tmail_ui_user/features/manage_account/domain/state/notification_setting_state.dart';

class GettingNotificationSetting extends NotificationSettingHandling {}

class GetNotificationSettingSuccess extends NotificationSettingSuccess {
  GetNotificationSettingSuccess({required this.isEnabled});

  final bool isEnabled;

  @override
  List<Object?> get props => [isEnabled];
}

class GetNotificationSettingFailure extends NotificationSettingFailure {}