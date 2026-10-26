import '../../base/base_test_scenario.dart';
import '../../mixin/collapsed_threads_scenario_mixin.dart';
import '../../models/provisioning_threads.dart';
import '../../utils/test_timeouts.dart';

/// On a screen taller than one page, the list loads more on its own until
/// it fills the screen, without any scroll.
class CollapsedThreadsLoadMoreTallViewportScenario extends BaseTestScenario
    with CollapsedThreadsScenarioMixin {
  const CollapsedThreadsLoadMoreTallViewportScenario(super.$, super.robots);

  static const _pageSize = 20;
  static const _threadCount = 70;

  @override
  String get threadSubjectPrefix => 'ct-tall-viewport';

  @override
  Future<void> runTestLogic() => runWithCollapsedThreads(() async {
        final viewport = robots.threadRobot().viewport;
        if (viewport == null) {
          throw StateError('Window resizing is not wired on this platform');
        }
        final threads = List.generate(_threadCount, (i) => i + 1);
        await threadProvisioner.provision(ProvisioningThreads(
          subjectPrefix: threadSubjectPrefix,
          threadNumbers: threads,
          repliesPerThread: 2,
          newest: DateTime.now().toUtc().subtract(const Duration(days: 1)),
        ));

        await viewport.withTallViewport(() async {
          await reloadFolder();
          await waitForStep(
            'list filled the tall viewport',
            () => listedThreads.length > _pageSize,
            timeout: TestTimeouts.long,
          );
          await waitForLoadMoreIdle();

          final assertion = robots.threadRobot().assertion;
          await assertion.expectListedThreadCountAbove(
            _pageSize,
            threadSubjectPrefix,
          );
          await assertion.expectListedThreadsArePrefixOf(
            threads,
            threadSubjectPrefix,
          );

          await scrollUntilListStopsGrowing();
          await assertion.expectThreadsListedOnce(threads, threadSubjectPrefix);
        });
      });
}
