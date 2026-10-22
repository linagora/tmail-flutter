import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/mailbox/collapsed_threads_load_more_after_refresh_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should list every thread once with thread view on after '
        'pull-to-refresh',
    tags: [TestTags.web],
    scenarioBuilder: ($, robots) => CollapsedThreadsLoadMoreAfterRefreshScenario(
      $,
      robots,
      gesture: CollapsedRefreshGesture.pullToRefresh,
    ),
  );
}
