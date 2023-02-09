
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/widget/popup_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/context_item_mailbox_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_bottom_sheet_action_tile_builder.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

mixin MailboxWidgetMixin {

  MailboxActions _mailboxActionForSpam(MailboxDashBoardController dashBoardController) {
    return dashBoardController.enableSpamReport
      ? MailboxActions.disableSpamReport
      : MailboxActions.enableSpamReport;
  }

  List<MailboxActions> listActionForMailbox(
    PresentationMailbox mailbox,
    MailboxDashBoardController dashBoardController
  ) {
    return [
      if (BuildUtils.isWeb)
        MailboxActions.openInNewTab,
      if (mailbox.isSpam)
        _mailboxActionForSpam(dashBoardController),
      MailboxActions.markAsRead,
      MailboxActions.move,
      MailboxActions.rename,
      MailboxActions.delete,
      if (mailbox.isSupportedDisableMailbox)
        MailboxActions.disableMailbox
    ];
  }

  void openMailboxMenuActionOnMobile(
    BuildContext context,
    ImagePaths imagePaths,
    PresentationMailbox mailbox,
    MailboxController controller
  ) {
    final contextMenuActions = listContextMenuItemAction(mailbox, controller.mailboxDashBoardController);

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
            color: contextMenuItem.action.getColorContextMenuIcon(),
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
    MailboxDashBoardController dashBoardController,
    {
      List<MailboxActions>? mailboxActions
    }
  ) {
    final mailboxActionsSupported = mailboxActions ?? listActionForMailbox(
      mailbox,
      dashBoardController
    );

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
    final contextMenuActions = listContextMenuItemAction(mailbox, controller.mailboxDashBoardController);

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
            contextMenuItem.action.getContextMenuIcon(imagePaths),
            contextMenuItem.action.getTitleContextMenu(context),
            colorIcon: contextMenuItem.action.getColorContextMenuIcon(),
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
}