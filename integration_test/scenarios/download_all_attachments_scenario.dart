import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../base/base_test_scenario.dart';
import '../models/provisioning_email.dart';
import '../robots/email_robot.dart';
import '../robots/thread_robot.dart';

class DownloadAllAttachmentsScenario extends BaseTestScenario {

  const DownloadAllAttachmentsScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const subject = 'download all attachments subject';
    final List<String> attachmentContents = ['file1', 'file2', 'file3'];
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');

    final threadRobot = ThreadRobot($);
    final emailRobot = EmailRobot($);

    // Prepare attachment files
    final attachmentFiles = await Future.wait(
      attachmentContents.map(
        (attachmentContent) => preparingTxtFile(attachmentContent),
      ),
    );

    // Provisioning email
    await provisionEmail(
      [ProvisioningEmail(
        toEmail: email,
        subject: subject,
        content: 'download all attachments content',
        attachmentPaths: attachmentFiles.map((file) => file.path).toList(),
      )],
      requestReadReceipt: false,
    );
    await $.pumpAndSettle();

    await threadRobot.openEmailWithSubject(subject);
    await $.pumpAndSettle();
    await emailRobot.tapDownloadAllButton();
    await _expectNativeSaveButtonVisible();
  }

  Future<void> _expectNativeSaveButtonVisible() async {
    await expectLater($.native.tap(Selector(text: 'SAVE')), completes);
  }
}