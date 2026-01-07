import '../../base/test_base.dart';
import '../../scenarios/labels/display_empty_view_when_open_tag_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should display empty view when open tag with no email',
    scenarioBuilder: ($) => DisplayEmptyViewWhenOpenTagScenario($),
  );
}
