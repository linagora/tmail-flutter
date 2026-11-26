import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/delegation/close_dialog_without_delegation_tab_focus_ring_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should not show a focus ring on the delegation tabs when a dialog is closed with the mouse',
    scenarioBuilder: ($, robots) =>
        CloseDialogWithoutDelegationTabFocusRingScenario($, robots),
    // Mobile uses touch highlight mode, which never paints the focus ring.
    tags: [TestTags.web],
  );
}
