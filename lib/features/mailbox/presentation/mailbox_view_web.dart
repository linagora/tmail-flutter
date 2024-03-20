import 'package:core/core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/widget/application_version_widget.dart';
import 'package:tmail_ui_user/features/base/widget/scrollbar_list_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/base_mailbox_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_loading_bar_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/user_information_widget.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class MailboxView extends BaseMailboxView {

  MailboxView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        elevation: controller.responsiveUtils.isDesktop(context) ? 0 : 16.0,
        child: Scaffold(
          backgroundColor: controller.responsiveUtils.isWebDesktop(context)
            ? AppColor.colorBgDesktop
            : Colors.white,
          body: Column(children: [
            if (!controller.responsiveUtils.isDesktop(context)) _buildLogoApp(context),
            if (!controller.responsiveUtils.isDesktop(context))
              const Divider(
                  color: AppColor.colorDividerMailbox,
                  height: 0.5,
                  thickness: 0.2),
            Expanded(child: Container(
              padding: EdgeInsetsDirectional.only(start: controller.responsiveUtils.isDesktop(context) ? 16 : 0),
              color: controller.responsiveUtils.isDesktop(context)
                  ? AppColor.colorBgDesktop
                  : Colors.white,
              child: Container(
                color: controller.responsiveUtils.isDesktop(context)
                  ? AppColor.colorBgDesktop
                  : Colors.white,
                child: _buildListMailbox(context),
              ),
            )),
            const QuotasView(),
          ]),
        )
    );
  }

  Widget _buildLogoApp(BuildContext context) {
    return Container(
        color: Colors.white,
        padding: EdgeInsetsDirectional.only(
          top: controller.responsiveUtils.isDesktop(context) ? 25 : 16,
          bottom: controller.responsiveUtils.isDesktop(context) ? 25 : 16,
          start: controller.responsiveUtils.isDesktop(context) ? 32 : 16,
        ),
        child: Row(children: [
          SloganBuilder(
            sizeLogo: 24,
            text: AppLocalizations.of(context).app_name,
            textAlign: TextAlign.center,
            textStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            logoSVG: controller.imagePaths.icTMailLogo
          ),
          ApplicationVersionWidget(
            applicationManager: controller.mailboxDashBoardController.applicationManager,
            padding: const EdgeInsets.only(top: 4),
          )
        ])
    );
  }

  Widget _buildListMailbox(BuildContext context) {
    return Stack(
      children: [
        ScrollbarListView(
          scrollController: controller.mailboxListScrollController,
          scrollBehavior: ScrollConfiguration.of(context).copyWith(
            physics: const BouncingScrollPhysics(),
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad
            },
          ),
          child: RefreshIndicator(
            color: AppColor.primaryColor,
            onRefresh: controller.refreshAllMailbox,
            child: SingleChildScrollView(
              controller: controller.mailboxListScrollController,
              key: const PageStorageKey('mailbox_list'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsetsDirectional.only(end: controller.responsiveUtils.isDesktop(context) ? 16 : 0),
              child: Column(children: [
                if (!controller.responsiveUtils.isDesktop(context))
                  Obx(() => UserInformationWidget(
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
                  )),
                Obx(() => MailboxLoadingBarWidget(viewState: controller.viewState.value)),
                AppConfig.appGridDashboardAvailable && controller.responsiveUtils.isWebNotDesktop(context)
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
                const SizedBox(height: 8),
                const Divider(color: AppColor.colorDividerMailbox, height: 1),
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(
                        AppLocalizations.of(context).folders,
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                        )
                      )),
                      Padding(
                        padding: EdgeInsetsDirectional.only(end: controller.responsiveUtils.isDesktop(context) ? 0 : 12),
                        child: Row(
                          children: [
                            TMailButtonWidget.fromIcon(
                              icon: controller.imagePaths.icSearchBar,
                              backgroundColor: Colors.transparent,
                              iconColor: AppColor.primaryColor,
                              tooltipMessage: AppLocalizations.of(context).searchForFolders,
                              onTapActionCallback: () => controller.openSearchViewAction(context)
                            ),
                            TMailButtonWidget.fromIcon(
                              icon: controller.imagePaths.icAddNewFolder,
                              backgroundColor: Colors.transparent,
                              iconColor: AppColor.primaryColor,
                              tooltipMessage: AppLocalizations.of(context).newFolder,
                              onTapActionCallback: () => controller.goToCreateNewMailboxView(context)
                            ),
                          ],
                        )
                      ),
                    ]),
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
                })
              ])
            ),
          ),
        ),
        Obx(() => controller.mailboxDashBoardController.isDraggingMailbox && controller.activeScrollTop
            ? Align(
                alignment: Alignment.topCenter,
                child: InkWell(
                  onTap: () {},
                  onHover: (value) => value ? controller.autoScrollTop() : controller.stopAutoScroll(),
                  child: Container(
                    height: 40)))
            : const SizedBox.shrink()),
        Obx(() => controller.mailboxDashBoardController.isDraggingMailbox && controller.activeScrollBottom
            ? Align(
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  onTap: () {},
                  onHover: (value) => value ? controller.autoScrollBottom() : controller.stopAutoScroll(),
                  child: Container(
                    height: 40)))
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildBodyMailboxCategory(
    BuildContext context,
    MailboxCategories categories,
    MailboxNode mailboxNode
  ) {
    final lastNode = mailboxNode.childrenItems?.last;

    return Container(
        padding: EdgeInsets.only(
            right: controller.responsiveUtils.isDesktop(context) ? 0 : 16,
            left: controller.responsiveUtils.isDesktop(context) ? 0 : 16),
        child: TreeView(
            key: Key('${categories.keyValue}_mailbox_list'),
            children: _buildListChildTileWidget(
                context,
                mailboxNode,
                lastNode: lastNode)));
  }

  Widget _buildMailboxCategory(
    BuildContext context,
    MailboxCategories categories,
    MailboxNode mailboxNode
  ) {
    if (categories == MailboxCategories.exchange) {
      return _buildBodyMailboxCategory(context, categories, mailboxNode);
    } else {
      return Column(
        children: [
          buildHeaderMailboxCategory(
            context,
            controller.responsiveUtils,
            controller.imagePaths,
            categories,
            controller,
            toggleMailboxCategories: controller.toggleMailboxCategories
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            child: categories.getExpandMode(controller.mailboxCategoriesExpandMode.value) == ExpandMode.EXPAND
              ? _buildBodyMailboxCategory(context, categories, mailboxNode)
              : const Offstage()
          ),
          const SizedBox(height: 8)
        ],
      );
    }
  }

  List<Widget> _buildListChildTileWidget(
    BuildContext context,
    MailboxNode parentNode,
    {MailboxNode? lastNode}
  ) {
    return parentNode.childrenItems?.map((mailboxNode) {
      if (mailboxNode.hasChildren()) {
        return TreeViewChild(
          context,
          key: const Key('children_tree_mailbox_child'),
          isExpanded: mailboxNode.expandMode == ExpandMode.EXPAND,
          paddingChild: const EdgeInsetsDirectional.only(start: 14),
          parent: Obx(() => MailboxItemWidget(
            mailboxNode: mailboxNode,
            mailboxNodeSelected: controller.mailboxDashBoardController.selectedMailbox.value,
            onOpenMailboxFolderClick: (mailboxNode) => controller.openMailbox(context, mailboxNode.item),
            onExpandFolderActionClick: (mailboxNode) => controller.toggleMailboxFolder(mailboxNode, controller.mailboxListScrollController),
            onSelectMailboxFolderClick: controller.selectMailboxNode,
            onDragItemAccepted: _handleDragItemAccepted,
            onMenuActionClick: (position, mailboxNode) {
              openMailboxMenuActionOnWeb(
                context,
                controller.imagePaths,
                controller.responsiveUtils,
                position,
                mailboxNode.item,
                controller
              );
            },
            onEmptyMailboxActionCallback: (mailboxNode) => controller.emptyMailboxAction(context, mailboxNode.item),
          )),
          children: _buildListChildTileWidget(context, mailboxNode)
        ).build();
      } else {
        return Obx(() => MailboxItemWidget(
          mailboxNode: mailboxNode,
          mailboxNodeSelected: controller.mailboxDashBoardController.selectedMailbox.value,
          onOpenMailboxFolderClick: (mailboxNode) => controller.openMailbox(context, mailboxNode.item),
          onSelectMailboxFolderClick: controller.selectMailboxNode,
          onDragItemAccepted: _handleDragItemAccepted,
          onMenuActionClick: (position, mailboxNode) {
            openMailboxMenuActionOnWeb(
              context,
              controller.imagePaths,
              controller.responsiveUtils,
              position,
              mailboxNode.item,
              controller
            );
          },
          onEmptyMailboxActionCallback: (mailboxNode) => controller.emptyMailboxAction(context, mailboxNode.item),
        ));
      }
    }).toList() ?? <Widget>[];
  }

  void _handleDragItemAccepted(List<PresentationEmail> listEmails, PresentationMailbox presentationMailbox) {
    final mailboxPath = controller.findNodePath(presentationMailbox.id)
        ?? presentationMailbox.name?.name;
    log('MailboxView::_handleDragItemAccepted(): mailboxPath: $mailboxPath');
    if (mailboxPath != null) {
      final newMailbox = presentationMailbox.toPresentationMailboxWithMailboxPath(mailboxPath);
      controller.mailboxDashBoardController.dragSelectedMultipleEmailToMailboxAction(listEmails, newMailbox);
    } else {
      controller.mailboxDashBoardController.dragSelectedMultipleEmailToMailboxAction(listEmails, presentationMailbox);
    }
  }
}