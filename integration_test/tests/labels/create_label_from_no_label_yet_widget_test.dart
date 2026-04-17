import '../../base/test_base.dart';
import '../../scenarios/labels/create_label_from_no_label_yet_widget_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should create a label from NoLabelYetWidget and show it in the Choose Label modal list',
    scenarioBuilder: ($) => CreateLabelFromNoLabelYetWidgetScenario($),
  );
}
