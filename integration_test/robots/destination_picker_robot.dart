
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/label_mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_item_widget.dart';

import '../base/core_robot.dart';

class DestinationPickerRobot extends CoreRobot {
  DestinationPickerRobot(super.$);

  Future<void> selectFolderByName(String name) async {
    await $(MailboxItemWidget)
      .$(LabelMailboxItemWidget)
      .$(find.text(name))
      .tap();
  }
}