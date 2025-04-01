
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/destination_picker_robot.dart';
import '../../robots/email_robot.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class MoveEmailToFolderScenario extends BaseTestScenario {

  const MoveEmailToFolderScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const subject = 'Move email to folder';
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');
    final threadRobot = ThreadRobot($);
    final emailRobot = EmailRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);
    final destinationPickerRobot = DestinationPickerRobot($);
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

    await emailRobot.tapEmailDetailedMoveEmailButton();
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    await destinationPickerRobot.selectFolderByName(appLocalizations.templatesMailboxDisplayName);
    await $.pumpAndSettle(duration: const Duration(seconds: 3));
    _expectEmailWithSubjectInCurrentFolderInvisible(subject);

    await threadRobot.openMailbox();
    await mailboxMenuRobot.openFolderByName(appLocalizations.templatesMailboxDisplayName);
    await _expectEmailWithSubjectInDestinationFolderVisible(subject);
  }

  void _expectEmailWithSubjectInCurrentFolderInvisible(String subject) {
    expect($(subject), findsNothing);
  }

  Future<void> _expectEmailWithSubjectInDestinationFolderVisible(String subject) async {
    await expectViewVisible($(subject));
  }
}