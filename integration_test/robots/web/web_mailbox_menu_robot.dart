import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';

import '../mailbox_navigation_robot.dart';
import '../mobile/mobile_mailbox_menu_robot.dart';
import 'web_hover_tap.dart';
import 'web_mailbox_label_robot.dart';

/// Web-specific navigation robot that simulates "long-press" via mouse hover
/// then tapping the more-action button, because mobile long-press gestures
/// are not available in a web browser context.
class WebMailboxNavigationRobot extends MailboxNavigationRobot {
  WebMailboxNavigationRobot(super.$);

  @override
  Future<void> longPressMailbox(PatrolFinder finder) async {
    await finder.waitUntilExists();
    await webHoverThenTap(
      $,
      finder,
      finder.$(const ValueKey(UiKeys.mailboxMoreActionButton)),
    );
  }
}

class WebMailboxMenuRobot extends MobileMailboxMenuRobot {
  WebMailboxMenuRobot(super.$)
      : super(
          navigationRobot: WebMailboxNavigationRobot($),
          labelRobot: WebMailboxLabelRobot($),
        );

  @override
  Future<void> openSetting() async {
    await $(const ValueKey(UiKeys.userAvatar)).tap();
    await $(ValueKey(ProfileSettingActionType.manageAccount.name)).tap();
  }
}
