import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../base/base_scenario.dart';
import '../models/provisioning_email.dart';
import '../robots/email_robot.dart';
import '../robots/thread_robot.dart';
import '../utils/scenario_utils_mixin.dart';
import 'login_with_basic_auth_scenario.dart';

class DownloadAllAttachmentsScenario extends BaseScenario with ScenarioUtilsMixin {
  DownloadAllAttachmentsScenario(
    super.$, {
    required this.loginWithBasicAuthScenario,
    required this.attachmentContents,
  });

  final LoginWithBasicAuthScenario loginWithBasicAuthScenario;
  final List<String> attachmentContents;

  @override
  Future<void> execute() async {
    const subject = 'download all attachments subject';
    final threadRobot = ThreadRobot($);
    final emailRobot = EmailRobot($);

    await loginWithBasicAuthScenario.execute();

    // Prepare attachment files
    final attachmentFiles = await Future.wait(
      attachmentContents.map(
        (attachmentContent) => preparingTxtFile(attachmentContent),
      ),
    );

    // Provisioning email
    await provisionEmail(
      [ProvisioningEmail(
        toEmail: loginWithBasicAuthScenario.email,
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