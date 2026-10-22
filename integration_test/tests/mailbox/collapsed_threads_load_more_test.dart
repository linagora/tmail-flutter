import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/mailbox/collapsed_threads_load_more_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should list every thread once when thread view is on '
        'and the folder loads more',
    // Threads are collapsed only on web, where emails can be queried from the server.
    tags: [TestTags.web],
    scenarioBuilder: ($, robots) => CollapsedThreadsLoadMoreScenario($, robots),
  );
}
