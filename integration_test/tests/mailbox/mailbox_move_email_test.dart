import '../../base/test_base.dart';
import '../../scenarios/mailbox/mailbox_move_email_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should move email to mailbox successfully',
    scenarioBuilder: ($) => MailboxMoveEmailScenario($),
  );
}
