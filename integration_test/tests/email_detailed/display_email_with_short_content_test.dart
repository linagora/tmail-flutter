import '../../base/test_base.dart';
import '../../scenarios/email_detailed/display_email_with_short_content_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should display full content when opening a short email',
    scenarioBuilder: ($) => DisplayEmailWithShortContentScenario($),
  );
}