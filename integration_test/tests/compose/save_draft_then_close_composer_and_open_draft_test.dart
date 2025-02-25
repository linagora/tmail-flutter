import '../../base/test_base.dart';
import '../../scenarios/save_draft_then_close_composer_and_open_draft_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should not see email address in `Reply-To` field when save draft email without `Reply-To` then open draft email',
    scenarioBuilder: ($) => SaveDraftThenCloseComposerAndOpenDraftScenario($),
  );
}