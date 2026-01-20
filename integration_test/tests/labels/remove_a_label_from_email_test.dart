import '../../base/test_base.dart';
import '../../scenarios/labels/remove_a_label_from_email_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should remove tag on email subject when clicking on the cross on a tag in the opened mail',
    scenarioBuilder: ($) => RemoveALabelFromEmailScenario($),
  );
}
