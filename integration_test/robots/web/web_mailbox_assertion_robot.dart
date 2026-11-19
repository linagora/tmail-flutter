import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/sidebar/sidebar_label_item.dart';

import '../../utils/wait_for_condition.dart';
import '../mailbox_assertion_robot.dart';
import '../mailbox_label_robot.dart';

/// Web-specific mailbox assertions: the sidebar is always visible, so there is
/// no drawer to open.
class WebMailboxAssertionRobot extends MailboxAssertionRobot {
  WebMailboxAssertionRobot(super.$);

  @override
  Future<void> expectLabelSelected(PatrolFinder label) async {
    final selectedLabel = label.which<SidebarLabelItem>((w) => w.isSelected);
    // scrollTo() scrolls the first Scrollable, which is not the sidebar on web.
    await MailboxLabelRobot($).ensureLabelReady(selectedLabel);
    await waitForCondition(() => selectedLabel.exists);
  }
}
