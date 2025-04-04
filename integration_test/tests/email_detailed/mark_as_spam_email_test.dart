import '../../base/test_base.dart';
import '../../scenarios/email_detailed/mark_as_spam_email_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see email in Spam folder when open detailed email and mark as spam email successfully',
    scenarioBuilder: ($) => MarkAsSpamEmailScenario($),
  );
}