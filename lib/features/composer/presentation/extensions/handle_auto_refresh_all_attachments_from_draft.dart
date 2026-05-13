import 'package:core/utils/app_logger.dart';
import 'package:model/email/attachment.dart';
import 'package:model/extensions/list_attachment_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';

extension HandleRefreshAllAttachmentsFromDraft on ComposerController {
  void autoRefreshAllAttachmentsFromDraft(
    List<Attachment> attachments,
    List<Attachment> htmlBodyAttachments,
  ) {
    final regularAttachments = attachments.getListAttachmentsDisplayedOutside(htmlBodyAttachments);
    final inlineAttachments = attachments.listAttachmentsDisplayedInContent;

    // If server returned no attachments but the composer still holds existing
    // attachment state, Email/get likely fell back to the Set response which
    // lacks attachment data. Skip the refresh to avoid clearing the UI.
    if (regularAttachments.isEmpty &&
        inlineAttachments.isEmpty &&
        (initialAttachments.isNotEmpty ||
            uploadController.inlineAttachmentsUploaded.isNotEmpty)) {
      log('HandleRefreshAllAttachmentsFromDraft::autoRefreshAllAttachmentsFromDraft: skipping — empty server response with non-empty composer state');
      return;
    }

    initialAttachments = regularAttachments;
    uploadController.refreshAllAttachmentsFromDraft(attachments, htmlBodyAttachments);
  }
}
