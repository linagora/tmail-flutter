import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/search/right_click_focus_search_field_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should focus the search field when right clicking on it',
    tags: [TestTags.web],
    scenarioBuilder: ($, robots) => RightClickFocusSearchFieldScenario($, robots),
  );
}
