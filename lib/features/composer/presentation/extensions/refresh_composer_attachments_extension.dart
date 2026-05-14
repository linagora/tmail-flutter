import 'package:core/utils/app_logger.dart';
import 'package:model/email/attachment.dart';
import 'package:model/extensions/list_attachment_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';

extension RefreshComposerAttachmentsExtension on ComposerController {
  void autoRefreshAllAttachments(
    List<Attachment> attachments,
    List<Attachment> htmlBodyAttachments,
  ) {
    final regularAttachments = attachments.getListAttachmentsDisplayedOutside(htmlBodyAttachments);
    final inlineAttachments = attachments.listAttachmentsDisplayedInContent;
    // If server returned no attachments but the composer still shows attachments,
    // Email/get likely fell back to the Set response which lacks attachment data.
    // Skip the refresh to avoid clearing the UI.
    // Use current upload state (not initialAttachments) so removing all attachments
    // before saving correctly updates initialAttachments to empty.
    if (regularAttachments.isEmpty &&
        inlineAttachments.isEmpty &&
        (uploadController.attachmentsUploaded.isNotEmpty ||
            uploadController.inlineAttachmentsUploaded.isNotEmpty)) {
      log('RefreshComposerAttachmentsExtension::autoRefreshAllAttachments: skipping — empty server response with non-empty composer state');
      return;
    }

    initialAttachments = regularAttachments;
    uploadController.refreshAllAttachments(attachments, htmlBodyAttachments);
  }
}
