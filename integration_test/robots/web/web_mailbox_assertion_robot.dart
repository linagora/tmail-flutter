import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/sidebar/sidebar_label_item.dart';

import '../../utils/wait_for_condition.dart';
import '../mailbox_assertion_robot.dart';

/// Web-specific mailbox assertions: the sidebar is always visible, so there is
/// no drawer to open.
class WebMailboxAssertionRobot extends MailboxAssertionRobot {
  WebMailboxAssertionRobot(super.$);

  @override
  Future<void> expectLabelSelected(PatrolFinder label) async {
    final selectedLabel = label.which<SidebarLabelItem>((w) => w.isSelected);
    await $(selectedLabel).scrollTo(scrollDirection: AxisDirection.down);
    await waitForCondition(() => selectedLabel.exists);
  }
}
