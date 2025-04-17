import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_attachments_widget.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/composer_robot.dart';
import '../../robots/email_robot.dart';
import '../../robots/thread_robot.dart';

class ForwardingEmailLostAttachmentsScenario extends BaseTestScenario {

  const ForwardingEmailLostAttachmentsScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const subject = 'Forwarding email lost attachments';
    final List<String> attachmentContents = ['file1', 'file2'];
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');

    final threadRobot = ThreadRobot($);
    final emailRobot = EmailRobot($);
    final composerRobot = ComposerRobot($);
    final imagePaths = ImagePaths();

    // Prepare attachment files
    final attachmentFiles = await Future.wait(
      attachmentContents.map(
        (attachmentContent) => preparingTxtFile(attachmentContent),
      ),
    );

    // Provisioning email
    await provisionEmail(
      [
        ProvisioningEmail(
          toEmail: emailUser,
          subject: subject,
          content: subject,
          attachmentPaths: attachmentFiles.map((file) => file.path).toList(),
        ),
      ],
      requestReadReceipt: false,
    );
    await $.pumpAndSettle();

    await threadRobot.openEmailWithSubject(subject);
    await $.pumpAndSettle();
    await _expectForwardEmailButtonVisible();
    await _expectAttachmentListVisible();

    await emailRobot.onTapForwardEmail();
    await _expectComposerViewVisible();

    await composerRobot.grantContactPermission();
    await composerRobot.addRecipientIntoField(
      prefixEmailAddress: PrefixEmailAddress.to,
      email: emailUser,
    );
    await composerRobot.sendEmail(imagePaths);
    await $.pumpAndSettle(duration: const Duration(seconds: 3));

    await _expectAttachmentListVisible();
  }

  Future<void> _expectForwardEmailButtonVisible() async {
    await expectViewVisible($(#forward_email_button));
  }

  Future<void> _expectComposerViewVisible() => expectViewVisible($(ComposerView));

  Future<void> _expectAttachmentListVisible() => expectViewVisible($(EmailAttachmentsWidget));
}