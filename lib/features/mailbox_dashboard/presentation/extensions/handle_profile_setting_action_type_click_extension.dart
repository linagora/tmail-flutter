
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';

extension HandleProfileSettingActionTypeClickExtension on MailboxDashBoardController {
  void handleProfileSettingActionTypeClick({
    required BuildContext context,
    required ProfileSettingActionType actionType,
 }) {
    switch (actionType) {
      case ProfileSettingActionType.signOut:
        logout(context, sessionCurrent, accountId.value);
        break;
      case ProfileSettingActionType.manageAccount:
        goToSettings();
        break;
    }
  }
}