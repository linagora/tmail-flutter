import 'package:flutter_test/flutter_test.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/thread_robot.dart';

class SwitchMailboxScenario extends BaseTestScenario {
  const SwitchMailboxScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const toEmail = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const sentEmailSubject = 'sent subject';
    const trashEmailSubject = 'trash subject';

    final threadRobot = ThreadRobot($);
    final appLocalizations = AppLocalizations();

    await provisionEmail(
      [ProvisioningEmail(
        toEmail: toEmail,
        subject: sentEmailSubject,
        content: '',
      )],
    );
    await provisionEmail(
      [ProvisioningEmail(
        toEmail: toEmail,
        subject: trashEmailSubject,
        content: '',
      )],
      sentLocation: PresentationMailbox.roleTrash,
    );

    await threadRobot.openMailbox();
    await threadRobot.tapOnMailboxWithName(appLocalizations.sentMailboxDisplayName);
    await _expectEmailWithSubjectVisible(sentEmailSubject);

    await threadRobot.openMailbox();
    await threadRobot.tapOnMailboxWithName(appLocalizations.trashMailboxDisplayName);
    await _expectEmailWithSubjectVisible(trashEmailSubject);
  }
  
  Future<void> _expectEmailWithSubjectVisible(String subject) async {
    await $.pumpAndSettle(duration: const Duration(seconds: 2));
    expect($(subject), findsOneWidget);
  }
}