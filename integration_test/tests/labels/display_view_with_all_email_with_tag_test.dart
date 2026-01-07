import '../../base/test_base.dart';
import '../../scenarios/labels/display_view_with_all_email_with_tag_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should display view with all email with tag correctly when open label',
    scenarioBuilder: ($) => DisplayViewWithAllEmailWithTagScenario($),
  );
}
