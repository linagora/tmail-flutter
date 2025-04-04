import '../../../base/test_base.dart';
import '../../../scenarios/email_detailed/copy_email_address_to_clipboard_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see Clipboard SnackBar when open detailed email and tap `Copy email address` button in email address info dialog',
    scenarioBuilder: ($) => CopyEmailAddressToClipboardScenario($),
  );
}