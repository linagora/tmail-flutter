import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class ChangeEmailFlagScenario extends BaseTestScenario {
  const ChangeEmailFlagScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const readSubject = 'mark as read';
    const starSubject = 'mark as star';
    const spamSubject = 'mark as spam';

    final threadRobot = ThreadRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);

    await provisionEmail([
      ProvisioningEmail(toEmail: email, subject: readSubject, content: ''),
      ProvisioningEmail(toEmail: email, subject: starSubject, content: ''),
      ProvisioningEmail(toEmail: email, subject: spamSubject, content: ''),
    ]);
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    await threadRobot.longPressEmailWithSubject(readSubject);
    await threadRobot.selectToggleRead();
    await _expectEmailWithSubjectIsRead(readSubject);

    await threadRobot.longPressEmailWithSubject(starSubject);
    await threadRobot.selectToggleStar();
    await _expectEmailWithSubjectIsStarred(starSubject);

    await threadRobot.longPressEmailWithSubject(spamSubject);
    await threadRobot.selectToggleSpam();
    await threadRobot.openMailbox();
    await mailboxMenuRobot.openFolderByName(
      AppLocalizations().spamMailboxDisplayName,
    );
    await _expectEmailWithSubjectExist(spamSubject);
  }

  Future<void> _expectEmailWithSubjectIsRead(String subject) async {
    await expectViewVisible($(EmailTileBuilder).which<EmailTileBuilder>(
      (widget) => widget.presentationEmail.subject == subject
        && widget.presentationEmail.hasRead
    ));
  }

  Future<void> _expectEmailWithSubjectIsStarred(String subject) async {
    await expectViewVisible($(EmailTileBuilder).which<EmailTileBuilder>(
      (widget) => widget.presentationEmail.subject == subject
        && widget.presentationEmail.hasStarred
    ));
  }

  Future<void> _expectEmailWithSubjectExist(String subject) async {
    await expectViewVisible($(EmailTileBuilder).which<EmailTileBuilder>(
      (widget) => widget.presentationEmail.subject == subject
    ));
  }
}
