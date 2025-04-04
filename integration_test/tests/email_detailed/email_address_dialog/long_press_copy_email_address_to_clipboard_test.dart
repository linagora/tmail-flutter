import '../../../base/test_base.dart';
import '../../../scenarios/email_detailed/long_press_copy_email_address_to_clipboard_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see Clipboard SnackBar when open detailed email and long press email address of sender or recipient',
    scenarioBuilder: ($) => LongPressCopyEmailAddressToClipboardScenario($),
  );
}