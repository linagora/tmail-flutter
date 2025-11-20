import '../../base/test_base.dart';
import '../../scenarios/email/reply_to_own_sent_email_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should all To recipients when reply to own sent email',
    scenarioBuilder: ($) => ReplyToOwnSentEmailScenario($),
  );
}