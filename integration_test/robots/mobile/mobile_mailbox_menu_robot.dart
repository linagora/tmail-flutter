import 'package:flutter/foundation.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';

import '../abstract/abstract_mailbox_menu_robot.dart';
import '../mailbox_menu_robot.dart';

class MobileMailboxMenuRobot extends MailboxMenuRobot implements AbstractMailboxMenuRobot {
  MobileMailboxMenuRobot(super.$);

  @override
  Future<void> openSetting() async {
    await $(const ValueKey(UiKeys.mobileMailboxMenuButton)).tap();
    await super.openSetting();
  }
}