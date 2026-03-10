import '../../base/test_base.dart';
import '../../scenarios/email_detailed/reply_email_when_change_language_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'The reply prefix should be displayed correctly when replying to an email.',
    scenarioBuilder: ($) => ReplyEmailWhenChangeLanguageScenario($),
  );
}