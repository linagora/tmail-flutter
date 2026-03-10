import '../../base/test_base.dart';
import '../../scenarios/email_detailed/forward_email_forwarded_when_change_language_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'The subject line of an email should not be changed when forwarding to an email that has already been forwarded to.',
    scenarioBuilder: ($) => ForwardEmailForwardedWhenChangeLanguageScenario($),
  );
}
