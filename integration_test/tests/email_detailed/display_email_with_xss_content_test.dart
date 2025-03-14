import '../../base/test_base.dart';
import '../../scenarios/email_detailed/display_email_with_xss_content_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should not display alert dialog when opening an email containing content xss',
    scenarioBuilder: ($) => DisplayEmailWithXssContentScenario($),
  );
}