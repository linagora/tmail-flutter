import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/search/collapsed_threads_search_more_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should list every thread once when thread view is on '
        'and the search results load more',
    // Search results use the thread list layout only on web desktop.
    tags: [TestTags.web],
    scenarioBuilder: ($, robots) =>
        CollapsedThreadsSearchMoreScenario($, robots),
  );
}
