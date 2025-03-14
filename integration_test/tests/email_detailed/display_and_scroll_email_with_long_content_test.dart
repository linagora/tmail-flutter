import '../../base/test_base.dart';
import '../../scenarios/email_detailed/display_and_scroll_email_with_long_content_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should be visible and fully scrollable when opening a long email',
    scenarioBuilder: ($) => DisplayAndScrollEmailWithLongContentScenario($),
  );
}