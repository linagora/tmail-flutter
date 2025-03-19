import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class MailboxMoveEmailScenario extends BaseTestScenario {
  const MailboxMoveEmailScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const templatesSubject = 'email to templates';
    const trashSubject = 'email to trash';

    final threadRobot = ThreadRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);
    final appLocalizations = AppLocalizations();

    await provisionEmail([
      ProvisioningEmail(
        toEmail: email,
        subject: templatesSubject,
        content: ''
      ),
      ProvisioningEmail(
        toEmail: email,
        subject: trashSubject,
        content: '',
      ),
    ]);
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    await threadRobot.longPressEmailWithSubject(templatesSubject);
    await threadRobot.moveEmailToMailboxWithName(appLocalizations.templatesMailboxDisplayName);
    await threadRobot.openMailbox();
    await mailboxMenuRobot.openFolderByName(appLocalizations.templatesMailboxDisplayName);
    await _expectEmailWithSubjectVisible(templatesSubject);
    await threadRobot.openMailbox();
    await mailboxMenuRobot.openFolderByName(appLocalizations.inboxMailboxDisplayName);

    await threadRobot.longPressEmailWithSubject(trashSubject);
    await threadRobot.moveEmailToTrash();
    await threadRobot.openMailbox();
    await mailboxMenuRobot.openFolderByName(appLocalizations.trashMailboxDisplayName);
    await _expectEmailWithSubjectVisible(trashSubject);
  }

  Future<void> _expectEmailWithSubjectVisible(String subject) async {
    await expectViewVisible($(subject));
  }
}
