
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/email_robot.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class ArchiveEmailScenario extends BaseTestScenario {

  const ArchiveEmailScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const subject = 'Archive email';
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
    _expectEmailDetailedMoreButtonVisible();

    await emailRobot.tapEmailDetailedMoreButton();
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    await emailRobot.tapArchiveMessageOptionInContextMenu();
    await $.pumpAndSettle(duration: const Duration(seconds: 3));

    await emailRobot.onTapBackButton();
    await $.pumpAndSettle();

    await threadRobot.openMailbox();
    await mailboxMenuRobot.openFolderByName(appLocalizations.archiveMailboxDisplayName);
    await _expectEmailWithSubjectInArchiveFolderVisible(subject);
  }

  void _expectEmailDetailedMoreButtonVisible() {
    expect($(#email_detailed_more_button), findsOneWidget);
  }

  Future<void> _expectEmailWithSubjectInArchiveFolderVisible(String subject) async {
    await expectViewVisible($(subject));
  }
}