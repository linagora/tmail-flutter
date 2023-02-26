
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/base/widget/popup_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/context_item_mailbox_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
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
    bool spamReportEnabled
  ) {

    return [
      if (BuildUtils.isWeb)
        MailboxActions.openInNewTab,
      if (mailbox.isSpam)
        _mailboxActionForSpam(spamReportEnabled),
      if (mailbox.getCountUnReadEmails().isNotEmpty)
        MailboxActions.markAsRead
    ];
  }

  List<MailboxActions> _listActionForPersonalMailbox(PresentationMailbox mailbox) {
    return [
      if (BuildUtils.isWeb && mailbox.isSubscribedMailbox)
        MailboxActions.openInNewTab,
      if (mailbox.getCountUnReadEmails().isNotEmpty)
        MailboxActions.markAsRead,
      MailboxActions.move,
      MailboxActions.rename,
      MailboxActions.delete,
      if (mailbox.isSubscribedMailbox)
        MailboxActions.disableMailbox
      else
        MailboxActions.enableMailbox
    ];
  }

  List<MailboxActions> _listActionForTeamMailbox(PresentationMailbox mailbox) {
    return [
      if (BuildUtils.isWeb && mailbox.isSubscribedMailbox)
        MailboxActions.openInNewTab,
      if (mailbox.getCountUnReadEmails().isNotEmpty)
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
    bool spamReportEnabled
  ) {
    if (mailbox.isDefault) {
      return _listActionForDefaultMailbox(mailbox, spamReportEnabled);
    } else if (mailbox.isPersonal) {
      return _listActionForPersonalMailbox(mailbox);
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
    final contextMenuActions = listContextMenuItemAction(
      mailbox,
      controller.mailboxDashBoardController.enableSpamReport
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
    bool spamReportEnabled
  ) {
    final mailboxActionsSupported = _listActionForAllMailboxType(mailbox, spamReportEnabled);

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
    final contextMenuActions = listContextMenuItemAction(
      mailbox,
      controller.mailboxDashBoardController.enableSpamReport
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

  Widget buildHeaderMailboxCategory(
    BuildContext context,
    ResponsiveUtils responsiveUtils,
    ImagePaths imagePaths,
    MailboxCategories categories,
    BaseMailboxController baseMailboxController,
    {
      required Function(MailboxCategories categories) toggleMailboxCategories,
      EdgeInsets? padding
    }
  ) {
    return Padding(
      padding: padding ?? EdgeInsets.only(
        top: 10,
        left: responsiveUtils.isDesktop(context) ? 0 : 16,
        right: responsiveUtils.isDesktop(context) ? 0 : 16
      ),
      child: Row(children: [
        Obx(() {
          final expandMode = categories.getExpandMode(baseMailboxController.mailboxCategoriesExpandMode.value);
          return buildIconWeb(
            splashRadius: 12,
            iconPadding: EdgeInsets.zero,
            minSize: 12,
            icon: SvgPicture.asset(
              expandMode == ExpandMode.EXPAND
                ? imagePaths.icExpandFolder
                : imagePaths.icCollapseFolder,
              color: AppColor.primaryColor,
              fit: BoxFit.fill
            ),
            tooltip: expandMode == ExpandMode.EXPAND
              ? AppLocalizations.of(context).collapse
              : AppLocalizations.of(context).expand,
            onTap: () => toggleMailboxCategories(categories)
          );
        }),
        Expanded(child: Text(
          categories.getTitle(context),
          maxLines: 1,
          overflow: CommonTextStyle.defaultTextOverFlow,
          softWrap: CommonTextStyle.defaultSoftWrap,
          style: const TextStyle(
            fontSize: 17,
            color: Colors.black,
            fontWeight: FontWeight.bold
          )
        )),
      ])
    );
  }
}