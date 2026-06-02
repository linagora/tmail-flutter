import 'package:core/presentation/views/bottom_popup/confirmation_dialog_action_sheet_builder.dart';
import 'package:flutter/material.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_manager.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension ExecuteEmptyTrashExtension on MailboxDashBoardController {
  void requestEmptyTrash(BuildContext context, PresentationMailbox trashMailbox) {
    final appLocalizations = AppLocalizations.of(context);

    if (responsiveUtils.isScreenWithShortestSide(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
        ..messageText(appLocalizations.empty_trash_dialog_message)
        ..onCancelAction(appLocalizations.cancel, popBack)
        ..onConfirmAction(
          appLocalizations.delete,
          () {
            popBack();
            emptyTrashFolderAction(trashMailbox: trashMailbox);
          },
        ))
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
          emptyTrashFolderAction(trashMailbox: trashMailbox);
        },
      );
    }
  }
}
