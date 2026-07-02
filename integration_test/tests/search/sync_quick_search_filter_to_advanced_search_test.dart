import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/search/sync_quick_search_filter_to_advanced_search_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should reflect a suggestion-dropdown filter in the advanced search form fields',
    scenarioBuilder: ($, robots) =>
        SyncQuickSearchFilterToAdvancedSearchScenario($, robots),
    tags: [TestTags.web],
  );
}
