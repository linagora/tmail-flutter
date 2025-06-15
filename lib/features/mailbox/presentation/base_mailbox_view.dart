import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/list/tree_view.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/handle_mailbox_action_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/open_app_grid_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/toggle_expand_folders_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/mailbox_item_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/folder_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/folders_bar_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_app_bar.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_category_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_loading_bar_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/sending_queue_mailbox_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

abstract class BaseMailboxView extends GetWidget<MailboxController>
    with AppLoaderMixin {

  BaseMailboxView({Key? key}) : super(key: key);

  Widget buildMailboxAppBar() {
    return Obx(() {
      final dashboardController = controller.mailboxDashBoardController;
      final accountId = dashboardController.accountId.value;
      final session = dashboardController.sessionCurrent;
      final username = accountId != null
          ? dashboardController.getOwnEmailAddress()
          : '';

      final linagoraApps = dashboardController
          .appGridDashboardController
          .listLinagoraApp;

      final contactSupportCapability = accountId != null && session != null
          ? session.getContactSupportCapability(accountId)
          : null;

      return MailboxAppBar(
        imagePaths: controller.imagePaths,
        username: username,
        openSettingsAction: dashboardController.goToSettings,
        openAppGridAction: linagoraApps.isNotEmpty
          ? () => controller.openAppGrid(linagoraApps)
          : null,
        openContactSupportAction: contactSupportCapability?.isAvailable == true
          ? () => dashboardController.onGetHelpOrReportBug(contactSupportCapability!)
          : null,
      );
    });
  }

  Widget buildFolders(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() {
          if (controller.personalMailboxIsNotEmpty) {
            return buildMailboxCategory(
              context,
              MailboxCategories.personalFolders,
              controller.personalRootNode,
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
        Obx(() {
          if (controller.teamMailboxesIsNotEmpty) {
            return buildMailboxCategory(
              context,
              MailboxCategories.teamMailboxes,
              controller.teamMailboxesRootNode,
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
      ],
    );
  }

  Widget buildMailboxCategory(
    BuildContext context,
    MailboxCategories categories,
    MailboxNode mailboxNode,
  ) {
    final isDesktop = controller.responsiveUtils.isDesktop(context);

    switch (categories) {
      case MailboxCategories.exchange:
        return _buildBodyMailboxCategory(
          context: context,
          categories: categories,
          mailboxNode: mailboxNode,
          padding: isDesktop ? null : const EdgeInsets.symmetric(horizontal: 12),
        );
      default:
        return Column(
          children: [
            Obx(() => MailboxCategoryWidget(
              categories: categories,
              expandMode: categories.getExpandMode(
                controller.mailboxCategoriesExpandMode.value,
              ),
              onToggleMailboxCategories: (categories, itemKey) =>
                  controller.toggleMailboxCategories(
                    categories,
                    controller.mailboxListScrollController,
                    itemKey,
                  ),
              isArrangeLTR: false,
              showIcon: true,
              padding: isDesktop
                  ? const EdgeInsetsDirectional.only(start: 10)
                  : const EdgeInsets.symmetric(horizontal: 24),
              height: isDesktop ? 36 : 40,
              iconSpace: isDesktop
                  ? null
                  : MailboxItemWidgetStyles.mobileLabelIconSpace,
              labelTextStyle: isDesktop ? null : ThemeUtils.textStyleInter500(),
            )),
            Obx(() {
              final categoriesExpandMode = controller
                  .mailboxCategoriesExpandMode
                  .value;

              bool isExpand = categories.getExpandMode(categoriesExpandMode) ==
                  ExpandMode.EXPAND;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                child: isExpand
                  ? _buildBodyMailboxCategory(
                      context: context,
                      categories: categories,
                      mailboxNode: mailboxNode,
                      padding: isDesktop
                        ? const EdgeInsetsDirectional.only(start: 10)
                        : const EdgeInsetsDirectional.only(start: 24, end: 12),
                    )
                  : const Offstage(),
              );
            }),
          ],
        );
    }
  }

  Widget _buildBodyMailboxCategory({
    required BuildContext context,
    required MailboxCategories categories,
    required MailboxNode mailboxNode,
    EdgeInsetsGeometry? padding,
  }) {
    final treeView = TreeView(
      key: Key('${categories.keyValue}_mailbox_list'),
      children: _buildListChildTileWidget(context, mailboxNode),
    );

    if (padding != null) {
      return Padding(padding: padding, child: treeView);
    } else {
      return treeView;
    }
  }

  List<Widget> _buildListChildTileWidget(
    BuildContext context,
    MailboxNode parentNode,
  ) {
    if (parentNode.childrenItems == null) {
      return [];
    }

    return parentNode.childrenItems!.map((mailboxNode) {
      final mailboxItemWidget = Obx(() => MailboxItemWidget(
        mailboxNode: mailboxNode,
        mailboxNodeSelected: controller
          .mailboxDashBoardController
          .selectedMailbox
          .value,
        onOpenMailboxFolderClick: (mailboxNode) =>
          controller.openMailbox(context, mailboxNode.item),
        onExpandFolderActionClick: mailboxNode.hasChildren()
          ? (mailboxNode, itemKey) => controller.toggleMailboxFolder(
              mailboxNode,
              controller.mailboxListScrollController,
              itemKey,
            )
          : null,
        onSelectMailboxFolderClick: controller.selectMailboxNode,
        onLongPressMailboxNodeAction: PlatformInfo.isMobile
          ? (mailboxNode) => controller.handleLongPressMailboxNodeAction(
              context,
              mailboxNode.item,
            )
          : null,
        onDragItemAccepted: PlatformInfo.isMobile
          ? null
          : controller.handleDragItemAccepted,
        onMenuActionClick: PlatformInfo.isMobile
          ? null
          : (position, mailboxNode) {
              return controller.openMailboxContextMenuAction(
                context,
                position,
                mailboxNode.item,
              );
            },
        onEmptyMailboxActionCallback: PlatformInfo.isMobile
          ? null
          : (mailboxNode) => controller.emptyMailboxAction(
              context,
              mailboxNode.item,
            ),
      ));

      if (mailboxNode.hasChildren()) {
        return TreeViewChild(
          context,
          key: const Key('children_tree_mailbox_child'),
          isExpanded: mailboxNode.expandMode == ExpandMode.EXPAND,
          paddingChild: const EdgeInsetsDirectional.only(start: 12),
          parent: mailboxItemWidget,
          children: _buildListChildTileWidget(context, mailboxNode),
        ).build();
      } else {
        return mailboxItemWidget;
      }
    }).toList();
  }

  Widget buildListMailbox(BuildContext context) {
    final isDesktop = controller.responsiveUtils.isDesktop(context);

    return SingleChildScrollView(
      controller: controller.mailboxListScrollController,
      key: const PageStorageKey('mailbox_list'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: isDesktop
        ? const EdgeInsetsDirectional.only(end: 16)
        : const EdgeInsets.only(bottom: 16, top: 16),
      child: Column(children: [
        Obx(() => MailboxLoadingBarWidget(viewState: controller.viewState.value)),
        Obx(() {
          if (controller.defaultMailboxIsNotEmpty) {
            return buildMailboxCategory(
              context,
              MailboxCategories.exchange,
              controller.defaultRootNode,
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
        Obx(() {
          final sendingEmails = controller
              .mailboxDashBoardController
              .listSendingEmails;

          final isSendingQueueSelected =
              controller.mailboxDashBoardController.dashboardRoute.value == DashboardRoutes.sendingQueue;

          if (sendingEmails.isNotEmpty && PlatformInfo.isMobile) {
            return SendingQueueMailboxWidget(
              imagePaths: controller.imagePaths,
              responsiveUtils: controller.responsiveUtils,
              listSendingEmails: sendingEmails,
              onOpenSendingQueueAction: () =>
                  controller.openSendingQueueViewAction(context),
              isSelected: isSendingQueueSelected,
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
        Obx(() {
          final sendingEmails = controller
              .mailboxDashBoardController
              .listSendingEmails;

          if (controller.defaultMailboxIsNotEmpty ||
              (sendingEmails.isNotEmpty && PlatformInfo.isMobile)) {
            return const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Divider(color: AppColor.folderDivider, height: 1),
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
        Obx(() {
          return FoldersBarWidget(
            onOpenSearchFolder: () => controller.openSearchViewAction(context),
            onAddNewFolder: () => controller.goToCreateNewMailboxView(context),
            imagePaths: controller.imagePaths,
            responsiveUtils: controller.responsiveUtils,
            height: isDesktop ? 48 : 40,
            padding: isDesktop
              ? null
              : const EdgeInsetsDirectional.only(start: 24, end: 12),
            labelStyle: isDesktop ? null : ThemeUtils.textStyleInter500(),
            expandMode: controller.foldersExpandMode.value,
            onToggleExpandFolder: controller.toggleExpandFolders,
          );
        }),
        Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          child: controller.foldersExpandMode.value == ExpandMode.EXPAND
              ? buildFolders(context)
              : const Offstage(),
        )),
        Obx(() {
          final accountId = controller
              .mailboxDashBoardController
              .accountId
              .value;

          if (accountId == null) return const SizedBox.shrink();

          final contactSupportCapability = controller
              .mailboxDashBoardController
              .sessionCurrent
              ?.getContactSupportCapability(accountId);

          if (contactSupportCapability?.isAvailable != true) {
            return const SizedBox.shrink();
          }

          final isFoldersExpanded =
              controller.foldersExpandMode.value == ExpandMode.EXPAND;

          final dividerPadding = EdgeInsets.only(
            top: isFoldersExpanded ? 8 : 0,
            bottom: 8,
          );

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: dividerPadding,
                child: const Divider(color: AppColor.folderDivider, height: 1),
              ),
              FolderWidget(
                icon: controller.imagePaths.icHelp,
                label: AppLocalizations.of(context).support,
                onOpenFolderAction: () => controller
                    .mailboxDashBoardController
                    .onGetHelpOrReportBug(contactSupportCapability!),
                tooltip: AppLocalizations.of(context).getHelpOrReportABug,
                padding: isDesktop
                    ? null
                    : const EdgeInsets.symmetric(horizontal: 12),
                itemPadding: const EdgeInsets.symmetric(
                  horizontal: MailboxItemWidgetStyles.mobileItemPadding,
                ),
                borderRadius: isDesktop
                  ? null
                  : MailboxItemWidgetStyles.mobileBorderRadius,
                height: isDesktop
                  ? null
                  : MailboxItemWidgetStyles.mobileHeight,
                labelTextStyle: isDesktop
                  ? null
                  : ThemeUtils.textStyleInter500(),
              ),
            ],
          );
        }),
      ]),
    );
  }
}