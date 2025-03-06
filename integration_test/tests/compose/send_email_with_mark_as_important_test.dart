import '../../base/test_base.dart';
import '../../scenarios/send_email_with_mark_as_important_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see email item has important flag icon when send email with mark as important successfully',
    scenarioBuilder: ($) => SendEmailWithMarkAsImportantScenario($),
  );
}