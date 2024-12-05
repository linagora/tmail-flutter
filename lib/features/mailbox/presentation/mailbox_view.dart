import 'package:core/core.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/widget/application_version_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/base_mailbox_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/bottom_bar_selection_mailbox_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_loading_bar_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/sending_queue_mailbox_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/user_information_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class MailboxView extends BaseMailboxView {

  MailboxView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeUtils.setStatusBarTransparentColor();

    return SafeArea(bottom: false, left: false, right: false,
        top: controller.responsiveUtils.isMobile(context),
        child: ClipRRect(
            borderRadius: controller.responsiveUtils.isPortraitMobile(context)
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

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Divider(color: AppColor.colorDividerHorizontal),
                              if (controller.contactSupportCapability == null)
                                const QuotasView()
                              else
                                Row(
                                  children: [
                                    const Expanded(child: QuotasView()),
                                    Expanded(
                                      child: TMailButtonWidget(
                                        text: AppLocalizations.of(context).getHelpOrReportABug,
                                        icon: controller.imagePaths.icHelp,
                                        verticalDirection: true,
                                        backgroundColor: Colors.transparent,
                                        maxLines: 2,
                                        flexibleText: true,
                                        mainAxisSize: MainAxisSize.min,
                                        margin: const EdgeInsetsDirectional.only(
                                          end: 12,
                                          start: 4,
                                          top: 6,
                                          bottom: 6,
                                        ),
                                        borderRadius: 10,
                                        textOverflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.primaryColor,
                                        ),
                                        onTapActionCallback: () {},
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          );
                        }),
                        Obx(() {
                          if (!controller.isSelectionEnabled() && controller.responsiveUtils.isPortraitMobile(context)) {
                            return Container(
                              color: AppColor.colorBgMailbox,
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              child: SafeArea(
                                top: false,
                                child: ApplicationVersionWidget(
                                  padding: EdgeInsets.zero,
                                  title: '${AppLocalizations.of(context).version} ',
                                  textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    fontSize: 16,
                                    color: AppColor.colorContentEmail,
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                              ),
                            );
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
        Obx(() {
          if (controller.isSelectionEnabled() && controller.responsiveUtils.isLandscapeMobile(context)) {
            return const SizedBox.shrink();
          }
          return UserInformationWidget(
            userName: controller.mailboxDashBoardController.accountId.value != null
              ? controller.mailboxDashBoardController.sessionCurrent?.username
              : null,
            subtitle: AppLocalizations.of(context).manage_account,
            onSubtitleClick: controller.mailboxDashBoardController.goToSettings,
            border: const Border(
                bottom: BorderSide(
                  color: AppColor.colorDividerHorizontal,
                  width: 0.5,
                )
            ),
          );
        }),
        Obx(() => MailboxLoadingBarWidget(viewState: controller.viewState.value)),
        AppConfig.appGridDashboardAvailable && !PlatformInfo.isMobile
          ? buildAppGridDashboard(context, controller.responsiveUtils, controller.imagePaths, controller)
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
        const Divider(color: AppColor.colorDividerMailbox, height: 1),
        Container(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 16,
            vertical: 6
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context).folders,
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
              Row(children: [
                TMailButtonWidget.fromIcon(
                  icon: controller.imagePaths.icSearchBar,
                  iconColor: AppColor.primaryColor,
                  backgroundColor: Colors.transparent,
                  tooltipMessage: AppLocalizations.of(context).searchForFolders,
                  onTapActionCallback: () => controller.openSearchViewAction(context)
                ),
                TMailButtonWidget.fromIcon(
                  icon: controller.imagePaths.icAddNewFolder,
                  iconColor: AppColor.primaryColor,
                  backgroundColor: Colors.transparent,
                  tooltipMessage: AppLocalizations.of(context).newFolder,
                  onTapActionCallback: () => controller.goToCreateNewMailboxView(context)
                ),
              ]),
            ]),
          ),
        const SizedBox(height: 8),
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
      ])
    );
  }

  Widget _buildHeaderMailboxCategory(BuildContext context, MailboxCategories categories) {
    return Padding(
        padding: EdgeInsetsDirectional.only(
          start: 12,
          end: controller.responsiveUtils.isLandscapeMobile(context) ? 8 : 28),
        child: Row(children: [
          TMailButtonWidget.fromIcon(
            icon: categories.getExpandMode(controller.mailboxCategoriesExpandMode.value) == ExpandMode.EXPAND
              ? controller.imagePaths.icArrowBottom
              : DirectionUtils.isDirectionRTLByLanguage(context)
                  ? controller.imagePaths.icArrowLeft
                  : controller.imagePaths.icArrowRight,
            tooltipMessage: AppLocalizations.of(context).collapse,
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
            iconColor: AppColor.primaryColor,
            onTapActionCallback: () => controller.toggleMailboxCategories(categories)
          ),
          Expanded(
            child: Text(
              categories.getTitle(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                color: Colors.black,
                fontWeight: FontWeight.bold
              )
            )
          ),
        ]));
  }

  Widget _buildBodyMailboxCategory(BuildContext context, MailboxCategories categories, MailboxNode mailboxNode) {
    final lastNode = mailboxNode.childrenItems?.last;

    return Container(
        margin: EdgeInsetsDirectional.only(
          start: controller.responsiveUtils.isLandscapeMobile(context) ? 0 : 8,
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
              parent: Obx(() => MailboxItemWidget(
                mailboxNode: mailboxNode,
                selectionMode: controller.currentSelectMode.value,
                mailboxNodeSelected: controller.mailboxDashBoardController.selectedMailbox.value,
                onLongPressMailboxNodeAction: (mailboxNode) => openMailboxMenuActionOnMobile(context, controller.imagePaths, mailboxNode.item, controller),
                onOpenMailboxFolderClick: (mailboxNode) => controller.openMailbox(context, mailboxNode.item),
                onExpandFolderActionClick: (mailboxNode) => controller.toggleMailboxFolder(mailboxNode, controller.mailboxListScrollController),
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