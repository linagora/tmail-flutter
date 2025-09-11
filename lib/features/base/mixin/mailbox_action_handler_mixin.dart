
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/bottom_popup/confirmation_dialog_action_sheet_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_manager.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

mixin MailboxActionHandlerMixin {

  void openMailboxInNewTabAction(PresentationMailbox mailbox) {
    AppUtils.launchLink(mailbox.mailboxRouteWeb.toString());
  }

  void markAsReadMailboxAction(
    BuildContext context,
    PresentationMailbox presentationMailbox,
    MailboxDashBoardController dashboardController,
    {
      Function(BuildContext)? onCallbackAction
    }
  ) {
    final session = dashboardController.sessionCurrent;
    final accountId = dashboardController.accountId.value;
    final mailboxId = presentationMailbox.id;
    final countEmailsUnread = presentationMailbox.unreadEmails?.value.value ?? 0;
    if (session != null && accountId != null) {
      dashboardController.markAsReadMailbox(
        session,
        accountId,
        mailboxId,
        presentationMailbox.getDisplayName(context),
        countEmailsUnread.toInt()
      );

      onCallbackAction?.call(context);
    }
  }

  void emptyTrashAction(
    BuildContext context,
    PresentationMailbox mailbox,
    MailboxDashBoardController dashboardController
  ) {
    final responsiveUtils = Get.find<ResponsiveUtils>();
    final appToast = Get.find<AppToast>();

    if (responsiveUtils.isScreenWithShortestSide(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
        ..messageText(AppLocalizations.of(context).empty_trash_dialog_message)
        ..onCancelAction(AppLocalizations.of(context).cancel, popBack)
        ..onConfirmAction(AppLocalizations.of(context).delete, () {
            popBack();
            if (mailbox.countTotalEmails > 0) {
              dashboardController.emptyTrashFolderAction(
                trashFolderId: mailbox.id,
                totalEmails: mailbox.countTotalEmails
              );
            } else {
              appToast.showToastWarningMessage(
                context,
                AppLocalizations.of(context).noEmailInYourCurrentFolder
              );
            }
        }))
      .show();
    } else {
      MessageDialogActionManager().showConfirmDialogAction(
        key: const Key('confirm_dialog_empty_trash'),
        context,
        title: AppLocalizations.of(context).emptyTrash,
        AppLocalizations.of(context).empty_trash_dialog_message,
        cancelTitle: AppLocalizations.of(context).cancel,
        AppLocalizations.of(context).delete,
        onCloseButtonAction: popBack,
        onConfirmAction: () {
          popBack();
          if (mailbox.countTotalEmails > 0) {
            dashboardController.emptyTrashFolderAction(
              trashFolderId: mailbox.id,
              totalEmails: mailbox.countTotalEmails
            );
          } else {
            appToast.showToastWarningMessage(
              context,
              AppLocalizations.of(context).noEmailInYourCurrentFolder
            );
          }
        },
      );
    }
  }

  void emptySpamAction(
    BuildContext context,
    PresentationMailbox mailbox,
    MailboxDashBoardController dashboardController
  ) {
    if (dashboardController.isDrawerOpen) {
      dashboardController.closeMailboxMenuDrawer();
    }

    final responsiveUtils = Get.find<ResponsiveUtils>();
    final appToast = Get.find<AppToast>();

    if (responsiveUtils.isScreenWithShortestSide(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
        ..messageText(AppLocalizations.of(context).emptySpamMessageDialog)
        ..onCancelAction(AppLocalizations.of(context).cancel, popBack)
        ..onConfirmAction(AppLocalizations.of(context).delete_all, () {
          popBack();
          if (mailbox.countTotalEmails > 0) {
            dashboardController.emptySpamFolderAction(spamFolderId: mailbox.id, totalEmails: mailbox.countTotalEmails);
          } else {
            appToast.showToastWarningMessage(
              context,
              AppLocalizations.of(context).noEmailInYourCurrentFolder
            );
          }
        }))
      .show();
    } else {
      MessageDialogActionManager().showConfirmDialogAction(
        key: const Key('confirm_dialog_empty_spam'),
        context,
        title: AppLocalizations.of(context).emptySpamFolder,
        AppLocalizations.of(context).emptySpamMessageDialog,
        cancelTitle: AppLocalizations.of(context).cancel,
        AppLocalizations.of(context).delete_all,
        onCloseButtonAction: popBack,
        onConfirmAction: () {
          popBack();
          if (mailbox.countTotalEmails > 0) {
            dashboardController.emptySpamFolderAction(spamFolderId: mailbox.id, totalEmails: mailbox.countTotalEmails);
          } else {
            appToast.showToastWarningMessage(
              context,
              AppLocalizations.of(context).noEmailInYourCurrentFolder
            );
          }
        },
      );
    }
  }
}