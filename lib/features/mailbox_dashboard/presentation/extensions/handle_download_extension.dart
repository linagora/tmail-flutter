import 'package:model/email/attachment.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

extension HandleDownloadExtension on MailboxDashBoardController {
  void downloadMessageAsEML(PresentationEmail presentationEmail) {
    downloadController.downloadMessageAsEML(
      presentationEmail: presentationEmail,
      accountId: accountId.value,
      session: sessionCurrent,
    );
  }

  void downloadAttachmentForWeb({
    required Attachment attachment,
    bool previewerSupported = false,
  }) {
    downloadController.downloadAttachmentForWeb(
      attachment: attachment,
      accountId: accountId.value,
      session: sessionCurrent,
      previewerSupported: previewerSupported,
    );
  }

  void downloadAllAttachmentsForWeb({
    required String outputFileName,
    PresentationEmail? currentEmail,
  }) {
    downloadController.downloadAllAttachmentsForWeb(
      outputFileName: outputFileName,
      currentEmail: currentEmail,
      accountId: accountId.value,
      session: sessionCurrent,
    );
  }
}
