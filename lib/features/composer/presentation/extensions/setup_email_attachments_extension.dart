
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
    if (currentEmailActionType == EmailActionType.composeFromFileShared) {
      final sharedFiles = arguments.listSharedMediaFile;
      if (sharedFiles != null && sharedFiles.isNotEmpty) {
        _uploadAttachmentFromFileShare(sharedFiles);
      }
      return;
    }

    initAttachmentsAndInlineImages(
      attachments: _getAttachmentsFromArguments(arguments),
      inlineImages: _getInlineImagesFromArguments(arguments),
    );
  }

  List<Attachment>? _getAttachmentsFromArguments(ComposerArguments arguments) {
    if (currentEmailActionType == EmailActionType.editSendingEmail) {
      final sendingEmail = arguments.sendingEmail;
      if (sendingEmail == null) return null;
      return sendingEmail.email.allAttachments.getListAttachmentsDisplayedOutside(
        sendingEmail.email.htmlBodyAttachments,
      );
    }
    if (_shouldPreserveAttachments) return arguments.attachments;
    return null;
  }

  List<Attachment>? _getInlineImagesFromArguments(ComposerArguments arguments) {
    if (currentEmailActionType == EmailActionType.editSendingEmail) {
      final sendingEmail = arguments.sendingEmail;
      if (sendingEmail == null) return null;
      return sendingEmail.email.allAttachments.listAttachmentsDisplayedInContent;
    }
    if (_shouldPreserveAttachments) return arguments.inlineImages;
    return null;
  }

  bool get _shouldPreserveAttachments => const {
    EmailActionType.reply,
    EmailActionType.replyToList,
    EmailActionType.replyAll,
    EmailActionType.forward,
    EmailActionType.reopenComposerBrowser,
  }.contains(currentEmailActionType);

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