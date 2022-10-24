

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/bottom_popup/confirmation_dialog_action_sheet_builder.dart';
import 'package:core/presentation/views/dialog/confirmation_dialog_builder.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/mixin/view_as_dialog_action_mixin.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/delete_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

mixin EmailActionController on ViewAsDialogActionMixin {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();

  void editEmail(PresentationEmail presentationEmail) {
    final arguments = ComposerArguments(
        emailActionType: EmailActionType.edit,
        presentationEmail: presentationEmail,
        mailboxRole: mailboxDashBoardController.selectedMailbox.value?.role);

    mailboxDashBoardController.goToComposer(arguments);
  }

  void previewEmail(BuildContext context, PresentationEmail presentationEmail) {
    mailboxDashBoardController.setSelectedEmail(presentationEmail);
    mailboxDashBoardController.dispatchRoute(DashboardRoutes.emailDetailed);
  }

  void moveToTrash(PresentationEmail email) async {
    final currentMailbox = mailboxDashBoardController.selectedMailbox.value;
    final accountId = mailboxDashBoardController.accountId.value;
    final trashMailboxId = mailboxDashBoardController.mapDefaultMailboxIdByRole[PresentationMailbox.roleTrash];

    if (currentMailbox != null && accountId != null && trashMailboxId != null) {
      _moveToTrashAction(accountId, MoveToMailboxRequest(
          {currentMailbox.id: [email.id]},
          trashMailboxId,
          MoveAction.moving,
          mailboxDashBoardController.sessionCurrent!,
          EmailActionType.moveToTrash)
      );
    }
  }

  void _moveToTrashAction(AccountId accountId, MoveToMailboxRequest moveRequest) {
    mailboxDashBoardController.moveToMailbox(accountId, moveRequest);
  }

  void moveToSpam(PresentationEmail email) async {
    final currentMailbox = mailboxDashBoardController.selectedMailbox.value;
    final accountId = mailboxDashBoardController.accountId.value;
    final spamMailboxId = mailboxDashBoardController.getMailboxIdByRole(PresentationMailbox.roleSpam);

    if (currentMailbox != null && accountId != null && spamMailboxId != null) {
      moveToSpamAction(accountId, MoveToMailboxRequest(
          {currentMailbox.id: [email.id]},
          spamMailboxId,
          MoveAction.moving,
          mailboxDashBoardController.sessionCurrent!,
          EmailActionType.moveToSpam)
      );
    }
  }

  void unSpam(PresentationEmail email) async {
    final accountId = mailboxDashBoardController.accountId.value;
    final spamMailboxId = mailboxDashBoardController.getMailboxIdByRole(PresentationMailbox.roleSpam);
    final inboxMailboxId = mailboxDashBoardController.getMailboxIdByRole(PresentationMailbox.roleInbox);

    if (inboxMailboxId != null && accountId != null && spamMailboxId != null) {
      moveToSpamAction(accountId, MoveToMailboxRequest(
          {spamMailboxId: [email.id]},
          inboxMailboxId,
          MoveAction.moving,
          mailboxDashBoardController.sessionCurrent!,
          EmailActionType.unSpam)
      );
    }
  }

  void moveToSpamAction(AccountId accountId, MoveToMailboxRequest moveRequest) {
    mailboxDashBoardController.moveToMailbox(accountId, moveRequest);
  }

  void moveToMailbox(BuildContext context, PresentationEmail email) async {
    final currentMailbox = mailboxDashBoardController.selectedMailbox.value;
    final accountId = mailboxDashBoardController.accountId.value;

    if (currentMailbox != null && accountId != null) {
      final arguments = DestinationPickerArguments(accountId, MailboxActions.moveEmail);

      if (BuildUtils.isWeb) {
        showDialogDestinationPicker(
            context: context,
            arguments: arguments,
            onSelectedMailbox: (destinationMailbox) {
              _dispatchMoveToAction(
                  context,
                  accountId,
                  email,
                  currentMailbox,
                  destinationMailbox);
            });
      } else {
        final destinationMailbox = await push(
            AppRoutes.destinationPicker,
            arguments: arguments);

      if (destinationMailbox != null && destinationMailbox is PresentationMailbox) {
        if (destinationMailbox.isTrash) {
          moveToSpamAction(accountId, MoveToMailboxRequest(
              {currentMailbox.id: [email.id]},
              destinationMailbox.id,
              MoveAction.moving,
              mailboxDashBoardController.sessionCurrent!,
              EmailActionType.moveToTrash));
        } else if (destinationMailbox.isSpam) {
          moveToSpamAction(accountId, MoveToMailboxRequest(
              {currentMailbox.id: [email.id]},
              destinationMailbox.id,
              MoveAction.moving,
              mailboxDashBoardController.sessionCurrent!,
              EmailActionType.moveToSpam));
        } else {
          _moveToMailboxAction(accountId, MoveToMailboxRequest(
              {currentMailbox.id: [email.id]},
              destinationMailbox.id,
              MoveAction.moving,
              mailboxDashBoardController.sessionCurrent!,
              EmailActionType.moveToMailbox,
              destinationPath: destinationMailbox.mailboxPath));
        }
      }
        _dispatchMoveToAction(
            context,
            accountId,
            email,
            currentMailbox,
            destinationMailbox);
      }
    }
  }

  void _dispatchMoveToAction(
      BuildContext context,
      AccountId accountId,
      PresentationEmail emailSelected,
      PresentationMailbox currentMailbox,
      PresentationMailbox destinationMailbox
  ) {
    if (destinationMailbox.isTrash) {
      moveToSpamAction(accountId, MoveToMailboxRequest(
          [emailSelected.id],
          currentMailbox.id,
          destinationMailbox.id,
          MoveAction.moving,
          EmailActionType.moveToTrash));
    } else if (destinationMailbox.isSpam) {
      moveToSpamAction(accountId, MoveToMailboxRequest(
          [emailSelected.id],
          currentMailbox.id,
          destinationMailbox.id,
          MoveAction.moving,
          EmailActionType.moveToSpam));
    } else {
      _moveToMailboxAction(accountId, MoveToMailboxRequest(
          [emailSelected.id],
          currentMailbox.id,
          destinationMailbox.id,
          MoveAction.moving,
          EmailActionType.moveToMailbox,
          destinationPath: destinationMailbox.mailboxPath));
    }
  }

  void _moveToMailboxAction(AccountId accountId, MoveToMailboxRequest moveRequest) {
    mailboxDashBoardController.moveToMailbox(accountId, moveRequest);
  }

  void deleteEmailPermanently(BuildContext context, PresentationEmail email) {
    if (responsiveUtils.isMobile(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
        ..messageText(DeleteActionType.single.getContentDialog(context))
        ..onCancelAction(AppLocalizations.of(context).cancel, () => popBack())
        ..onConfirmAction(
            DeleteActionType.single.getConfirmActionName(context),
                () => _deleteEmailPermanentlyAction(context, email)))
          .show();
    } else {
      showDialog(
          context: context,
          barrierColor: AppColor.colorDefaultCupertinoActionSheet,
          builder: (BuildContext context) => PointerInterceptor(child: (ConfirmDialogBuilder(imagePaths)
            ..key(const Key('confirm_dialog_delete_email_permanently'))
            ..title(DeleteActionType.single.getTitleDialog(context))
            ..content(DeleteActionType.single.getContentDialog(context))
            ..addIcon(SvgPicture.asset(imagePaths.icRemoveDialog, fit: BoxFit.fill))
            ..colorConfirmButton(AppColor.colorConfirmActionDialog)
            ..styleTextConfirmButton(
                const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: AppColor.colorActionDeleteConfirmDialog))
            ..onCloseButtonAction(() => popBack())
            ..onConfirmButtonAction(
                DeleteActionType.single.getConfirmActionName(context),
                    () => _deleteEmailPermanentlyAction(context, email))
            ..onCancelButtonAction(
                AppLocalizations.of(context).cancel,
                    () => popBack()))
              .build()));
    }
  }

  void _deleteEmailPermanentlyAction(BuildContext context, PresentationEmail email) {
    popBack();
    mailboxDashBoardController.deleteEmailPermanently(email);
  }

  void markAsEmailRead(PresentationEmail presentationEmail, ReadActions readActions) async {
    mailboxDashBoardController.markAsEmailRead(presentationEmail, readActions);
  }

  void markAsStarEmail(PresentationEmail presentationEmail, MarkStarAction action) {
    mailboxDashBoardController.markAsStarEmail(presentationEmail, action);
  }

  void markAsReadSelectedMultipleEmail(List<PresentationEmail> listEmails, ReadActions readActions) {
    mailboxDashBoardController.markAsReadSelectedMultipleEmail(listEmails, readActions);
  }

  void markAsStarSelectedMultipleEmail(List<PresentationEmail> listEmails, MarkStarAction markStarAction) {
    mailboxDashBoardController.markAsStarSelectedMultipleEmail(listEmails, markStarAction);
  }

  void moveSelectedMultipleEmailToMailbox(
      BuildContext context,
      List<PresentationEmail> listEmails,
      PresentationMailbox mailboxCurrent
  ) {
    mailboxDashBoardController.moveSelectedMultipleEmailToMailbox(
        context,
        listEmails,
        mailboxCurrent);
  }

  void moveSelectedMultipleEmailToTrash(List<PresentationEmail> listEmails, PresentationMailbox mailboxCurrent) {
    mailboxDashBoardController.moveSelectedMultipleEmailToTrash(listEmails, mailboxCurrent);
  }

  void moveSelectedMultipleEmailToSpam(List<PresentationEmail> listEmails, PresentationMailbox mailboxCurrent) {
    mailboxDashBoardController.moveSelectedMultipleEmailToSpam(listEmails, mailboxCurrent);
  }

  void unSpamSelectedMultipleEmail(List<PresentationEmail> listEmails) {
    mailboxDashBoardController.unSpamSelectedMultipleEmail(listEmails);
  }

  void deleteSelectionEmailsPermanently(
      BuildContext context,
      DeleteActionType actionType,
      {
        List<PresentationEmail>? listEmails,
        PresentationMailbox? mailboxCurrent,
        Function? onCancelSelectionEmail,
      }
  ) {
    mailboxDashBoardController.deleteSelectionEmailsPermanently(
        context,
        actionType,
        listEmails: listEmails,
        mailboxCurrent: mailboxCurrent,
        onCancelSelectionEmail: onCancelSelectionEmail);
  }
}