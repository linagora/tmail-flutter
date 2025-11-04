import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class MoveFolderContentScenario extends BaseTestScenario {
  const MoveFolderContentScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const emailSubject = 'Move folder content';

    final threadRobot = ThreadRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);
    final appLocalizations = AppLocalizations();

    final listEmails = List.generate(
      40,
      (_) => ProvisioningEmail(
        toEmail: email,
        subject: emailSubject,
        content: '',
      ),
    );

    await provisionEmail(listEmails);
    await $.pumpAndTrySettle(duration: const Duration(seconds: 2));
    await _expectEmptyViewInVisibleInInboxFolder();

    await threadRobot.openMailbox();
    await $.pumpAndTrySettle();

    await mailboxMenuRobot.longPressMailboxWithName(
      appLocalizations.inboxMailboxDisplayName,
    );
    await mailboxMenuRobot.tapMoveFolderContentAction(
      appLocalizations.templatesMailboxDisplayName,
    );
    await $.pumpAndTrySettle(duration: const Duration(seconds: 3));

    await threadRobot.openMailbox();
    await $.pumpAndTrySettle();
    await mailboxMenuRobot.openFolderByName(
      appLocalizations.templatesMailboxDisplayName,
    );
    await $.pumpAndTrySettle();
    await _expectEmailWithSubjectVisible(emailSubject);

    await threadRobot.openMailbox();
    await $.pumpAndTrySettle();
    await mailboxMenuRobot.openFolderByName(
      appLocalizations.inboxMailboxDisplayName,
    );
    await $.pumpAndTrySettle();
    await _expectEmailWithSubjectInVisible(emailSubject);
    await _expectEmptyViewVisibleInInboxFolder();
  }

  Future<void> _expectEmailWithSubjectVisible(String subject) async {
    await expectViewVisible($(subject));
  }

  Future<void> _expectEmailWithSubjectInVisible(String subject) async {
    await expectViewInvisible($(subject));
  }

  Future<void> _expectEmptyViewVisibleInInboxFolder() async {
    await expectViewVisible($(#empty_thread_view));
  }

  Future<void> _expectEmptyViewInVisibleInInboxFolder() async {
    await expectViewInvisible($(#empty_thread_view));
  }
}
