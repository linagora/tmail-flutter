import '../../base/test_base.dart';
import '../../scenarios/labels/display_no_label_yet_widget_when_open_choose_label_modal_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should display NoLabelYetWidget when opening Choose Label modal with no labels',
    scenarioBuilder: ($) =>
        DisplayNoLabelYetWidgetWhenOpenChooseLabelModalScenario($),
  );
}
