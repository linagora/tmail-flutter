import '../../base/test_base.dart';
import '../../scenarios/email_detailed/delete_thread_to_trash_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should see toast message success when open detailed email and delete thread successfully',
    scenarioBuilder: ($) => DeleteThreadToTrashScenario($),
  );
}
