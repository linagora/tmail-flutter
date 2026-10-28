import '../../base/base_test_scenario.dart';
import '../../mixin/collapsed_threads_scenario_mixin.dart';
import '../../models/provisioning_threads.dart';

class CollapsedThreadsLoadMoreScenario extends BaseTestScenario
    with CollapsedThreadsScenarioMixin {
  const CollapsedThreadsLoadMoreScenario(super.$, super.robots);

  static const _threadCount = 9;

  @override
  String get threadSubjectPrefix => 'ct-short-page';

  @override
  Future<void> runTestLogic() => runWithCollapsedThreads(() async {
        final threads = List.generate(_threadCount, (i) => i + 1);
        await threadProvisioner.provision(ProvisioningThreads(
          subjectPrefix: threadSubjectPrefix,
          threadNumbers: threads,
          repliesPerThread: 5,
          newest: DateTime.now().toUtc().subtract(const Duration(days: 1)),
        ));

        await reloadFolder();

        await robots.threadRobot().assertion.expectThreadsListedOnce(
          threads,
          threadSubjectPrefix,
        );
      });
}
