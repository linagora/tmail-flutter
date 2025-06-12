
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/mailbox/mailbox_constants.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/widget/popup_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/context_item_mailbox_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_utils.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
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

  void openMailboxMenuActionOnMobile(
    BuildContext context,
    ImagePaths imagePaths,
    PresentationMailbox mailbox,
    MailboxController controller
  ) {
    final bool deletedMessageVaultSupported = MailboxUtils.isDeletedMessageVaultSupported(
        controller.mailboxDashBoardController.sessionCurrent,
        controller.mailboxDashBoardController.accountId.value);

    final bool subaddressingSupported = isSubaddressingSupported(
        controller.mailboxDashBoardController.sessionCurrent,
        controller.mailboxDashBoardController.accountId.value);

    final contextMenuActions = listContextMenuItemAction(
      mailbox,
      controller.mailboxDashBoardController.enableSpamReport,
      deletedMessageVaultSupported,
      subaddressingSupported,
      imagePaths,
      AppLocalizations.of(context),
    );

    if (contextMenuActions.isEmpty) {
      return;
    }

    controller.openContextMenuAction(
      context,
      [],
      itemActions: contextMenuActions,
      onContextMenuActionClick: (menuAction) => controller.handleMailboxAction(
        context,
        menuAction.action,
        mailbox,
      ),
    );
  }

  List<ContextMenuItemMailboxAction> listContextMenuItemAction(
    PresentationMailbox mailbox,
    bool spamReportEnabled,
    bool deletedMessageVaultSupported,
    bool subaddressingSupported,
    ImagePaths imagePaths,
    AppLocalizations appLocalizations,
  ) {
    final mailboxActionsSupported = _listActionForAllMailboxType(mailbox, spamReportEnabled, deletedMessageVaultSupported, subaddressingSupported);

    final listContextMenuItemAction = mailboxActionsSupported
      .map((action) => ContextMenuItemMailboxAction(
        action,
        appLocalizations,
        imagePaths
      ))
      .toList();

    return listContextMenuItemAction;
  }

  void openMailboxMenuActionOnWeb(
    BuildContext context,
    ImagePaths imagePaths,
    ResponsiveUtils responsiveUtils,
    RelativeRect position,
    PresentationMailbox mailbox,
    MailboxController controller
  ) {
    final bool deletedMessageVaultSupported = MailboxUtils.isDeletedMessageVaultSupported(
        controller.mailboxDashBoardController.sessionCurrent,
        controller.mailboxDashBoardController.accountId.value);

    final bool subaddressingSupported = isSubaddressingSupported(
      controller.mailboxDashBoardController.sessionCurrent,
      controller.mailboxDashBoardController.accountId.value);

    final contextMenuActions = listContextMenuItemAction(
      mailbox,
      controller.mailboxDashBoardController.enableSpamReport,
      deletedMessageVaultSupported,
      subaddressingSupported,
      imagePaths,
      AppLocalizations.of(context),
    );

    if (contextMenuActions.isEmpty) {
      return;
    }

    if (responsiveUtils.isScreenWithShortestSide(context)) {
      controller.openContextMenuAction(
        context,
        [],
        itemActions: contextMenuActions,
        onContextMenuActionClick: (menuAction) => controller.handleMailboxAction(
          context,
          menuAction.action,
          mailbox,
        ),
      );
    } else {
      controller.openPopupMenuAction(
        context,
        position,
        popupMenuMailboxActionTiles(
          context,
          imagePaths,
          mailbox,
          contextMenuActions,
          handleMailboxAction: controller.handleMailboxAction
        )
      );
    }
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

  static bool isSubaddressingSupported(Session? session, AccountId? accountId) {
    if (session == null || accountId == null) {
      return false;
    }
    if (!CapabilityIdentifier.jmapTeamMailboxes.isSupported(session, accountId)) {
      return false;
    }

    return (session.getCapabilityProperties(accountId, CapabilityIdentifier.jmapTeamMailboxes)
        ?.props[0] as Map<String, dynamic>?)
        ?[subaddressingSupported]
        ?? false;
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
      child: PopupItemWidget(
        iconAction: contextMenuItem.action.getContextMenuIcon(imagePaths),
        nameAction: contextMenuItem.action.getTitleContextMenu(AppLocalizations.of(context)),
        colorIcon: contextMenuItem.action.getPopupMenuIconColor(),
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
        styleName: ThemeUtils.textStyleBodyBody3(
            color: contextMenuItem.action.getPopupMenuTitleColor()
        ),
        onCallbackAction: () => handleMailboxAction(context, contextMenuItem.action, mailbox)
      )
    );
  }
}