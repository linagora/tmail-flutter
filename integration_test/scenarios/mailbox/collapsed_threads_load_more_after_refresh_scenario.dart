import '../../base/base_test_scenario.dart';
import '../../mixin/collapsed_threads_scenario_mixin.dart';
import '../../models/provisioning_threads.dart';

enum CollapsedRefreshGesture { pullToRefresh, deepRefresh }

class CollapsedThreadsLoadMoreAfterRefreshScenario extends BaseTestScenario
    with CollapsedThreadsScenarioMixin {
  const CollapsedThreadsLoadMoreAfterRefreshScenario(
    super.$,
    super.robots, {
    required this.gesture,
  });

  final CollapsedRefreshGesture gesture;

  static const _threadCount = 9;
  static const _repliesPerThread = 5;
  static const _sentinelThread = 100;

  @override
  String get threadSubjectPrefix => switch (gesture) {
        CollapsedRefreshGesture.pullToRefresh => 'ct-pull-refresh',
        CollapsedRefreshGesture.deepRefresh => 'ct-deep-refresh',
      };

  @override
  Future<void> runTestLogic() => runWithCollapsedThreads(() async {
        final threads = List.generate(_threadCount, (i) => i + 1);
        final created = await threadProvisioner.provision(ProvisioningThreads(
          subjectPrefix: threadSubjectPrefix,
          threadNumbers: threads,
          repliesPerThread: _repliesPerThread,
          newest: DateTime.now().toUtc().subtract(const Duration(days: 1)),
        ));
        await waitForEmailState(created.state);
        await waitForStep('threads listed', () => listedThreads.isNotEmpty);
        await waitForLoadMoreIdle();

        await threadProvisioner.provision(ProvisioningThreads(
          subjectPrefix: threadSubjectPrefix,
          threadNumbers: const [_sentinelThread],
          repliesPerThread: _repliesPerThread,
          newest: DateTime.now().toUtc(),
        ));

        if (threadController.listEmailController.hasClients) {
          threadController.listEmailController.jumpTo(0);
        }
        await $.pumpAndSettle();
        final subject = dashboardController.emailsInCurrentMailbox.first.subject!;
        final threadRobot = robots.threadRobot();
        if (gesture == CollapsedRefreshGesture.pullToRefresh) {
          await threadRobot.pullToRefreshByEmailSubject(subject);
        } else {
          await threadRobot.deepPullToRefreshByEmailSubject(subject);
        }
        await waitForStep(
          'refresh listed the new thread',
          () => listedThreads.contains(_sentinelThread),
        );
        await waitForLoadMoreIdle();
        await scrollUntilListStopsGrowing();

        await threadRobot.assertion.expectThreadsListedOnce(
          [_sentinelThread, ...threads],
          threadSubjectPrefix,
        );
      });
}
