import '../../base/test_base.dart';
import '../../scenarios/mailbox/search_mailbox_inbox_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see expected mailbox when searching mailboxes',
    scenarioBuilder: ($) => SearchMailboxInboxScenario($),
  );
} 