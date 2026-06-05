import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/bottom_popup/confirmation_dialog_action_sheet_builder.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_manager.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class EmptyTrashConfirmationDialog {
  static void show(
    BuildContext context, {
    required ResponsiveUtils responsiveUtils,
    required VoidCallback onConfirm,
  }) {
    final appLocalizations = AppLocalizations.of(context);
    if (responsiveUtils.isScreenWithShortestSide(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
            ..messageText(appLocalizations.empty_trash_dialog_message)
            ..onCancelAction(appLocalizations.cancel, popBack)
            ..onConfirmAction(appLocalizations.delete, () {
              popBack();
              onConfirm();
            }))
          .show();
    } else {
      MessageDialogActionManager().showConfirmDialogAction(
        key: const Key('confirm_dialog_empty_trash'),
        context,
        title: appLocalizations.emptyTrash,
        appLocalizations.empty_trash_dialog_message,
        appLocalizations.delete,
        cancelTitle: appLocalizations.cancel,
        onCloseButtonAction: popBack,
        onConfirmAction: () {
          popBack();
          onConfirm();
        },
      );
    }
  }
}
