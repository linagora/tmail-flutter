
import 'package:core/utils/list_utils.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:model/extensions/list_attachment_extension.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/list_shared_media_file_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/list_file_info_extension.dart';

extension SetupEmailAttachmentsExtension on ComposerController {

  void setupEmailAttachments(ComposerArguments arguments) {
    List<Attachment>? attachments;
    List<Attachment>? inlineImages;

    switch(currentEmailActionType) {
      case EmailActionType.editSendingEmail:
        final sendingEmail = arguments.sendingEmail;
        final allAttachments = sendingEmail?.email.allAttachments;
        attachments = allAttachments?.getListAttachmentsDisplayedOutside(
          sendingEmail?.email.htmlBodyAttachments ?? [],
        );
        inlineImages = allAttachments?.listAttachmentsDisplayedInContent;
        break;
      case EmailActionType.composeFromFileShared:
        _uploadAttachmentFromFileShare(arguments.listSharedMediaFile!);
        break;
      case EmailActionType.reply:
      case EmailActionType.replyToList:
      case EmailActionType.replyAll:
      case EmailActionType.forward:
        attachments = arguments.attachments;
        inlineImages = arguments.inlineImages;
        break;
      case EmailActionType.reopenComposerBrowser:
        attachments = arguments.attachments;
        inlineImages = arguments.inlineImages;
        break;
      default:
        break;
    }

    initAttachmentsAndInlineImages(
      attachments: attachments,
      inlineImages: inlineImages,
    );
  }

  void _uploadAttachmentFromFileShare(List<SharedMediaFile> listSharedMediaFile) {
    final listFileInfo = listSharedMediaFile.toListFileInfo(isShared: true);

    final tupleListFileInfo = partition(
      listFileInfo,
      (fileInfo) => fileInfo.isInline == true,
    );
    final listAttachments = tupleListFileInfo.value2;

    uploadController.validateTotalSizeAttachmentsBeforeUpload(
      totalSizePreparedFiles: listFileInfo.totalSize,
      totalSizePreparedFilesWithDispositionAttachment: listAttachments.totalSize,
      onValidationSuccess: () => uploadAttachmentsAction(pickedFiles: listFileInfo),
    );
  }
}