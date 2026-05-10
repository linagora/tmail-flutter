
import 'package:core/utils/list_utils.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/email_action_type.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/email_attachment_classifier_extension.dart';
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

    final resolved = _resolveAttachmentsFromArguments(arguments);
    initAttachmentsAndInlineImages(
      attachments: resolved.attachments,
      inlineImages: resolved.inlineImages,
    );
  }

  ({List<Attachment>? attachments, List<Attachment>? inlineImages})
      _resolveAttachmentsFromArguments(ComposerArguments arguments) {
    if (currentEmailActionType == EmailActionType.editSendingEmail) {
      final email = arguments.sendingEmail?.email;
      if (email == null) return (attachments: null, inlineImages: null);
      final classified = email.classifyAttachments();
      return (
        attachments: classified.attachments,
        inlineImages: classified.inlineImages,
      );
    }
    if (_shouldPreserveAttachments) {
      return (
        attachments: arguments.attachments,
        inlineImages: arguments.inlineImages,
      );
    }
    return (attachments: null, inlineImages: null);
  }

  bool get _shouldPreserveAttachments => const {
    EmailActionType.reply,
    EmailActionType.replyToList,
    EmailActionType.replyAll,
    EmailActionType.forward,
    EmailActionType.reopenComposerBrowser,
    EmailActionType.restoreComposerFromPersistentCache,
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