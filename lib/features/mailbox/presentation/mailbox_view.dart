import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/widget/application_version_widget.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/base_mailbox_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/mailbox_item_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/folder_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/folders_bar_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_category_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_loading_bar_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/sending_queue_mailbox_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MailboxView extends BaseMailboxView {

  MailboxView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: InputBorder.none,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildMailboxAppBar(),
            Expanded(
              child: RefreshIndicator(
                color: AppColor.primaryColor,
                onRefresh: controller.refreshAllMailbox,
                child: _buildListMailbox(context),
              ),
            ),
            const QuotasView(),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: ApplicationVersionWidget(
                padding: EdgeInsets.zero,
                title: '${AppLocalizations.of(context).version} ',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListMailbox(BuildContext context) {
    return SingleChildScrollView(
      controller: controller.mailboxListScrollController,
      key: const PageStorageKey('mailbox_list'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16, top: 16),
      child: Column(children: [
        Obx(() => MailboxLoadingBarWidget(viewState: controller.viewState.value)),
        Obx(() {
          if (controller.defaultMailboxIsNotEmpty) {
            return _buildMailboxCategory(
              context,
              MailboxCategories.exchange,
              controller.defaultRootNode
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
        Obx(() {
          if (controller.mailboxDashBoardController.listSendingEmails.isNotEmpty) {
            return SendingQueueMailboxWidget(
              imagePaths: controller.imagePaths,
              responsiveUtils: controller.responsiveUtils,
              listSendingEmails: controller.mailboxDashBoardController.listSendingEmails,
              onOpenSendingQueueAction: () => controller.openSendingQueueViewAction(context),
              isSelected: controller.mailboxDashBoardController.dashboardRoute.value == DashboardRoutes.sendingQueue,
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
        Obx(() {
          if (controller.defaultMailboxIsNotEmpty ||
              controller.mailboxDashBoardController.listSendingEmails.isNotEmpty) {
            return const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Divider(color: AppColor.folderDivider, height: 1),
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
        FoldersBarWidget(
          onOpenSearchFolder: () => controller.openSearchViewAction(context),
          onAddNewFolder:  () => controller.goToCreateNewMailboxView(context),
          imagePaths: controller.imagePaths,
          responsiveUtils: controller.responsiveUtils,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          labelStyle: ThemeUtils.textStyleInter500(),
        ),
        Obx(() {
          if (controller.personalMailboxIsNotEmpty) {
            return _buildMailboxCategory(
              context,
              MailboxCategories.personalFolders,
              controller.personalRootNode
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
        Obx(() {
          if (controller.teamMailboxesIsNotEmpty) {
            return _buildMailboxCategory(
              context,
              MailboxCategories.teamMailboxes,
              controller.teamMailboxesRootNode
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
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

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Divider(color: AppColor.folderDivider, height: 1),
              ),
              FolderWidget(
                icon: controller.imagePaths.icHelp,
                label: AppLocalizations.of(context).support,
                onOpenFolderAction: () => controller
                    .mailboxDashBoardController
                    .onGetHelpOrReportBug(contactSupportCapability!),
                tooltip: AppLocalizations.of(context).getHelpOrReportABug,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemPadding: const EdgeInsets.symmetric(
                  horizontal: MailboxItemWidgetStyles.mobileItemPadding,
                ),
                borderRadius: MailboxItemWidgetStyles.mobileBorderRadius,
                height: MailboxItemWidgetStyles.mobileHeight,
                labelTextStyle: ThemeUtils.textStyleInter500(),
              ),
            ],
          );
        }),
      ])
    );
  }

  Widget _buildBodyMailboxCategory({
    required BuildContext context,
    required MailboxCategories categories,
    required MailboxNode mailboxNode,
    EdgeInsetsGeometry? padding,
  }) {
    final lastNode = mailboxNode.childrenItems?.last;

    final treeView = TreeView(
      key: Key('${categories.keyValue}_mailbox_list'),
      children: _buildListChildTileWidget(
        context,
        mailboxNode,
        lastNode: lastNode,
      ),
    );

    if (padding != null) {
      return Padding(
        padding: padding,
        child: treeView,
      );
    } else {
      return treeView;
    }
  }

  Widget _buildMailboxCategory(BuildContext context, MailboxCategories categories, MailboxNode mailboxNode) {
    if (categories == MailboxCategories.exchange) {
      return _buildBodyMailboxCategory(
        context: context,
        categories: categories,
        mailboxNode: mailboxNode,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      );
    }
    return Column(children: [
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        height: 40,
        iconSpace: MailboxItemWidgetStyles.mobileLabelIconSpace,
        labelTextStyle: ThemeUtils.textStyleInter500(),
      )),
      AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        child: categories.getExpandMode(controller.mailboxCategoriesExpandMode.value) == ExpandMode.EXPAND
            ? _buildBodyMailboxCategory(
                context: context,
                categories: categories,
                mailboxNode: mailboxNode,
                padding: const EdgeInsetsDirectional.only(
                  start: 24,
                  end: 12,
                ),
              )
            : const Offstage())
    ]);
  }

  List<Widget> _buildListChildTileWidget(BuildContext context, MailboxNode parentNode, {MailboxNode? lastNode}) {
    return parentNode.childrenItems
      ?.map((mailboxNode) {
          if (mailboxNode.hasChildren()) {
            return TreeViewChild(
              context,
              key: const Key('children_tree_mailbox_child'),
              isExpanded: mailboxNode.expandMode == ExpandMode.EXPAND,
              paddingChild: const EdgeInsetsDirectional.only(start: 12),
              parent: Obx(() => MailboxItemWidget(
                mailboxNode: mailboxNode,
                mailboxNodeSelected: controller.mailboxDashBoardController.selectedMailbox.value,
                onLongPressMailboxNodeAction: (mailboxNode) => openMailboxMenuActionOnMobile(context, controller.imagePaths, mailboxNode.item, controller),
                onOpenMailboxFolderClick: (mailboxNode) => controller.openMailbox(context, mailboxNode.item),
                onExpandFolderActionClick: (mailboxNode, itemKey) =>
                    controller.toggleMailboxFolder(
                        mailboxNode,
                        controller.mailboxListScrollController,
                        itemKey,
                    ),
                onSelectMailboxFolderClick: (mailboxNode) => controller.selectMailboxNode(mailboxNode),
              )),
              children: _buildListChildTileWidget(context, mailboxNode)
            ).build();
          } else {
            return Obx(() => MailboxItemWidget(
              mailboxNode: mailboxNode,
              mailboxNodeSelected: controller.mailboxDashBoardController.selectedMailbox.value,
              onLongPressMailboxNodeAction: (mailboxNode) => openMailboxMenuActionOnMobile(context, controller.imagePaths, mailboxNode.item, controller),
              onOpenMailboxFolderClick: (mailboxNode) => controller.openMailbox(context, mailboxNode.item),
              onSelectMailboxFolderClick: (mailboxNode) => controller.selectMailboxNode(mailboxNode)
            ));
          }
      }).toList() ?? <Widget>[];
  }
}