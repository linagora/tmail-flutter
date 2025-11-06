import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_download_attachment_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_preview_attachment_extension.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension PreviewUploadFileExtension on ComposerController  {
  void previewUploadFile(BuildContext context, UploadTaskId uploadId) {
    final uploadFile = uploadController.getUploadFileId(uploadId);

    if (uploadFile == null || uploadFile.attachment == null) {
      appToast.showToastWarningMessage(
        context,
        AppLocalizations.of(context).noPreviewAvailable,
      );
      return;
    }

    mailboxDashBoardController.previewUploadFile(
      context: context,
      uploadFile: uploadFile,
      isDialogLoadingVisible: true,
      onPreviewOrDownloadAction: (attachment, isPreview) {
        mailboxDashBoardController.downloadAttachment(
          attachment: attachment,
          previewerSupported: isPreview,
        );
      },
    );
  }
}
