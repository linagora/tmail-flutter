import '../../base/test_base.dart';
import '../../scenarios/labels/create_new_a_tag_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should show toast success when create new a label successfully',
    scenarioBuilder: ($) => CreateNewATagScenario($),
  );
}
