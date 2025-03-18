import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class MailboxCountRealTimeUpdateScenario extends BaseTestScenario {
  const MailboxCountRealTimeUpdateScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const subject = 'mailbox unread realtime update';

    final threadRobot = ThreadRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);

    await provisionEmail([ProvisioningEmail(
      toEmail: email,
      subject: 'dummy email',
      content: '',
    )]);
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    await threadRobot.openMailbox();
    final currentInboxCount = mailboxMenuRobot.getCurrentInboxCount();
    await _expectInboxWithCount(currentInboxCount);

    await provisionEmail([ProvisioningEmail(
      toEmail: email,
      subject: subject,
      content: '',
    )]);
    await $.pumpAndSettle(duration: const Duration(seconds: 2));
    await _expectInboxWithCount(currentInboxCount + 1);

    await simulateUpdateFlagsOfEmailsWithSubjectsFromOutsideCurrentClient(
      subjects: [subject],
      isRead: true,
    );
    await $.pumpAndSettle(duration: const Duration(seconds: 5));
    await _expectInboxWithCount(currentInboxCount);
  }

  Future<void> _expectInboxWithCount(int currentInboxCount) async {
    await expectViewVisible($(currentInboxCount.toString()));
  }
}
