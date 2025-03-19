import '../../base/test_base.dart';
import '../../scenarios/mailbox/mark_mailbox_as_read_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should not see unread counter when mark mailbox as read',
    scenarioBuilder: ($) => MarkMailboxAsReadScenario($),
  );
}
