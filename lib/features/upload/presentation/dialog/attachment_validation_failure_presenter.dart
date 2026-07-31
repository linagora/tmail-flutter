import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_failure.dart';
import 'package:tmail_ui_user/features/upload/presentation/dialog/max_size_attachments_dialog_presenter.dart';

class AttachmentValidationFailurePresenter {
  const AttachmentValidationFailurePresenter._();

  static Future<void> present(BuildContext context, AttachmentUploadFailure failure) {
    switch (failure) {
      case MaxEmailAttachmentSizeExceeded(:final maximumBytes):
        return MaxSizeAttachmentsDialogPresenter.show(
          context: context,
          maxSizeAttachmentsPerEmail: maximumBytes);
    }
  }
}
