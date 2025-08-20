
import 'package:flutter/cupertino.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';

extension HandleProfileSettingActionTypeClickExtension on MailboxDashBoardController {
  void handleProfileSettingActionTypeClick({
    required BuildContext context,
    required ProfileSettingActionType actionType,
 }) {
    switch (actionType) {
      case ProfileSettingActionType.signOut:
        String accountDisplayName = ownEmailAddress.value;
        if (accountDisplayName.trim().isEmpty) {
          accountDisplayName =
              sessionCurrent?.getOwnEmailAddressOrUsername() ?? '';
        }
        logout(context, sessionCurrent, accountId.value, accountDisplayName);
        break;
      case ProfileSettingActionType.manageAccount:
        goToSettings();
        break;
    }
  }
}