import 'package:core/core.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/base_mailbox_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/bottom_bar_selection_mailbox_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_folder_tile_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/sending_queue_mailbox_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/quotas/presentation/widget/quotas_footer_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class MailboxView extends BaseMailboxView {

  MailboxView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeUtils.setStatusBarTransparentColor();

    return SafeArea(bottom: false, left: false, right: false,
        top: responsiveUtils.isMobile(context),
        child: ClipRRect(
            borderRadius: responsiveUtils.isPortraitMobile(context)
                ? const BorderRadius.only(
                    topRight: Radius.circular(14),
                    topLeft: Radius.circular(14))
                : const BorderRadius.all(Radius.zero),
            child: Drawer(
                child: Scaffold(
                  backgroundColor: Colors.white,
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(children: [
                            _buildHeaderMailbox(context),
                            Expanded(child: Container(
                              color: Colors.white,
                              child: RefreshIndicator(
                                color: AppColor.primaryColor,
                                onRefresh: () async => controller.refreshAllMailbox(),
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
                                return _buildOptionSelectionMailbox(context);
                              } else {
                                return const SizedBox.shrink();
                              }
                            }),
                          ]),
                        ),
                        Obx(() => !controller.isSelectionEnabled()
                            ? const QuotasFooterWidget()
                            : const SizedBox.shrink(),
                        ),
                        Obx(() {
                          final appInformation = controller.mailboxDashBoardController.appInformation.value;
                          if (appInformation != null
                              && !controller.isSelectionEnabled()) {
                            if (responsiveUtils.isLandscapeMobile(context)) {
                              return const SizedBox.shrink();
                            }
                            return _buildVersionInformation(context, appInformation);
                          } else {
                            return const SizedBox.shrink();
                          }
                        })
                  ]),
                )
            )
        )
    );
  }

  Widget _buildHeaderMailbox(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: responsiveUtils.isMobile(context) ? 10 : 30, bottom: 8),
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
        if (!responsiveUtils.isTabletLarge(context))
          const Divider(color: AppColor.colorDividerMailbox, height: 0.5, thickness: 0.2),
      ]
    );
  }

  Widget _buildCloseScreenButton(BuildContext context) {
    return buildIconWeb(
        icon: SvgPicture.asset(imagePaths.icCloseMailbox, width: 28, height: 28, fit: BoxFit.fill),
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
    return NotificationListener(
      onNotification: (_) {
        controller.handleScrollEnable();
        return true;
      },
      child: SingleChildScrollView(
        controller: controller.mailboxListScrollController,
        key: const PageStorageKey('mailbox_list'),
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(children: [
          Obx(() {
            if (controller.isSelectionEnabled() && responsiveUtils.isLandscapeMobile(context)) {
              return const SizedBox.shrink();
            }
            return buildUserInformation(context);
          }),
          buildLoadingView(),
          AppConfig.appGridDashboardAvailable
            ? buildAppGridDashboard(context, responsiveUtils, imagePaths, controller)
            : const SizedBox.shrink(),
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
          const Divider(color: AppColor.colorDividerMailbox, height: 0.5, thickness: 0.2),
          const SizedBox(height: 12),
          Container(
            margin: EdgeInsetsDirectional.only(
              start: responsiveUtils.isLandscapeMobile(context) ? 0 : 8,
              end: 16),
            padding: const EdgeInsetsDirectional.only(start: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context).mailBoxes,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
                Row(children: [
                  buildIconWeb(
                    minSize: 40,
                    iconPadding: EdgeInsets.zero,
                    icon: SvgPicture.asset(
                      imagePaths.icSearchBar,
                      colorFilter: AppColor.colorTextButton.asFilter(),
                      fit: BoxFit.fill
                    ),
                    tooltip: AppLocalizations.of(context).searchForMailboxes,
                    onTap: () => controller.openSearchViewAction(context)
                  ),
                  buildIconWeb(
                    minSize: 40,
                    iconSize: 20,
                    iconPadding: EdgeInsets.zero,
                    splashRadius: 15,
                    icon: SvgPicture.asset(
                      imagePaths.icAddNewFolder,
                      colorFilter: AppColor.colorTextButton.asFilter(),
                      fit: BoxFit.fill),
                    tooltip: AppLocalizations.of(context).new_mailbox,
                  onTap: () => controller.goToCreateNewMailboxView(context)),
                ]),
              ]),
            ),
          const SizedBox(height: 8),
          Obx(() {
            if (controller.personalMailboxIsNotEmpty) {
              return _buildMailboxCategory(
                context,
                MailboxCategories.personalMailboxes,
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
        ])
      ),
    );
  }

  Widget _buildHeaderMailboxCategory(BuildContext context, MailboxCategories categories) {
    return Padding(
        padding: EdgeInsetsDirectional.only(
          start: 4,
          end: responsiveUtils.isLandscapeMobile(context) ? 8 : 28),
        child: Row(children: [
         buildIconWeb(
              minSize: 40,
              iconSize: 20,
              iconPadding: EdgeInsets.zero,
              splashRadius: 15,
              icon: SvgPicture.asset(
                  categories.getExpandMode(controller.mailboxCategoriesExpandMode.value) == ExpandMode.EXPAND
                    ? imagePaths.icExpandFolder
                    : DirectionUtils.isDirectionRTLByLanguage(context) ? imagePaths.icBack : imagePaths.icCollapseFolder,
                  colorFilter: AppColor.primaryColor.asFilter(),
                  fit: BoxFit.fill),
              tooltip: AppLocalizations.of(context).collapse,
              onTap: () => controller.toggleMailboxCategories(categories)),
          Expanded(child: Text(categories.getTitle(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold))),
        ]));
  }

  Widget _buildBodyMailboxCategory(BuildContext context, MailboxCategories categories, MailboxNode mailboxNode) {
    final lastNode = mailboxNode.childrenItems?.last;

    return Container(
        margin: EdgeInsetsDirectional.only(
          start: responsiveUtils.isLandscapeMobile(context) ? 0 : 8,
          end: 16
        ),
        padding: const EdgeInsetsDirectional.only(start: 12),
        child: TreeView(
            key: Key('${categories.keyValue}_mailbox_list'),
            children: _buildListChildTileWidget(context, mailboxNode, lastNode: lastNode)));
  }

  Widget _buildMailboxCategory(BuildContext context, MailboxCategories categories, MailboxNode mailboxNode) {
    if (categories == MailboxCategories.exchange) {
      return _buildBodyMailboxCategory(context, categories, mailboxNode);
    }
    return Column(children: [
      _buildHeaderMailboxCategory(context, categories),
      AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        child: categories.getExpandMode(controller.mailboxCategoriesExpandMode.value) == ExpandMode.EXPAND
            ? _buildBodyMailboxCategory(context, categories, mailboxNode)
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
              parent: Obx(() => (MailBoxFolderTileBuilder(
                    context,
                    imagePaths,
                    mailboxNode,
                    lastNode: lastNode,
                    allSelectMode: controller.currentSelectMode.value,
                    mailboxNodeSelected: controller.mailboxDashBoardController.selectedMailbox.value)
                ..addOnLongPressMailboxNodeAction((mailboxNode) {
                  openMailboxMenuActionOnMobile(
                    context,
                    imagePaths,
                    mailboxNode.item,
                    controller
                  );
                })
                ..addOnClickOpenMailboxNodeAction((mailboxNode) => controller.openMailbox(context, mailboxNode.item))
                ..addOnClickExpandMailboxNodeAction((mailboxNode) =>
                  controller.toggleMailboxFolder(mailboxNode, controller.mailboxListScrollController))
                ..addOnSelectMailboxNodeAction((mailboxNode) => controller.selectMailboxNode(mailboxNode))
              ).build()),
              children: _buildListChildTileWidget(context, mailboxNode)
            ).build();
          } else {
            return Obx(() => (MailBoxFolderTileBuilder(
                  context,
                  imagePaths,
                  mailboxNode,
                  lastNode: lastNode,
                  allSelectMode: controller.currentSelectMode.value,
                  mailboxNodeSelected: controller.mailboxDashBoardController.selectedMailbox.value)
              ..addOnLongPressMailboxNodeAction((mailboxNode) {
                openMailboxMenuActionOnMobile(
                  context,
                  imagePaths,
                  mailboxNode.item,
                  controller
                );
              })
              ..addOnClickOpenMailboxNodeAction((mailboxNode) => controller.openMailbox(context, mailboxNode.item))
              ..addOnSelectMailboxNodeAction((mailboxNode) => controller.selectMailboxNode(mailboxNode))
            ).build());
          }
      }).toList() ?? <Widget>[];
  }

  Widget _buildOptionSelectionMailbox(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(
          color: AppColor.lineItemListColor,
          height: 1,
          thickness: 0.2
        ),
        SafeArea(
          right: false,
          top: false,
          child: BottomBarSelectionMailboxWidget(
            responsiveUtils,
            imagePaths,
            controller.listMailboxSelected,
            controller.listActionOfMailboxSelected,
            onMailboxActionsClick: (actions, listMailboxSelected) =>
              controller.pressMailboxSelectionAction(
                context,
                actions,
                listMailboxSelected
              )
          )
        )
      ]
    );
  }

  Widget _buildVersionInformation(BuildContext context, PackageInfo packageInfo) {
    return Container(
      color: AppColor.colorBgMailbox,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: Text(
          '${AppLocalizations.of(context).version} ${packageInfo.version}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: AppColor.colorContentEmail, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}