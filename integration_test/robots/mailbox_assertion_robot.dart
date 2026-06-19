import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

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
}
