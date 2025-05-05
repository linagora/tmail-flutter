
import 'package:core/core.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/mailbox/mailbox_constants.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/base/widget/popup_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/context_item_mailbox_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_utils.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_bottom_sheet_action_tile_builder.dart';
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
    );

    if (contextMenuActions.isEmpty) {
      return;
    }

    controller.openContextMenuAction(
      context,
      contextMenuMailboxActionTiles(
        context,
        imagePaths,
        mailbox,
        contextMenuActions,
        handleMailboxAction: controller.handleMailboxAction
      )
    );
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
            colorFilter: contextMenuItem.action.getColorContextMenuIcon().asFilter(),
            width: 24,
            height: 24
          ),
          contextMenuItem.action.getTitleContextMenu(context),
          mailbox,
          absorbing: !contextMenuItem.isActivated,
          opacity: !contextMenuItem.isActivated)
      ..actionTextStyle(textStyle: TextStyle(
          fontSize: 16,
          color: contextMenuItem.action.getColorContextMenuTitle(),
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
    );

    if (contextMenuActions.isEmpty) {
      return;
    }

    if (responsiveUtils.isScreenWithShortestSide(context)) {
      controller.openContextMenuAction(
        context,
          contextMenuMailboxActionTiles(
            context,
            imagePaths,
            mailbox,
            contextMenuActions,
            handleMailboxAction: controller.handleMailboxAction
          )
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
      child: AbsorbPointer(
        absorbing: !contextMenuItem.isActivated,
        child: Opacity(
          opacity: contextMenuItem.isActivated ? 1.0 : 0.3,
          child: PopupItemWidget(
            iconAction: contextMenuItem.action.getContextMenuIcon(imagePaths),
            nameAction: contextMenuItem.action.getTitleContextMenu(context),
            colorIcon: contextMenuItem.action.getColorContextMenuIcon(),
            padding: const EdgeInsetsDirectional.only(start: 12),
            iconSize: 24,
            styleName: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: contextMenuItem.action.getColorContextMenuTitle()
            ),
            onCallbackAction: () => handleMailboxAction(context, contextMenuItem.action, mailbox)
          ),
        ),
      )
    );
  }

  Widget buildHeaderMailboxCategory(
    BuildContext context,
    ResponsiveUtils responsiveUtils,
    ImagePaths imagePaths,
    MailboxCategories categories,
    BaseMailboxController baseMailboxController,
    {
      required Function(MailboxCategories categories) toggleMailboxCategories,
      EdgeInsetsGeometry? padding,
      bool isArrangeLTR = true,
    }
  ) {
    final item = Row(children: [
      if (!isArrangeLTR)
        Flexible(
          child: Text(
            categories.getTitle(context),
            maxLines: 1,
            overflow: CommonTextStyle.defaultTextOverFlow,
            softWrap: CommonTextStyle.defaultSoftWrap,
            style: ThemeUtils.textStyleBodyBody3(color: Colors.black),
          ),
        ),
      Obx(() {
        final expandMode = categories.getExpandMode(baseMailboxController.mailboxCategoriesExpandMode.value);
        return TMailButtonWidget.fromIcon(
          icon: expandMode == ExpandMode.EXPAND
            ? imagePaths.icArrowBottom
            : DirectionUtils.isDirectionRTLByLanguage(context)
                ? imagePaths.icArrowLeft
                : imagePaths.icArrowRight,
          iconColor: Colors.black,
          iconSize: 20,
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.all(5),
          tooltipMessage: expandMode == ExpandMode.EXPAND
            ? AppLocalizations.of(context).collapse
            : AppLocalizations.of(context).expand,
          onTapActionCallback: () => toggleMailboxCategories(categories)
        );
      }),
      if (isArrangeLTR)
        Expanded(child: Text(
          categories.getTitle(context),
          maxLines: 1,
          overflow: CommonTextStyle.defaultTextOverFlow,
          softWrap: CommonTextStyle.defaultSoftWrap,
          style: ThemeUtils.textStyleBodyBody3(color: Colors.black)
        )),
    ]);

    if (padding != null) {
      return Padding(padding: padding, child: item);
    } else {
      return item;
    }
  }
}