import 'package:flutter_test/flutter_test.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/thread_robot.dart';

class QuickFilterScenario extends BaseTestScenario {
  const QuickFilterScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    final unreadEmail = ProvisioningEmail(
      toEmail: email,
      subject: 'quick filter unread email',
      content: '',
    );
    final readEmail = ProvisioningEmail(
      toEmail: email,
      subject: 'quick filter read email',
      content: '',
    );
    final starredEmail = ProvisioningEmail(
      toEmail: email,
      subject: 'quick filter starred email',
      content: '',
    );
    final file = await preparingTxtFile('some content');
    final attachmentEmail = ProvisioningEmail(
      toEmail: email,
      subject: 'quick filter attachment email',
      content: '',
      attachmentPaths: [file.path],
    );

    final threadRobot = ThreadRobot($);

    await provisionEmail([
      unreadEmail,
      readEmail,
      starredEmail,
      attachmentEmail,
    ]);
    await $.pumpAndSettle(); 

    await simulateUpdateFlagsOfEmailsWithSubjectsFromOutsideCurrentClient(
      subjects: ['quick filter read email'],
      isRead: true,
    );
    await simulateUpdateFlagsOfEmailsWithSubjectsFromOutsideCurrentClient(
      subjects: ['quick filter starred email'],
      isStar: true,
    );

    await threadRobot.openQuickFilter();
    await threadRobot.selectAttachmentFilter();
    await _expectEmailWithAttachmentVisible();

    await threadRobot.openQuickFilter();
    await threadRobot.selectUnreadFilter();
    await _expectUnreadEmailVisible();

    await threadRobot.openQuickFilter();
    await threadRobot.selectStarredFilter();
    await _expectStarredEmailVisible();
  }
  
  Future<void> _expectEmailWithAttachmentVisible() async {
    await expectViewVisible($('quick filter attachment email'));
  }

  Future<void> _expectUnreadEmailVisible() async {
    await expectViewVisible($('quick filter unread email'));
  }
  
  Future<void> _expectStarredEmailVisible() async {
    await expectViewVisible($('quick filter starred email'));
  }
}