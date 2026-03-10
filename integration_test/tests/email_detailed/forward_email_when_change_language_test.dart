import '../../base/test_base.dart';
import '../../scenarios/email_detailed/forward_email_when_change_language_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'The forward prefix should be displayed correctly when forwarding an email.',
    scenarioBuilder: ($) => ForwardEmailWhenChangeLanguageScenario($),
  );
}
