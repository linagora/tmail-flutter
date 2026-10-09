import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/sidebar/sidebar_label_item.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/sidebar/sidebar_mailbox_item.dart';

import '../base/core_robot.dart';
import '../utils/wait_for_condition.dart';
import 'abstract/abstract_mailbox_assertion_robot.dart';

class MailboxAssertionRobot extends CoreRobot implements AbstractMailboxAssertionRobot {
  MailboxAssertionRobot(super.$);

  @override
  Future<void> expectMailboxVisible(PatrolFinder finder) async {
    await waitForCondition(() async => finder.evaluate().isNotEmpty);
    expect(finder, findsWidgets);
  }

  @override
  Future<void> expectSubfolderNotExist(PatrolFinder finder) async {
    await waitForCondition(() => !finder.exists);
  }

  @override
  Future<void> expectMailboxSelected(PatrolFinder mailbox) async {
    final selectedMailbox = mailbox.which<SidebarMailboxItem>(
      (w) => w.mailboxNodeSelected?.id == w.mailboxNode.item.id,
    );
    await waitForCondition(() => selectedMailbox.exists);
  }

  @override
  Future<void> expectLabelSelected(PatrolFinder label) async {
    final selectedLabel = label.which<SidebarLabelItem>((w) => w.isSelected);
    await waitForCondition(() => selectedLabel.exists);
  }
}
