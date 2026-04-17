import '../../base/test_base.dart';
import '../../scenarios/labels/create_label_from_choose_label_modal_with_existing_labels_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should show "Create a label" button in Choose Label modal when labels exist, and create a new label successfully',
    scenarioBuilder: ($) =>
        CreateLabelFromChooseLabelModalWithExistingLabelsScenario($),
  );
}
