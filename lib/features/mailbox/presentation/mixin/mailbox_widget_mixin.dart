
import 'package:core/core.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/base/widget/popup_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/context_item_mailbox_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_bottom_sheet_action_tile_builder.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/app_dashboard/app_list_dashboard_item.dart';
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
      if (PlatformInfo.isWeb)
        MailboxActions.openInNewTab,
      if (!mailbox.isRecovered)
        MailboxActions.newSubfolder,
      if (mailbox.isTrash)
        ...[
          MailboxActions.emptyTrash,
          MailboxActions.recoverDeletedMessages
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

  List<MailboxActions> _listActionForPersonalMailbox(PresentationMailbox mailbox) {
    return [
      if (PlatformInfo.isWeb && mailbox.isSubscribedMailbox)
        MailboxActions.openInNewTab,
      MailboxActions.newSubfolder,
      if (mailbox.countUnReadEmailsAsString.isNotEmpty)
        MailboxActions.markAsRead,
      MailboxActions.move,
      MailboxActions.rename,
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
      EdgeInsetsGeometry? padding
    }
  ) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(children: [
        Obx(() {
          final expandMode = categories.getExpandMode(baseMailboxController.mailboxCategoriesExpandMode.value);
          return TMailButtonWidget.fromIcon(
            icon: expandMode == ExpandMode.EXPAND
              ? imagePaths.icArrowBottom
              : DirectionUtils.isDirectionRTLByLanguage(context)
                  ? imagePaths.icArrowLeft
                  : imagePaths.icArrowRight,
            iconColor: AppColor.primaryColor,
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
            tooltipMessage: expandMode == ExpandMode.EXPAND
              ? AppLocalizations.of(context).collapse
              : AppLocalizations.of(context).expand,
            onTapActionCallback: () => toggleMailboxCategories(categories)
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

  Widget buildAppGridDashboard(
    BuildContext context,
    ResponsiveUtils responsiveUtils,
    ImagePaths imagePaths,
    MailboxController controller
  ) {
    return Column(children: [
      _buildGoToApplicationsCategory(
        context,
        responsiveUtils,
        imagePaths,
        MailboxCategories.appGrid,
        controller),
      AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        child: Obx(() {
          return controller.mailboxDashBoardController.appGridDashboardController.appDashboardExpandMode.value == ExpandMode.EXPAND
            ? _buildAppGridInMailboxView(context, controller)
            : const Offstage();
        })
      ),
      const Divider(color: AppColor.colorDividerMailbox, height: 1)
    ]);
  }

  Widget _buildGoToApplicationsCategory(
    BuildContext context,
    ResponsiveUtils responsiveUtils,
    ImagePaths imagePaths,
    MailboxCategories categories,
    MailboxController controller
  ) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 32, end: 4),
      child: Row(children: [
        SvgPicture.asset(
          imagePaths.icAppDashboard,
          colorFilter: AppColor.primaryColor.asFilter(),
          width: 20,
          height: 20,
          fit: BoxFit.fill),
        Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(categories.getTitle(context),
            maxLines: 1,
            overflow: CommonTextStyle.defaultTextOverFlow,
            softWrap: CommonTextStyle.defaultSoftWrap,
            style: const TextStyle(
              fontSize: 16,
              color: AppColor.colorTextButton,
              fontWeight: FontWeight.w500
            )
          )
        )),
        buildIconWeb(
          icon: Obx(() => SvgPicture.asset(
            controller.mailboxDashBoardController.appGridDashboardController.appDashboardExpandMode.value == ExpandMode.COLLAPSE
              ? DirectionUtils.isDirectionRTLByLanguage(context) ? imagePaths.icBack : imagePaths.icCollapseFolder
              : imagePaths.icExpandFolder,
            colorFilter: controller.mailboxDashBoardController.appGridDashboardController.appDashboardExpandMode.value == ExpandMode.COLLAPSE
              ? AppColor.colorIconUnSubscribedMailbox.asFilter()
              : AppColor.primaryColor.asFilter(),
            fit: BoxFit.fill
          )),
          tooltip: AppLocalizations.of(context).appGridTittle,
          onTap: () => controller.toggleMailboxCategories(categories)
        )
      ])
    );
  }

  Widget _buildAppGridInMailboxView(BuildContext context, MailboxController controller) {
    return Obx(() {
      final linagoraApps = controller.mailboxDashBoardController.appGridDashboardController.linagoraApplications.value;
      if (linagoraApps != null && linagoraApps.apps.isNotEmpty) {
        return ListView.builder(
          shrinkWrap: true,
          primary: false,
          padding: const EdgeInsetsDirectional.only(start: 16, end: 16, bottom: 8),
          itemCount: linagoraApps.apps.length,
          itemBuilder: (context, index) {
            return AppListDashboardItem(linagoraApps.apps[index]);
          }
        );
      }
      return const SizedBox.shrink();
    });
  }
}