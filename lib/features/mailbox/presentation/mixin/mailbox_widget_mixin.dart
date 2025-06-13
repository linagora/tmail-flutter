
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/model/popup_menu_item_action.dart';
import 'package:tmail_ui_user/features/base/widget/popup_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/context_item_mailbox_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/popup_menu_item_mailbox_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_bottom_sheet_action_tile_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

mixin MailboxWidgetMixin {

  MailboxActions _mailboxActionForSpam(bool spamReportEnabled) {
    return spamReportEnabled
      ? MailboxActions.disableSpamReport
      : MailboxActions.enableSpamReport;
  }

  List<MailboxActions> _listActionForDefaultMailbox(
    PresentationMailbox mailbox,
    bool spamReportEnabled,
    bool deletedMessageVaultSupported
  ) {

    return [
      if (PlatformInfo.isWeb)
        MailboxActions.openInNewTab,
      if (!mailbox.isRecovered)
        MailboxActions.newSubfolder,
      MailboxActions.createFilter,
      if (mailbox.isTrash)
        ...[
          MailboxActions.emptyTrash,
          if (deletedMessageVaultSupported)
            MailboxActions.recoverDeletedMessages,
        ]
      else if (mailbox.isSpam)
        ...[
          _mailboxActionForSpam(spamReportEnabled),
          MailboxActions.confirmMailSpam,
          MailboxActions.emptySpam
        ]
      else if (mailbox.countUnReadEmailsAsString.isNotEmpty)
        MailboxActions.markAsRead
    ];
  }

  List<MailboxActions> _listActionForPersonalMailbox(PresentationMailbox mailbox, bool subaddressingSupported) {
    return [
      if (PlatformInfo.isWeb && mailbox.isSubscribedMailbox)
        MailboxActions.openInNewTab,
      MailboxActions.newSubfolder,
      MailboxActions.createFilter,
      if (mailbox.countUnReadEmailsAsString.isNotEmpty)
        MailboxActions.markAsRead,
      MailboxActions.move,
      MailboxActions.rename,
      if (subaddressingSupported) ...[
        if (mailbox.isSubaddressingAllowed)
          MailboxActions.disallowSubaddressing
        else
          MailboxActions.allowSubaddressing,
        if (mailbox.isSubaddressingAllowed)
          MailboxActions.copySubaddress,
      ],
      if (mailbox.isSubscribedMailbox)
        MailboxActions.disableMailbox
      else
        MailboxActions.enableMailbox,
      MailboxActions.delete
    ];
  }

  List<MailboxActions> _listActionForTeamMailbox(PresentationMailbox mailbox) {
    return [
      if (PlatformInfo.isWeb && mailbox.isSubscribedMailbox)
        MailboxActions.openInNewTab,
      if (mailbox.countUnReadEmailsAsString.isNotEmpty)
        MailboxActions.markAsRead,
      if (mailbox.isTeamMailboxes)
        if (mailbox.isSubscribedMailbox)
          MailboxActions.disableMailbox
        else
          MailboxActions.enableMailbox
    ];
  }

  List<MailboxActions> _listActionForAllMailboxType(
    PresentationMailbox mailbox,
    bool spamReportEnabled,
    bool deletedMessageVaultSupported,
    bool subaddressingSupported,
  ) {
    if (mailbox.isDefault) {
      return _listActionForDefaultMailbox(mailbox, spamReportEnabled, deletedMessageVaultSupported);
    } else if (mailbox.isPersonal) {
      return _listActionForPersonalMailbox(mailbox, subaddressingSupported);
    } else {
      return _listActionForTeamMailbox(mailbox);
    }
  }

  List<Widget> contextMenuMailboxActionTiles(
    BuildContext context,
    ImagePaths imagePaths,
    PresentationMailbox mailbox,
    List<ContextMenuItemMailboxAction> contextMenuActions,
    {
      required Function(BuildContext, MailboxActions, PresentationMailbox) handleMailboxAction
    }
  ) {
    return contextMenuActions
      .map((action) => _buildContextMenuActionTile(
        context,
        imagePaths,
        action,
        mailbox,
        handleMailboxAction: handleMailboxAction
      ))
      .toList();
  }

  Widget _buildContextMenuActionTile(
    BuildContext context,
    ImagePaths imagePaths,
    ContextMenuItemMailboxAction contextMenuItem,
    PresentationMailbox mailbox,
    {
      required Function(BuildContext, MailboxActions, PresentationMailbox) handleMailboxAction
    }
  ) {
    return (MailboxBottomSheetActionTileBuilder(
          Key('${contextMenuItem.action.name}_action'),
          SvgPicture.asset(
            contextMenuItem.action.getContextMenuIcon(imagePaths),
            colorFilter: contextMenuItem.action.getContextMenuIconColor().asFilter(),
            width: 24,
            height: 24
          ),
          contextMenuItem.action.getContextMenuTitle(AppLocalizations.of(context)),
          mailbox,
          absorbing: !contextMenuItem.isActivated,
          opacity: !contextMenuItem.isActivated)
      ..actionTextStyle(textStyle: TextStyle(
          fontSize: 16,
          color: contextMenuItem.action.getContextMenuTitleColor(),
          fontWeight: FontWeight.w500
      ))
      ..onActionClick((mailbox) => handleMailboxAction(context, contextMenuItem.action, mailbox))
    ).build();
  }

  List<ContextMenuItemMailboxAction> listContextMenuItemAction(
    PresentationMailbox mailbox,
    bool spamReportEnabled,
    bool deletedMessageVaultSupported,
    bool subaddressingSupported,
  ) {
    final mailboxActionsSupported = _listActionForAllMailboxType(mailbox, spamReportEnabled, deletedMessageVaultSupported, subaddressingSupported);

    final listContextMenuItemAction = mailboxActionsSupported
      .map((action) => ContextMenuItemMailboxAction(action, action.getContextMenuItemState(mailbox)))
      .toList();

    return listContextMenuItemAction;
  }

  List<PopupMenuItemAction> getListPopupMenuItemAction(
    AppLocalizations appLocalizations,
    ImagePaths imagePaths,
    PresentationMailbox presentationMailbox,
    bool spamReportEnabled,
    bool deletedMessageVaultSupported,
    bool isSubAddressingSupported,
  ) {
    final mailboxActionsSupported = _listActionForAllMailboxType(
      presentationMailbox,
      spamReportEnabled,
      deletedMessageVaultSupported,
      isSubAddressingSupported,
    );

    final popupMenuActions = mailboxActionsSupported
      .map((action) => PopupMenuItemMailboxAction(
        action,
        appLocalizations,
        imagePaths,
      ))
      .toList();

    return popupMenuActions;
  }

  List<PopupMenuEntry> popupMenuMailboxActionTiles(
    BuildContext context,
    ImagePaths imagePaths,
    PresentationMailbox mailbox,
    List<ContextMenuItemMailboxAction> contextMenuActions,
    {
      required Function(BuildContext, MailboxActions, PresentationMailbox) handleMailboxAction
    }
  ) {
    return contextMenuActions
      .map((action) => _buildPopupMenuItem(
        context,
        imagePaths,
        action,
        mailbox,
        handleMailboxAction: handleMailboxAction
      ))
      .toList();
  }

  PopupMenuItem _buildPopupMenuItem(
    BuildContext context,
    ImagePaths imagePaths,
    ContextMenuItemMailboxAction contextMenuItem,
    PresentationMailbox mailbox,
    {
      required Function(BuildContext, MailboxActions, PresentationMailbox) handleMailboxAction
    }
  ) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      child: AbsorbPointer(
        absorbing: !contextMenuItem.isActivated,
        child: Opacity(
          opacity: contextMenuItem.isActivated ? 1.0 : 0.3,
          child: PopupItemWidget(
            iconAction: contextMenuItem.action.getContextMenuIcon(imagePaths),
            nameAction: contextMenuItem.action.getContextMenuTitle(AppLocalizations.of(context)),
            colorIcon: contextMenuItem.action.getContextMenuIconColor(),
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
            styleName: ThemeUtils.textStyleBodyBody3(
              color: contextMenuItem.action.getContextMenuTitleColor()
            ),
            onCallbackAction: () => handleMailboxAction(context, contextMenuItem.action, mailbox)
          ),
        ),
      )
    );
  }
}