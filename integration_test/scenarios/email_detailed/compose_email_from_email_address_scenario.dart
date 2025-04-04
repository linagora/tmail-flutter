
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_composer_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/composer_robot.dart';
import '../../robots/email_address_dialog_robot.dart';
import '../../robots/email_robot.dart';
import '../../robots/thread_robot.dart';

class ComposeEmailFromEmailAddressScenario extends BaseTestScenario {

  const ComposeEmailFromEmailAddressScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const subject = 'Compose email from email address';
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');
    final threadRobot = ThreadRobot($);
    final emailRobot = EmailRobot($);
    final emailAddressDialogRobot = EmailAddressDialogRobot($);
    final composerRobot = ComposerRobot($);
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

    await emailAddressDialogRobot.tapComposeEmailButton(appLocalizations);
    await _expectComposerViewVisible();

    await composerRobot.grantContactPermission();

    await _expectToFieldContainListEmailAddressCorrectly(emailUser);
  }

  Future<void> _expectComposerViewVisible() async {
    await expectViewVisible($(ComposerView));
  }

  Future<void> _expectToFieldContainListEmailAddressCorrectly(String emailAddress) async {
    expect(
      $(RecipientComposerWidget).which<RecipientComposerWidget>((widget) =>
      widget.prefix == PrefixEmailAddress.to &&
          isMatchingEmailList(widget.listEmailAddress, {emailAddress})
      ).visible,
      isTrue,
    );
  }
}