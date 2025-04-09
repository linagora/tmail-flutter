import '../../base/test_base.dart';
import '../../scenarios/mailbox/long_press_empty_and_recover_trash_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should empty and recover trash by long press mailbox successfully',
    scenarioBuilder: ($) => LongPressEmptyAndRecoverTrashScenario($),
  );
}