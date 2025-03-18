import '../../base/test_base.dart';
import '../../scenarios/email_detailed/reply_email_with_reply_to_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
      'SHOULD see the Subject contain the prefix `Re:`\n'
      'AND the To field should contain the email\'s `Reply-To` address.',
    scenarioBuilder: ($) => ReplyEmailWithReplyToScenario($),
  );
}