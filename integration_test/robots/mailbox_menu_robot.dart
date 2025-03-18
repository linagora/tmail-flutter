
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/label_mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

import '../base/core_robot.dart';
import '../exceptions/mailbox/null_inbox_unread_count_exception.dart';

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

  int getCurrentInboxCount() {
    final inboxCount = Get.find<MailboxDashBoardController>()
      .selectedMailbox
      .value
      ?.unreadEmails
      ?.value
      .value
      .toInt();

    if (inboxCount == null) {
      throw NullInboxUnreadCountException();
    }

    return inboxCount;
  }
}