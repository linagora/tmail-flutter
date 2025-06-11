import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/widget/application_version_widget.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/base_mailbox_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/app_grid_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/bottom_bar_selection_mailbox_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/folder_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/folders_bar_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_app_bar.dart';
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
    return SafeArea(
      child: Drawer(
        backgroundColor: Colors.white,
        shape: InputBorder.none,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(children: [
                Obx(() {
                  final accountId = controller
                      .mailboxDashBoardController
                      .accountId
                      .value;

                  final username = accountId != null
                    ? controller.mailboxDashBoardController.getOwnEmailAddress()
                    : '';

                  return MailboxAppBar(
                    username: username,
                    openSettingsAction:
                        controller.mailboxDashBoardController.goToSettings,
                  );
                }),
                _buildHeaderMailbox(context),
                Expanded(child: Container(
                  color: Colors.white,
                  child: RefreshIndicator(
                    color: AppColor.primaryColor,
                    onRefresh: controller.refreshAllMailbox,
                    child: SafeArea(
                      top: false,
                      right: false,
                      bottom: false,
                      child: _buildListMailbox(context)
                    )
                  ),
                )),
                Obx(() {
                  if (controller.isSelectionEnabled()
                      && controller.listActionOfMailboxSelected.isNotEmpty) {
                    return SafeArea(
                      right: false,
                      top: false,
                      child: BottomBarSelectionMailboxWidget(
                        controller.listMailboxSelected,
                        controller.listActionOfMailboxSelected,
                        onMailboxActionsClick: (actions, listMailboxSelected) {
                          return controller.pressMailboxSelectionAction(
                            context,
                            actions,
                            listMailboxSelected
                          );
                        }
                      )
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
              ]),
            ),
            Obx(() {
              if (controller.isSelectionEnabled()) {
                return const SizedBox.shrink();
              }

              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(color: AppColor.colorDividerHorizontal),
                  QuotasView()
                ],
              );
            }),
            Obx(() {
              if (!controller.isSelectionEnabled() && controller.responsiveUtils.isPortraitMobile(context)) {
                return Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: SafeArea(
                    top: false,
                    child: ApplicationVersionWidget(
                      padding: EdgeInsets.zero,
                      title: '${AppLocalizations.of(context).version} ',
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderMailbox(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: controller.responsiveUtils.isMobile(context) ? 10 : 30, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 10),
                child: _buildCloseScreenButton(context)),
              SizedBox(width: controller.isSelectionEnabled() ? 49 : 40),
              Expanded(child: Text(
                AppLocalizations.of(context).folders,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 21, color: Colors.black, fontWeight: FontWeight.bold))),
              Obx(() => _buildEditMailboxButton(context, controller.isSelectionEnabled()))
            ]
          )
        ),
        if (!controller.responsiveUtils.isTabletLarge(context))
          const Divider(color: AppColor.colorDividerMailbox, height: 1),
      ]
    );
  }

  Widget _buildCloseScreenButton(BuildContext context) {
    return buildIconWeb(
        icon: SvgPicture.asset(controller.imagePaths.icCircleClose, width: 28, height: 28, fit: BoxFit.fill),
        tooltip: AppLocalizations.of(context).close,
        onTap: () => controller.closeMailboxScreen(context));
  }

  Widget _buildEditMailboxButton(BuildContext context, bool isSelectionEnabled) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 10),
      child: Material(
          shape: const CircleBorder(),
          color: Colors.transparent,
          child: TextButton(
              child: Text(
                !isSelectionEnabled ? AppLocalizations.of(context).select : AppLocalizations.of(context).cancel,
                style: const TextStyle(fontSize: 17, color: AppColor.colorTextButton, fontWeight: FontWeight.normal)),
              onPressed: () => !isSelectionEnabled
                  ? controller.enableSelectionMailbox()
                  : controller.disableSelectionMailbox()
          )
      ),
    );
  }

  Widget _buildListMailbox(BuildContext context) {
    return SingleChildScrollView(
      controller: controller.mailboxListScrollController,
      key: const PageStorageKey('mailbox_list'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(children: [
        Obx(() => MailboxLoadingBarWidget(viewState: controller.viewState.value)),
        Obx(() {
          final linagoraApps = controller
              .mailboxDashBoardController
              .appGridDashboardController
              .listLinagoraApp;

          if (linagoraApps.isNotEmpty) {
            return AppGridView(linagoraApps: linagoraApps);
          } else {
            return const SizedBox.shrink();
          }
        }),
        const SizedBox(height: 8),
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
          if (controller.mailboxDashBoardController.listSendingEmails.isNotEmpty &&
              PlatformInfo.isMobile &&
              !controller.isSelectionEnabled()) {
            return SendingQueueMailboxWidget(
              listSendingEmails: controller.mailboxDashBoardController.listSendingEmails,
              onOpenSendingQueueAction: () => controller.openSendingQueueViewAction(context),
              isSelected: controller.mailboxDashBoardController.dashboardRoute.value == DashboardRoutes.sendingQueue,
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
        const SizedBox(height: 8),
        const Divider(color: AppColor.colorDividerMailbox, height: 1),
        FoldersBarWidget(
          onOpenSearchFolder: () => controller.openSearchViewAction(context),
          onAddNewFolder:  () => controller.goToCreateNewMailboxView(context),
          imagePaths: controller.imagePaths,
          responsiveUtils: controller.responsiveUtils,
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
        const SizedBox(height: 8),
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
              const SizedBox(height: 8),
              const Divider(color: AppColor.colorDividerMailbox, height: 1),
              const SizedBox(height: 8),
              FolderWidget(
                icon: controller.imagePaths.icHelp,
                label: AppLocalizations.of(context).support,
                onOpenFolderAction: () => controller
                    .mailboxDashBoardController
                    .onGetHelpOrReportBug(contactSupportCapability!),
                tooltip: AppLocalizations.of(context).getHelpOrReportABug,
                padding: const EdgeInsets.symmetric(horizontal: 16)
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
        padding: const EdgeInsetsDirectional.only(
          start: 26,
          end: 16,
        ),
      )),
      AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        child: categories.getExpandMode(controller.mailboxCategoriesExpandMode.value) == ExpandMode.EXPAND
            ? _buildBodyMailboxCategory(
                context: context,
                categories: categories,
                mailboxNode: mailboxNode,
                padding: const EdgeInsetsDirectional.only(
                  start: 30,
                  end: 16,
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
              paddingChild: const EdgeInsetsDirectional.only(start: 14),
              parent: Obx(() => MailboxItemWidget(
                mailboxNode: mailboxNode,
                selectionMode: controller.currentSelectMode.value,
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
              selectionMode: controller.currentSelectMode.value,
              mailboxNodeSelected: controller.mailboxDashBoardController.selectedMailbox.value,
              onLongPressMailboxNodeAction: (mailboxNode) => openMailboxMenuActionOnMobile(context, controller.imagePaths, mailboxNode.item, controller),
              onOpenMailboxFolderClick: (mailboxNode) => controller.openMailbox(context, mailboxNode.item),
              onSelectMailboxFolderClick: (mailboxNode) => controller.selectMailboxNode(mailboxNode)
            ));
          }
      }).toList() ?? <Widget>[];
  }
}