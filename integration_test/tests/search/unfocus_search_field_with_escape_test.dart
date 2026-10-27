import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/search/unfocus_search_field_with_escape_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should unfocus the search field when pressing Escape',
    scenarioBuilder: ($, robots) => UnfocusSearchFieldWithEscapeScenario($, robots),
    tags: [TestTags.web],
  );
}
