
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/bottom_popup/confirmation_dialog_action_sheet_builder.dart';
import 'package:core/presentation/views/dialog/confirmation_dialog_builder.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/email/domain/model/mark_read_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/delete_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

mixin EmailActionController {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();

  void editDraftEmail(PresentationEmail presentationEmail) {
    mailboxDashBoardController.goToComposer(ComposerArguments.editDraftEmail(presentationEmail));
  }

  void previewEmail(PresentationEmail presentationEmail) {
    log('EmailActionController::previewEmail():presentationEmailId: ${presentationEmail.id}');
    mailboxDashBoardController.openEmailDetailedView(presentationEmail);
  }

  void moveToTrash(PresentationEmail email, {PresentationMailbox? mailboxContain}) async {
    final session = mailboxDashBoardController.sessionCurrent;
    final accountId = mailboxDashBoardController.accountId.value;
    final trashMailboxId = mailboxDashBoardController.mapDefaultMailboxIdByRole[PresentationMailbox.roleTrash];

    if (session != null && mailboxContain != null && accountId != null && trashMailboxId != null) {
      _moveToTrashAction(
        session,
        accountId,
        MoveToMailboxRequest(
          {mailboxContain.id: email.id != null ? [email.id!] : []},
          trashMailboxId,
          MoveAction.moving,
          EmailActionType.moveToTrash)
      );
    }
  }

  void _moveToTrashAction(Session session, AccountId accountId, MoveToMailboxRequest moveRequest) {
    mailboxDashBoardController.moveToMailbox(session, accountId, moveRequest);
  }

  void moveToSpam(PresentationEmail email, {PresentationMailbox? mailboxContain}) async {
    final session = mailboxDashBoardController.sessionCurrent;
    final accountId = mailboxDashBoardController.accountId.value;
    final spamMailboxId = mailboxDashBoardController.getMailboxIdByRole(PresentationMailbox.roleSpam);

    if (session != null && mailboxContain != null && accountId != null && spamMailboxId != null) {
      moveToSpamAction(
        session,
        accountId,
        MoveToMailboxRequest(
          {mailboxContain.id: email.id != null ? [email.id!] : []},
          spamMailboxId,
          MoveAction.moving,
          EmailActionType.moveToSpam)
      );
    }
  }

  void unSpam(PresentationEmail email) async {
    final session = mailboxDashBoardController.sessionCurrent;
    final accountId = mailboxDashBoardController.accountId.value;
    final spamMailboxId = mailboxDashBoardController.getMailboxIdByRole(PresentationMailbox.roleSpam);
    final inboxMailboxId = mailboxDashBoardController.getMailboxIdByRole(PresentationMailbox.roleInbox);

    if (session != null && inboxMailboxId != null && accountId != null && spamMailboxId != null) {
      moveToSpamAction(
        session,
        accountId,
        MoveToMailboxRequest(
          {spamMailboxId: email.id != null ? [email.id!] : []},
          inboxMailboxId,
          MoveAction.moving,
          EmailActionType.unSpam)
      );
    }
  }

  void moveToSpamAction(Session session, AccountId accountId, MoveToMailboxRequest moveRequest) {
    mailboxDashBoardController.moveToMailbox(session, accountId, moveRequest);
  }

  void moveToMailbox(
    BuildContext context,
    PresentationEmail email,
    {PresentationMailbox? mailboxContain}
  ) async {
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;

    if (mailboxContain != null && accountId != null) {
      final arguments = DestinationPickerArguments(
        accountId,
        MailboxActions.moveEmail,
        session,
        mailboxIdSelected: mailboxContain.mailboxId);

      final destinationMailbox = PlatformInfo.isWeb
        ? await DialogRouter.pushGeneralDialog(routeName: AppRoutes.destinationPicker, arguments: arguments)
        : await push(AppRoutes.destinationPicker, arguments: arguments);

      if (destinationMailbox != null &&
          context.mounted &&
          destinationMailbox is PresentationMailbox &&
          mailboxDashBoardController.sessionCurrent != null
      ) {
        _dispatchMoveToAction(
          context,
          accountId,
          mailboxDashBoardController.sessionCurrent!,
          email,
          mailboxContain,
          destinationMailbox);
      }
    }
  }

  void _dispatchMoveToAction(
    BuildContext context,
    AccountId accountId,
    Session session,
    PresentationEmail emailSelected,
    PresentationMailbox currentMailbox,
    PresentationMailbox destinationMailbox
  ) {
    if (destinationMailbox.isTrash) {
      moveToSpamAction(
        session,
        accountId,
        MoveToMailboxRequest(
          {currentMailbox.id: emailSelected.id != null ? [emailSelected.id!] : []},
          destinationMailbox.id,
          MoveAction.moving,
          EmailActionType.moveToTrash));
    } else if (destinationMailbox.isSpam) {
      moveToSpamAction(
        session,
        accountId,
        MoveToMailboxRequest(
          {currentMailbox.id: emailSelected.id != null ? [emailSelected.id!] : []},
          destinationMailbox.id,
          MoveAction.moving,
          EmailActionType.moveToSpam));
    } else {
      _moveToMailboxAction(
        session,
        accountId,
        MoveToMailboxRequest(
          {currentMailbox.id: emailSelected.id != null ? [emailSelected.id!] : []},
          destinationMailbox.id,
          MoveAction.moving,
          EmailActionType.moveToMailbox,
          destinationPath: destinationMailbox.mailboxPath));
    }
  }

  void _moveToMailboxAction(Session session, AccountId accountId, MoveToMailboxRequest moveRequest) {
    mailboxDashBoardController.moveToMailbox(session, accountId, moveRequest);
  }

  void deleteEmailPermanently(BuildContext context, PresentationEmail email) {
    if (responsiveUtils.isScreenWithShortestSide(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
        ..messageText(DeleteActionType.single.getContentDialog(context))
        ..onCancelAction(AppLocalizations.of(context).cancel, () => popBack())
        ..onConfirmAction(
            DeleteActionType.single.getConfirmActionName(context),
            () => _deleteEmailPermanentlyAction(context, email)))
          .show();
    } else {
      Get.dialog(
        PointerInterceptor(child: (ConfirmDialogBuilder(imagePaths)
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
        .build()),
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
      );
    }
  }

  void _deleteEmailPermanentlyAction(BuildContext context, PresentationEmail email) {
    popBack();
    mailboxDashBoardController.deleteEmailPermanently(email);
  }

  void markAsEmailRead(PresentationEmail presentationEmail, ReadActions readActions, MarkReadAction markReadAction) async {
    mailboxDashBoardController.markAsEmailRead(presentationEmail, readActions, markReadAction);
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

  void openEmailInNewTabAction(BuildContext context, PresentationEmail email) {
    AppUtils.launchLink(email.routeWebAsString);
  }
}