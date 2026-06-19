import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';

import '../mailbox_navigation_robot.dart';
import '../mobile/mobile_mailbox_menu_robot.dart';

/// Web-specific navigation robot that simulates "long-press" via mouse hover
/// then tapping the more-action button, because mobile long-press gestures
/// are not available in a web browser context.
class WebMailboxNavigationRobot extends MailboxNavigationRobot {
  WebMailboxNavigationRobot(super.$);

  @override
  Future<void> longPressMailbox(PatrolFinder finder) async {
    await finder.waitUntilExists();

    final gesture = await $.tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    try {
      await gesture.moveTo($.tester.getCenter(finder));
      await $.pump();

      await finder.$(const ValueKey(UiKeys.mailboxMoreActionButton)).tap();
      await $.pumpAndTrySettle();
    } finally {
      await gesture.removePointer();
    }
  }
}

class WebMailboxMenuRobot extends MobileMailboxMenuRobot {
  WebMailboxMenuRobot(super.$) : super(navigationRobot: WebMailboxNavigationRobot($));

  @override
  Future<void> openSetting() async {
    await $(const ValueKey(UiKeys.userAvatar)).tap();
    await $(ValueKey(ProfileSettingActionType.manageAccount.name)).tap();
  }
}
