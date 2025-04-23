import '../../base/test_base.dart';
import '../../scenarios/composer/update_draft_email_with_message_success_toast_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see message success toast when edit draft email and save draft successfully',
    scenarioBuilder: ($) => UpdateDraftEmailWithMessageSuccessToastScenario($),
  );
}