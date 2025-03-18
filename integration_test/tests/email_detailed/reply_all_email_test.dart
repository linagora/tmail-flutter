import '../../base/test_base.dart';
import '../../scenarios/email_detailed/reply_all_email_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
      'SHOULD see the Subject contain the prefix `Re:`\n'
      'AND the To, Cc, Bcc field should display correctly',
    scenarioBuilder: ($) => ReplyAllEmailScenario($),
  );
}