
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/email_robot.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class DeleteEmailScenario extends BaseTestScenario {

  const DeleteEmailScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const subject = 'Delete email';
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');
    final threadRobot = ThreadRobot($);
    final emailRobot = EmailRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);
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

    await emailRobot.tapEmailDetailedDeleteEmailButton();
    await $.pumpAndSettle(duration: const Duration(seconds: 3));

    _expectEmailViewInvisible();

    await threadRobot.openMailbox();
    await mailboxMenuRobot.openFolderByName(appLocalizations.trashMailboxDisplayName);
    await _expectEmailWithSubjectInDestinationFolderVisible(subject);
  }

  void _expectEmailViewInvisible() {
    expect($(EmailView).visible, isFalse);
  }

  Future<void> _expectEmailWithSubjectInDestinationFolderVisible(String subject) async {
    await expectViewVisible($(subject));
  }
}