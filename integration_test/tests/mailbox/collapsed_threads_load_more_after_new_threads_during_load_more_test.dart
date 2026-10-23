import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/mailbox/collapsed_threads_load_more_after_changes_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should list every thread once with thread view on when '
        'new threads arrive while the next page loads',
    // Threads are collapsed only on web, where emails can be queried from the server.
    tags: [TestTags.web],
    scenarioBuilder: ($, robots) => CollapsedThreadsLoadMoreAfterChangesScenario(
      $,
      robots,
      change: CollapsedListChange.newThreadsArrivedDuringLoadMore,
    ),
  );
}
