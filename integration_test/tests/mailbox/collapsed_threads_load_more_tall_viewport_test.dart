import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/mailbox/collapsed_threads_load_more_tall_viewport_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should fill a tall screen with each thread once when thread '
        'view is on and the folder loads more on its own',
    // Threads are collapsed only on web, where emails can be queried from the server.
    tags: [TestTags.web],
    scenarioBuilder: ($, robots) =>
        CollapsedThreadsLoadMoreTallViewportScenario($, robots),
  );
}
