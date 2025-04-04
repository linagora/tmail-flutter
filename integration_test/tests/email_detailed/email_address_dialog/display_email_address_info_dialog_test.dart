import '../../../base/test_base.dart';
import '../../../scenarios/email_detailed/display_email_address_info_dialog_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see email address info dialog when open detailed email and click email address if sender or recipient',
    scenarioBuilder: ($) => DisplayEmailAddressInfoDialogScenario($),
  );
}