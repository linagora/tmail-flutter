import 'package:flutter/foundation.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';

import '../abstract/abstract_mailbox_assertion_robot.dart';
import '../abstract/abstract_mailbox_label_robot.dart';
import '../abstract/abstract_mailbox_menu_robot.dart';
import '../abstract/abstract_mailbox_navigation_robot.dart';
import '../mailbox_menu_robot.dart';

class MobileMailboxMenuRobot extends MailboxMenuRobot implements AbstractMailboxMenuRobot {
  MobileMailboxMenuRobot(
    PatrolIntegrationTester $, {
    AbstractMailboxNavigationRobot? navigationRobot,
    AbstractMailboxLabelRobot? labelRobot,
    AbstractMailboxAssertionRobot? assertionRobot,
  }) : super(
          $,
          navigationRobot: navigationRobot,
          labelRobot: labelRobot,
          assertionRobot: assertionRobot,
        );

  @override
  Future<void> openSetting() async {
    await $(const ValueKey(UiKeys.mobileMailboxMenuButton)).tap();
    await super.openSetting();
  }
}
