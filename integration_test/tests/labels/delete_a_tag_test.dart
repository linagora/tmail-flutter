import '../../base/test_base.dart';
import '../../scenarios/labels/delete_a_tag_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should delete label in label list when delete a label successfully',
    scenarioBuilder: ($) => DeleteATagScenario($),
  );
}
