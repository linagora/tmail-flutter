
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/bottom_popup/confirmation_dialog_action_sheet_builder.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_manager.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_folder_content_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/move_folder_content_state.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_action_reactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';

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

  void performMoveFolderContent({
    required BuildContext context,
    required PresentationMailbox mailboxSelected,
    required MailboxDashBoardController dashboardController,
    required BaseMailboxController baseMailboxController,
    required MailboxActionReactor mailboxActionReactor,
  }) {
    final accountId = dashboardController.accountId.value;
    final session = dashboardController.sessionCurrent;

    if (accountId == null || session == null) {
      baseMailboxController.consumeState(
        Stream.value(
          Left(MoveFolderContentFailure(NotFoundAccountIdException())),
        ),
      );
      return;
    }

    baseMailboxController.moveFolderContentAction(
      appLocalizations: AppLocalizations.of(context),
      accountId: accountId,
      session: session,
      mailboxSelected: mailboxSelected,
      onMoveFolderContentAction: (currentMailbox, destinationMailbox, appLocalizations) {
        baseMailboxController.consumeState(
          mailboxActionReactor.moveFolderContent(
            session: session,
            accountId: accountId,
            moveRequest: MoveFolderContentRequest(
              moveAction: MoveAction.moving,
              mailboxId: currentMailbox.id,
              destinationMailboxId: destinationMailbox.id,
              destinationMailboxDisplayName: appLocalizations,
              markAsRead: destinationMailbox.isSpam,
              totalEmails: currentMailbox.countTotalEmails,
            ),
            onProgressController: dashboardController.progressStateController,
          ),
        );
      },
    );
  }

  void handleMoveFolderContentSuccess({
    required MoveFolderContentSuccess success,
    required MailboxDashBoardController dashboardController,
    required BaseMailboxController baseMailboxController,
    required MailboxActionReactor mailboxActionReactor,
  }) {
    dashboardController.syncViewStateMailboxActionProgress(
      newState: Right(UIState.idle),
    );
    final moveFolderRequest = success.request;

    if (moveFolderRequest.moveAction == MoveAction.moving) {
      baseMailboxController.toastManager.showMessageSuccessWithAction(
        success: success,
        onActionCallback: () {
          _undoMoveFolderContentAction(
            dashboardController: dashboardController,
            baseMailboxController: baseMailboxController,
            mailboxActionReactor: mailboxActionReactor,
            newMoveRequest: MoveFolderContentRequest(
              moveAction: MoveAction.undo,
              mailboxId: moveFolderRequest.destinationMailboxId,
              destinationMailboxId: moveFolderRequest.mailboxId,
              destinationMailboxDisplayName: '',
              totalEmails: moveFolderRequest.totalEmails,
            ),
          );
        },
      );
    }
  }

  void _undoMoveFolderContentAction({
    required MoveFolderContentRequest newMoveRequest,
    required MailboxDashBoardController dashboardController,
    required BaseMailboxController baseMailboxController,
    required MailboxActionReactor mailboxActionReactor,
  }) {
    final accountId = dashboardController.accountId.value;
    final session = dashboardController.sessionCurrent;

    if (accountId == null || session == null) {
      baseMailboxController.consumeState(
        Stream.value(
          Left(MoveFolderContentFailure(NotFoundAccountIdException())),
        ),
      );
      return;
    }

    baseMailboxController.consumeState(
      mailboxActionReactor.moveFolderContent(
        session: session,
        accountId: accountId,
        moveRequest: newMoveRequest,
        onProgressController: dashboardController.progressStateController,
      ),
    );
  }

  void handleMoveFolderContentFailure({
    required MoveFolderContentFailure failure,
    required MailboxDashBoardController dashboardController,
    required ToastManager toastManager,
  }) {
    dashboardController.syncViewStateMailboxActionProgress(
      newState: Right(UIState.idle),
    );
    toastManager.showMessageFailure(failure);
  }
}