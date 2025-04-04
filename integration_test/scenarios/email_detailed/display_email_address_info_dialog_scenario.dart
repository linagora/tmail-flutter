
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/email_address_dialog_robot.dart';
import '../../robots/email_robot.dart';
import '../../robots/thread_robot.dart';

class DisplayEmailAddressInfoDialogScenario extends BaseTestScenario {

  const DisplayEmailAddressInfoDialogScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const subject = 'Email address info dialog';
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
    await _expectEmailAddressInfoDialogVisible(appLocalizations);

    await emailAddressDialogRobot.tapCloseDialogButton();
    await $.pumpAndSettle();

    await emailRobot.tapRecipientEmailAddress(emailUser);
    await $.pumpAndSettle();

    await _expectEmailAddressInfoDialogVisible(appLocalizations);
  }

  Future<void> _expectEmailAddressInfoDialogVisible(
    AppLocalizations appLocalizations,
  ) async {
    await expectViewVisible($(appLocalizations.copy_email_address));
    await expectViewVisible($(appLocalizations.quickCreatingRule));
    await expectViewVisible($(appLocalizations.compose_email));
  }
}