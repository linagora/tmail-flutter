import '../../base/test_base.dart';
import '../../scenarios/email_detailed/reply_to_list_email_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
      'SHOULD see the Subject contain the prefix `Re:`\n'
      'AND the To field should contain the email\'s `List-Post` address.',
    scenarioBuilder: ($) => ReplyToListEmailScenario($),
  );
}