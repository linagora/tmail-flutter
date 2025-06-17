
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_utils.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

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
      onContextMenuActionClick: (menuAction) {
        popBack();
        handleMailboxAction(
          context,
          menuAction.action,
          mailbox,
        );
      },
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

  Future<void> openMailboxContextMenuAction(
    BuildContext context,
    RelativeRect position,
    PresentationMailbox mailbox,
  ) {
    final deletedMessageVaultSupported =
      MailboxUtils.isDeletedMessageVaultSupported(session, accountId);

    final isSubAddressingSupported =
      session?.isSubAddressingSupported(accountId) ?? false;

    final popupMenuActions = getListPopupMenuItemAction(
      AppLocalizations.of(context),
      imagePaths,
      mailbox,
      mailboxDashBoardController.enableSpamReport,
      deletedMessageVaultSupported,
      isSubAddressingSupported,
    );

    if (popupMenuActions.isEmpty) return Future.value();

    final popupMenuItems = popupMenuActions.map((menuAction) {
      return PopupMenuItem(
        padding: EdgeInsets.zero,
        child: PopupMenuItemActionWidget(
          menuAction: menuAction,
          menuActionClick: (menuAction) {
            popBack();
            handleMailboxAction(context, menuAction.action, mailbox);
          },
        ),
      );
    }).toList();

    return openPopupMenuAction(context, position, popupMenuItems);
  }
}