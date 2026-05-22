import 'package:flutter/foundation.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';

import '../mobile/mobile_mailbox_menu_robot.dart';

class WebMailboxMenuRobot extends MobileMailboxMenuRobot {
  WebMailboxMenuRobot(super.$);

  @override
  Future<void> openSetting() async {
    await $(const ValueKey(UiKeys.userAvatar)).tap();
    await $(ValueKey(ProfileSettingActionType.manageAccount.name)).tap();
  }
}