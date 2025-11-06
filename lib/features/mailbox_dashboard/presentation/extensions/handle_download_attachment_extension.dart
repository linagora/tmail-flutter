import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/download/domain/model/download_source_view.dart';
import 'package:tmail_ui_user/features/download/presentation/extensions/download_attachment_download_controller_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

extension HandleDownloadAttachmentExtension on MailboxDashBoardController {
  void downloadMessageAsEML({
    required PresentationEmail presentationEmail,
    bool showBottomDownloadProgressBar = false,
  }) =>
      downloadController.downloadMessageAsEML(
        presentationEmail: presentationEmail,
        accountId: accountId.value,
        session: sessionCurrent,
        showBottomDownloadProgressBar: showBottomDownloadProgressBar,
      );

  void downloadAttachment({
    required Attachment attachment,
    bool previewerSupported = false,
    bool showBottomDownloadProgressBar = false,
    DownloadSourceView? sourceView,
  }) =>
      downloadController.downloadAttachment(
        attachment: attachment,
        accountId: accountId.value,
        session: sessionCurrent,
        previewerSupported: previewerSupported,
        showBottomDownloadProgressBar: showBottomDownloadProgressBar,
        sourceView: sourceView,
      );

  void downloadAllAttachments({
    required String outputFileName,
    required EmailId? emailId,
    bool showBottomDownloadProgressBar = false,
  }) =>
      downloadController.downloadAllAttachments(
        outputFileName: outputFileName,
        emailId: emailId,
        accountId: accountId.value,
        session: sessionCurrent,
        showBottomDownloadProgressBar: showBottomDownloadProgressBar,
      );
}
