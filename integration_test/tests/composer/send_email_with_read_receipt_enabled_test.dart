import '../../base/test_base.dart';
import '../../scenarios/send_email_with_read_receipt_enabled_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see read receipt dialog when user toggle read receipt and open read receipt email',
    scenarioBuilder: ($) => SendEmailWithReadReceiptEnabledScenario($),
  );
}