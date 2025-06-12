
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_utils.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension HandleMailboxActionExtension on MailboxController {

  void handleLongPressMailboxNodeAction(
    BuildContext context,
    PresentationMailbox mailbox,
  ) {
    final deletedMessageVaultSupported =
      MailboxUtils.isDeletedMessageVaultSupported(session, accountId);

    final isSubAddressingSupported =
      session?.isSubAddressingSupported(accountId) ?? false;

    final contextMenuActions = listContextMenuItemAction(
      mailbox,
      mailboxDashBoardController.enableSpamReport,
      deletedMessageVaultSupported,
      isSubAddressingSupported,
      imagePaths,
      AppLocalizations.of(context),
    );

    if (contextMenuActions.isEmpty) {
      return;
    }

    openBottomSheetContextMenuAction(
      context: context,
      itemActions: contextMenuActions,
      onContextMenuActionClick: (menuAction) => handleMailboxAction(
        context,
        menuAction.action,
        mailbox,
      ),
    );
  }

  void handleDragItemAccepted(
    List<PresentationEmail> listEmails,
    PresentationMailbox presentationMailbox,
  ) {
    final mailboxPath = findNodePath(presentationMailbox.id)
        ?? presentationMailbox.name?.name;
    log('HandleMailboxActionExtension::handleDragItemAccepted():mailboxPath = $mailboxPath');
    final newMailbox = mailboxPath != null
        ? presentationMailbox.toPresentationMailboxWithMailboxPath(mailboxPath)
        : presentationMailbox;

    mailboxDashBoardController.dragSelectedMultipleEmailToMailboxAction(
      listEmails,
      newMailbox,
    );
  }

  void openMailboxContextMenuAction(
    BuildContext context,
    RelativeRect position,
    PresentationMailbox mailbox,
  ) {
    final deletedMessageVaultSupported =
      MailboxUtils.isDeletedMessageVaultSupported(session, accountId);

    final isSubAddressingSupported =
      session?.isSubAddressingSupported(accountId) ?? false;

    final contextMenuActions = listContextMenuItemAction(
      mailbox,
      mailboxDashBoardController.enableSpamReport,
      deletedMessageVaultSupported,
      isSubAddressingSupported,
      imagePaths,
      AppLocalizations.of(context),
    );

    if (contextMenuActions.isEmpty) {
      return;
    }

    if (responsiveUtils.isScreenWithShortestSide(context)) {
      openBottomSheetContextMenuAction(
        context: context,
        itemActions: contextMenuActions,
        onContextMenuActionClick: (menuAction) => handleMailboxAction(
          context,
          menuAction.action,
          mailbox,
        ),
      );
    } else {
      openPopupMenuAction(
        context,
        position,
        popupMenuMailboxActionTiles(
          context,
          imagePaths,
          mailbox,
          contextMenuActions,
          handleMailboxAction: handleMailboxAction,
        ),
      );
    }
  }
}