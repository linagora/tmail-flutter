import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/list/tree_view.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/labels/presentation/extensions/handle_label_action_type_extension.dart';
import 'package:tmail_ui_user/features/labels/presentation/models/label_action_type.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/handle_label_action_type_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/handle_mailbox_action_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/open_app_grid_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/toggle_expand_folders_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/mailbox_item_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/folders_bar_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/labels/label_list_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/labels/labels_bar_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_app_bar.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_category_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_loading_bar_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/sending_queue_mailbox_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';

abstract class BaseMailboxView extends GetWidget<MailboxController>
    with AppLoaderMixin {

  BaseMailboxView({Key? key}) : super(key: key);

  Widget buildMailboxAppBar() {
    return Obx(() {
      final dashboardController = controller.mailboxDashBoardController;
      final accountId = dashboardController.accountId.value;
      final session = dashboardController.sessionCurrent;
      String username = dashboardController.ownEmailAddress.value;
      if (username.trim().isEmpty) {
        username = session?.getOwnEmailAddressOrUsername() ?? '';
      }

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
                  ? const EdgeInsets.symmetric(
                      horizontal: MailboxItemWidgetStyles.itemPadding,
                    )
                  : const EdgeInsets.symmetric(
                      horizontal: MailboxItemWidgetStyles.mobileItemPadding * 2,
                    ),
              height: isDesktop
                  ? MailboxItemWidgetStyles.height
                  : MailboxItemWidgetStyles.mobileHeight,
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
        isHighlighted: isFolderHighlighted(mailboxNode),
        onOpenMailboxFolderClick: (mailboxNode) =>
            mailboxNode != null
                ? controller.openMailbox(context, mailboxNode.item)
                : null,
        onExpandFolderActionClick: mailboxNode.hasChildren()
          ? (mailboxNode, itemKey) => controller.toggleMailboxFolder(
              mailboxNode,
              controller.mailboxListScrollController,
              itemKey,
            )
          : null,
        onSelectMailboxFolderClick: controller.selectMailboxNode,
        onLongPressMailboxNodeAction: (mailboxNode) => controller.handleLongPressMailboxNodeAction(
          context,
          mailboxNode.item,
        ),
        onDragItemAccepted: controller.handleDragItemAccepted,
        onMenuActionClick: (position, mailboxNode) {
          return controller.openMailboxContextMenuAction(
            context,
            position,
            mailboxNode.item,
          );
        },
        onEmptyMailboxActionCallback: (mailboxNode) => controller.emptyMailboxAction(
            context,
            mailboxNode.item,
          ),
      ));

      if (mailboxNode.hasChildren()) {
        return TreeViewChild(
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

  bool get isSearchByStarredOnly {
    final searchController =
        controller.mailboxDashBoardController.searchController;

    return searchController.isSearchEmailRunning &&
        searchController.searchEmailFilter.value.isOnlyStarredApplied;
  }

  bool isFolderHighlighted(MailboxNode mailboxNode) =>
      mailboxNode.item.isFavorite && isSearchByStarredOnly;

  Widget buildListMailbox(BuildContext context) {
    final isDesktop = controller.responsiveUtils.isDesktop(context);
    final isMobileResponsive = controller
        .responsiveUtils
        .isScreenWithShortestSide(context);

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
        buildLabelsBar(context, isDesktop),
        buildLabelsList(context, isDesktop, isMobileResponsive),
      ]),
    );
  }

  Widget buildLabelsBar(BuildContext context, bool isDesktop) {
    return Obx(() {
      final isLabelCapabilitySupported = controller
          .mailboxDashBoardController
          .isLabelCapabilitySupported;

      final labelController =
          controller.mailboxDashBoardController.labelController;

      final isLabelSettingEnabled = labelController
          .isLabelSettingEnabled
          .isTrue;

      if (isLabelCapabilitySupported && isLabelSettingEnabled) {
        final accountId = controller.accountId;
        final labelListExpandMode = labelController.labelListExpandMode.value;
        final countLabels = labelController.labels.length;

        return LabelsBarWidget(
          imagePaths: controller.imagePaths,
          isDesktop: isDesktop,
          height: isDesktop ? 48 : 40,
          padding: isDesktop
              ? null
              : const EdgeInsetsDirectional.only(start: 24, end: 12),
          labelStyle: isDesktop ? null : ThemeUtils.textStyleInter500(),
          expandMode: labelListExpandMode,
          countLabels: countLabels,
          onToggleLabelListState: labelController.toggleLabelListState,
          onAddNewLabel: () =>
              labelController.handleLabelActionType(
                actionType: LabelActionType.create,
                accountId: accountId,
              ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget buildLabelsList(
    BuildContext context,
    bool isDesktop,
    bool isMobileResponsive,
  ) {
    return Obx(() {
      final dashboardController = controller.mailboxDashBoardController;

      final isLabelCapabilitySupported =
          dashboardController.isLabelCapabilitySupported;

      final labelController = dashboardController.labelController;

      final isLabelSettingEnabled = labelController
          .isLabelSettingEnabled
          .isTrue;

      if (isLabelCapabilitySupported && isLabelSettingEnabled) {
        final labelListExpandMode = labelController.labelListExpandMode.value;
        final labels = labelController.labels;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          child: labelListExpandMode == ExpandMode.EXPAND && labels.isNotEmpty
              ? LabelListView(
                  labels: labels,
                  imagePaths: controller.imagePaths,
                  isDesktop: isDesktop,
                  isMobileResponsive: isMobileResponsive,
                  onOpenContextMenu: (label, position) =>
                    dashboardController.openLabelPopupMenuAction(
                      context,
                      controller.imagePaths,
                      label,
                      position,
                    ),
                  onLongPressLabelItemAction: (label) =>
                    dashboardController.openLabelContextMenuAction(
                      context,
                      controller.imagePaths,
                      label,
                    ),
                )
              : const Offstage(),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}