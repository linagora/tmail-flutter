import '../../base/test_base.dart';
import '../../scenarios/send_email_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see success toast when send email successfully',
    scenarioBuilder: ($) => SendEmailScenario($),
  );
}