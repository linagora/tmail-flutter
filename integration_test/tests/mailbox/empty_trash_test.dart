import '../../base/test_base.dart';
import '../../scenarios/mailbox/empty_trash_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should empty view and hide empty trash banner when empty trash successfully',
    scenarioBuilder: ($) => EmptyTrashScenario($),
  );
}