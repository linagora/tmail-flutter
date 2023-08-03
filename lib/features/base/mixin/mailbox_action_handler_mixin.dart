
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/presentation_mailbox_extension.dart';
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
    final imagePaths = Get.find<ImagePaths>();
    final appToast = Get.find<AppToast>();

    if (responsiveUtils.isScreenWithShortestSide(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
        ..messageText(AppLocalizations.of(context).emptyTrashMessageDialog)
        ..onCancelAction(AppLocalizations.of(context).cancel, popBack)
        ..onConfirmAction(AppLocalizations.of(context).delete, () {
            popBack();
            if (mailbox.countEmails > 0) {
              dashboardController.emptyTrashFolderAction(trashFolderId: mailbox.id);
            } else {
              appToast.showToastWarningMessage(
                context,
                AppLocalizations.of(context).noEmailInYourCurrentMailbox
              );
            }
        }))
      .show();
    } else {
      showDialog(
        context: context,
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
        builder: (context) => PointerInterceptor(child: (ConfirmDialogBuilder(imagePaths)
          ..key(const Key('confirm_dialog_empty_trash'))
          ..title(AppLocalizations.of(context).emptyTrash)
          ..content(AppLocalizations.of(context).emptyTrashMessageDialog)
          ..addIcon(SvgPicture.asset(imagePaths.icRemoveDialog, fit: BoxFit.fill))
          ..colorConfirmButton(AppColor.colorConfirmActionDialog)
          ..styleTextConfirmButton(const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppColor.colorActionDeleteConfirmDialog))
          ..onCloseButtonAction(popBack)
          ..onConfirmButtonAction(AppLocalizations.of(context).delete, () {
              popBack();
              if (mailbox.countEmails > 0) {
                dashboardController.emptyTrashFolderAction(trashFolderId: mailbox.id);
              } else {
                appToast.showToastWarningMessage(
                  context,
                  AppLocalizations.of(context).noEmailInYourCurrentMailbox
                );
              }
          })
          ..onCancelButtonAction(AppLocalizations.of(context).cancel, popBack))
        .build()));
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
    final imagePaths = Get.find<ImagePaths>();
    final appToast = Get.find<AppToast>();

    if (responsiveUtils.isScreenWithShortestSide(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
        ..messageText(AppLocalizations.of(context).emptySpamMessageDialog)
        ..onCancelAction(AppLocalizations.of(context).cancel, popBack)
        ..onConfirmAction(AppLocalizations.of(context).delete_all, () {
          popBack();
          if (mailbox.countEmails > 0) {
            dashboardController.emptySpamFolderAction(spamFolderId: mailbox.id);
          } else {
            appToast.showToastWarningMessage(
              context,
              AppLocalizations.of(context).noEmailInYourCurrentMailbox
            );
          }
        }))
      .show();
    } else {
      showDialog(
        context: context,
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
        builder: (context) => PointerInterceptor(child: (ConfirmDialogBuilder(imagePaths)
          ..key(const Key('confirm_dialog_empty_spam'))
          ..title(AppLocalizations.of(context).emptySpamFolder)
          ..content(AppLocalizations.of(context).emptySpamMessageDialog)
          ..addIcon(SvgPicture.asset(imagePaths.icRemoveDialog, fit: BoxFit.fill))
          ..colorConfirmButton(AppColor.colorConfirmActionDialog)
          ..styleTextConfirmButton(const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppColor.colorActionDeleteConfirmDialog))
          ..onCloseButtonAction(popBack)
          ..onConfirmButtonAction(AppLocalizations.of(context).delete_all, () {
            popBack();
            if (mailbox.countEmails > 0) {
              dashboardController.emptySpamFolderAction(spamFolderId: mailbox.id);
            } else {
              appToast.showToastWarningMessage(
                context,
                AppLocalizations.of(context).noEmailInYourCurrentMailbox
              );
            }
          })
          ..onCancelButtonAction(AppLocalizations.of(context).cancel, popBack)
        ).build()));
    }
  }
}