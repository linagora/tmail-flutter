import '../../base/test_base.dart';
import '../../scenarios/mailbox/empty_and_recover_trash_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should empty and recover trash successfully',
    scenarioBuilder: ($) => EmptyAndRecoverTrashScenario($),
  );
}