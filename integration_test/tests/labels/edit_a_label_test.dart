import '../../base/test_base.dart';
import '../../scenarios/labels/edit_a_tag_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should update label display name when edit a label successfully',
    scenarioBuilder: ($) => EditATagScenario($),
  );
}
