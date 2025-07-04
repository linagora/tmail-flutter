
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/label_mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_item_widget.dart';

import '../base/core_robot.dart';

class MailboxMenuRobot extends CoreRobot {
  MailboxMenuRobot(super.$);

  Future<void> openAppGrid() async {
    await $(#toggle_app_grid_button).tap();
  }

  Future<void> openFolderByName(String name) async {
    await $(MailboxItemWidget)
      .$(LabelMailboxItemWidget)
      .$(find.text(name))
      .tap();
  }

  Future<void> openSetting() async {
    await $(#user_avatar).tap();
  }
}