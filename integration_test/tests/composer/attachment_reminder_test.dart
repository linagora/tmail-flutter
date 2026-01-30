import '../../base/test_base.dart';
import '../../scenarios/composer/attachment_reminder_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should not see attachment reminder when send email with attachment keyword in signature',
    scenarioBuilder: ($) => AttachmentReminderScenario($),
  );
}
