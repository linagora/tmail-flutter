import '../../base/test_base.dart';
import '../../scenarios/email_detailed/reply_email_replied_when_change_language_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'The subject line of an email should not be changed when replying to an email that has already been replied to.',
    scenarioBuilder: ($) => ReplyEmailRepliedWhenChangeLanguageScenario($),
  );
}
