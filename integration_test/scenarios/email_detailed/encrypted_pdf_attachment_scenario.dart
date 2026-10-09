import 'dart:convert';

import 'package:model/upload/file_info.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../resources/encrypted_pdf_resources.dart';
import '../../robots/abstract/abstract_email_pdf_preview_robot.dart';

abstract class EncryptedPdfAttachmentScenario extends BaseTestScenario {
  const EncryptedPdfAttachmentScenario(super.$, super.robots);

  /// Receives an email with a password-protected PDF, opens it and waits for
  /// the first password prompt.
  Future<AbstractEmailPdfPreviewRobot> openEncryptedPdfAttachment(
    String subject,
  ) async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    final pdfPreviewRobot = robots.emailRobot().pdfPreview;

    await robots.commonRobot().provisionEmail(
      [
        ProvisioningEmail(
          toEmail: email,
          subject: subject,
          content: subject,
          fileInfos: [
            FileInfo.fromBytes(
              bytes: base64Decode(EncryptedPdfResources.base64),
              name: EncryptedPdfResources.fileName,
              type: 'application/pdf',
            ),
          ],
        ),
      ],
      requestReadReceipt: false,
    );
    await $.pumpAndSettle();

    await robots.threadRobot().openEmailWithSubject(subject);
    await pdfPreviewRobot.openAttachment();
    await pdfPreviewRobot.assertion.expectPasswordPrompt(
      showsIncorrectPassword: false,
    );
    return pdfPreviewRobot;
  }
}
