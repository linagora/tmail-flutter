import '../base/base_test_scenario.dart';
import '../models/provisioning_email.dart';

class DownloadAllAttachmentsScenario extends BaseTestScenario {
  const DownloadAllAttachmentsScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    const subject = 'download all attachments subject';
    final List<String> attachmentContents = ['file1', 'file2', 'file3'];
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');

    final commonRobot = robots.commonRobot();
    final threadRobot = robots.threadRobot();
    final emailRobot = robots.emailRobot();

    // Prepare attachment files
    final fileInfos = await Future.wait(
      attachmentContents.map(commonRobot.prepareTxtFile),
    );

    // Provisioning email
    await commonRobot.provisionEmail(
      [ProvisioningEmail(
        toEmail: email,
        subject: subject,
        content: 'download all attachments content',
        fileInfos: fileInfos,
      )],
      requestReadReceipt: false,
    );

    await threadRobot.openEmailWithSubject(subject);
    await emailRobot.tapDownloadAllButton();
    await emailRobot.expectDownloadSaveDialogVisible();
  }
}