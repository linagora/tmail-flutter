import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_prompt.dart';
import 'package:tmail_ui_user/features/upload/presentation/dialog/upload_size_warning_dialog_presenter.dart';

class AttachmentConfirmationPresenter {
  const AttachmentConfirmationPresenter._();

  static Future<bool> ask(BuildContext context, AttachmentUploadPrompt prompt) async {
    var confirmed = false;
    switch (prompt) {
      case LargeRegularAttachmentWarning():
        await UploadSizeWarningDialogPresenter.showExceededWarningSize(
          context: context,
          confirmAction: () => confirmed = true);
    }
    return confirmed;
  }
}
