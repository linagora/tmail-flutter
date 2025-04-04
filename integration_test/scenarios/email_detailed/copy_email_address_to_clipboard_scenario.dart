
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/email_address_dialog_robot.dart';
import '../../robots/email_robot.dart';
import '../../robots/thread_robot.dart';

class CopyEmailAddressToClipboardScenario extends BaseTestScenario {

  const CopyEmailAddressToClipboardScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const subject = 'Copy email address to clipboard';
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');
    final threadRobot = ThreadRobot($);
    final emailRobot = EmailRobot($);
    final emailAddressDialogRobot = EmailAddressDialogRobot($);
    final appLocalizations = AppLocalizations();

    await provisionEmail(
      [
        ProvisioningEmail(
          toEmail: emailUser,
          subject: subject,
          content: subject,
        ),
      ],
      requestReadReceipt: false,
    );
    await $.pumpAndSettle();

    await threadRobot.openEmailWithSubject(subject);
    await $.pumpAndSettle();

    await emailRobot.tapSenderEmailAddress(emailUser);
    await $.pumpAndSettle();

    await emailAddressDialogRobot.tapCopyEmailAddressButton(appLocalizations);
    await _expectSnackBarVisible(appLocalizations);
  }

  Future<void> _expectSnackBarVisible(
    AppLocalizations appLocalizations,
  ) async {
    await expectViewVisible($(appLocalizations.email_address_copied_to_clipboard));
  }
}