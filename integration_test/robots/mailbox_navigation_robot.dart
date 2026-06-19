import 'package:patrol/patrol.dart';

import '../base/core_robot.dart';
import 'abstract/abstract_mailbox_navigation_robot.dart';

class MailboxNavigationRobot extends CoreRobot implements AbstractMailboxNavigationRobot {
  MailboxNavigationRobot(super.$);

  Future<void> _ensureReady(PatrolFinder finder) async {
    await finder.waitUntilExists();
    await $.scrollUntilVisible(finder: finder);
  }

  @override
  Future<void> openFolder(PatrolFinder finder) async {
    await _ensureReady(finder);
    await finder.tap();
  }

  @override
  Future<void> longPressMailbox(PatrolFinder finder) async {
    await _ensureReady(finder);
    await finder.longPress();
    await $.pumpAndSettle();
  }

  @override
  Future<void> expandMailbox(PatrolFinder finder) async {
    await _ensureReady(finder);
    final expandButton = finder.$(#expand_mailbox_button);
    await expandButton.waitUntilExists();
    await expandButton.tap();
  }

  @override
  Future<void> tapMailbox(PatrolFinder finder) async {
    await _ensureReady(finder);
    await finder.tap();
    await $.pumpAndSettle(duration: const Duration(seconds: 2));
  }
}
