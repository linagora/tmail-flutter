import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_manager.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class UploadSizeWarningDialogPresenter {
  const UploadSizeWarningDialogPresenter._();

  static Future<void> showExceededWarningSize({
    required BuildContext context,
    VoidCallback? confirmAction,
    VoidCallback? cancelAction,
  }) {
    final appLocalizations = AppLocalizations.of(context);
    return MessageDialogActionManager().showConfirmDialogAction(
      context,
      title: '',
      appLocalizations.warningMessageWhenExceedGenerallySizeInComposer,
      appLocalizations.continueAction,
      cancelTitle: appLocalizations.cancel,
      alignCenter: true,
      outsideDismissible: false,
      onConfirmAction: confirmAction,
      onCancelAction: cancelAction,
      onCloseButtonAction: () {
        popBack();
        cancelAction?.call();
      },
    );
  }
}
