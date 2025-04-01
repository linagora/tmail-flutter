
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/email_robot.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class MarkAsSpamEmailScenario extends BaseTestScenario {

  const MarkAsSpamEmailScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const subject = 'Mark as spam email';
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

    await emailRobot.tapMarkAsSpamOptionInContextMenu();
    await $.pumpAndSettle(duration: const Duration(seconds: 3));
    _expectEmailViewInvisible();

    await threadRobot.openMailbox();
    await mailboxMenuRobot.openFolderByName(appLocalizations.spamMailboxDisplayName);
    await _expectEmailWithSubjectInSpamFolderVisible(subject);
  }

  void _expectEmailDetailedMoreButtonVisible() {
    expect($(#email_detailed_more_button), findsOneWidget);
  }

  void _expectEmailViewInvisible() {
    expect($(EmailView).visible, isFalse);
  }

  Future<void> _expectEmailWithSubjectInSpamFolderVisible(String subject) async {
    await expectViewVisible($(subject));
  }
}