import '../../base/base_test_scenario.dart';
import '../../mixin/collapsed_threads_scenario_mixin.dart';
import '../../models/provisioning_threads.dart';

/// Search results on web desktop use the thread list layout, so with thread
/// view on they are collapsed and search-more pages through threads.
class CollapsedThreadsSearchMoreScenario extends BaseTestScenario
    with CollapsedThreadsScenarioMixin {
  const CollapsedThreadsSearchMoreScenario(super.$, super.robots);

  // More threads than one result page, each with replies that a search
  // matches too, so search-more must skip rows of listed threads.
  static const _threadCount = 30;
  static const _repliesPerThread = 3;

  // One word, so the search keyword matches it as a whole token.
  @override
  String get threadSubjectPrefix => 'ctsearchmore';

  @override
  Future<void> runTestLogic() => runWithCollapsedThreads(() async {
        final threads = List.generate(_threadCount, (i) => i + 1);
        await threadProvisioner.provision(ProvisioningThreads(
          subjectPrefix: threadSubjectPrefix,
          threadNumbers: threads,
          repliesPerThread: _repliesPerThread,
          newest: DateTime.now().toUtc().subtract(const Duration(days: 1)),
        ));
        await reloadFolder();

        final searchRobot = robots.searchRobot();
        await searchRobot.enterKeyword(threadSubjectPrefix);
        await searchRobot.tapOnShowAllResultsText();
        await waitForStep('search results listed', () => listedThreads.isNotEmpty);
        await waitForLoadMoreIdle();

        await scrollUntilListStopsGrowing();

        await robots.threadRobot().assertion.expectEachThreadListedOnce(
          threads,
          threadSubjectPrefix,
        );
      });
}
