import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_manager.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MaxSizeAttachmentsDialogPresenter {
  const MaxSizeAttachmentsDialogPresenter._();

  static Future<void> show({
    required BuildContext context,
    required num? maxSizeAttachmentsPerEmail,
  }) {
    final maxSize = filesize(maxSizeAttachmentsPerEmail ?? 0, 0);
    return MessageDialogActionManager().showConfirmDialogAction(
      context,
      AppLocalizations.of(context).message_dialog_upload_attachments_exceeds_maximum_size(maxSize),
      AppLocalizations.of(context).got_it,
      title: AppLocalizations.of(context).maximum_files_size,
      hasCancelButton: false);
  }
}
