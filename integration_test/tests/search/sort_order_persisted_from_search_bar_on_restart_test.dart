import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/search/sort_order_persisted_from_search_bar_on_restart_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'GIVEN user previously stored oldest sort order '
        'WHEN app restarts and user searches from the inline search bar '
        'THEN search results should be sorted by oldest',
    scenarioBuilder: ($, robots) =>
        SortOrderPersistedFromSearchBarOnRestartScenario($, robots),
    tags: [TestTags.web],
  );
}
