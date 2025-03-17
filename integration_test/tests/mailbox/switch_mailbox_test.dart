import '../../base/test_base.dart';
import '../../scenarios/mailbox/switch_mailbox_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should switch and see emails in mailboxes',
    scenarioBuilder: ($) => SwitchMailboxScenario($),
  );
}