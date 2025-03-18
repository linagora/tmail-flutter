import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_item_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/email_robot.dart';
import '../../robots/thread_robot.dart';

class ExportAttachmentScenario extends BaseTestScenario {

  const ExportAttachmentScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const subject = 'export attachment';
    const attachmentContent = 'attachment content';
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');
    final threadRobot = ThreadRobot($);
    final emailRobot = EmailRobot($);
    final appLocalizations = AppLocalizations();

    final attachmentFile = await preparingTxtFile(attachmentContent);
    await provisionEmail(
      [
        ProvisioningEmail(
          toEmail: emailUser,
          subject: subject,
          content: subject,
          attachmentPaths: [attachmentFile.path],
        ),
      ],
      requestReadReceipt: false,
    );
    await $.pumpAndSettle();

    await threadRobot.openEmailWithSubject(subject);
    await $.pumpAndSettle();
    _expectAttachmentVisible();

    await emailRobot.onTapAttachmentItem();
    await $.pumpAndSettle();

    await $.native.pressBack();
    _expectEmailViewVisible();
    _expectExportDialogLoadingInvisible(appLocalizations);
  }

  void _expectAttachmentVisible() {
    expect($(AttachmentItemWidget), findsOneWidget);
  }

  void _expectEmailViewVisible() {
    expect($(EmailView).visible, isTrue);
  }

  void _expectExportDialogLoadingInvisible(AppLocalizations appLocalizations) {
    expect($(appLocalizations.preparing_to_export).visible, isFalse);
  }
}