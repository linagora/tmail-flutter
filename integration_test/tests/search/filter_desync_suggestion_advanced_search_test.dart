import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/search/filter_desync_suggestion_advanced_search_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should sync filters between suggestion list and advanced search dialog',
    scenarioBuilder: ($, robots) => FilterDesyncSuggestionAdvancedSearchScenario($, robots),
    tags: [TestTags.web],
  );
}
