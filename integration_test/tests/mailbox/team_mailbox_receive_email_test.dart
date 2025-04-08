import '../../base/test_base.dart';
import '../../scenarios/mailbox/team_mailbox_receive_email_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see email in team mailbox INBOX after sending to team mailbox address',
    scenarioBuilder: ($) => TeamMailboxReceiveEmailScenario($),
  );
} 