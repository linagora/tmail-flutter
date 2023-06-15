import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/base_mailbox_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_folder_tile_builder.dart';
import 'package:tmail_ui_user/features/quotas/presentation/widget/quotas_footer_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class MailboxView extends BaseMailboxView {

  MailboxView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        elevation: responsiveUtils.isDesktop(context) ? 0 : 16.0,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(children: [
            if (!responsiveUtils.isDesktop(context)) _buildLogoApp(context),
            if (!responsiveUtils.isDesktop(context))
              const Divider(
                  color: AppColor.colorDividerMailbox,
                  height: 0.5,
                  thickness: 0.2),
            Expanded(child: Container(
              padding: EdgeInsetsDirectional.only(start: responsiveUtils.isDesktop(context) ? 16 : 0),
              color: responsiveUtils.isDesktop(context)
                  ? AppColor.colorBgDesktop
                  : Colors.white,
              child: Container(
                color: responsiveUtils.isDesktop(context)
                  ? AppColor.colorBgDesktop
                  : Colors.white,
                child: RefreshIndicator(
                  color: AppColor.primaryColor,
                  onRefresh: () async => controller.refreshAllMailbox(),
                  child: _buildListMailbox(context)
                ),
              ),
            )),
            const QuotasFooterWidget(),
          ]),
        )
    );
  }

  Widget _buildLogoApp(BuildContext context) {
    return Container(
        color: Colors.white,
        padding: EdgeInsetsDirectional.only(
          top: responsiveUtils.isDesktop(context) ? 25 : 16,
          bottom: responsiveUtils.isDesktop(context) ? 25 : 16,
          start: responsiveUtils.isDesktop(context) ? 32 : 16,
        ),
        child: Row(children: [
          SloganBuilder(
            sizeLogo: 24,
            text: AppLocalizations.of(context).app_name,
            textAlign: TextAlign.center,
            textStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            logo: imagePaths.icLogoTMail
          ),
          Obx(() {
            if (controller.mailboxDashBoardController.appInformation.value != null) {
              return _buildVersionInformation(context, controller.mailboxDashBoardController.appInformation.value!);
            } else {
              return const SizedBox.shrink();
            }
          }),
        ])
    );
  }

  Widget _buildListMailbox(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: controller.mailboxListScrollController,
          key: const PageStorageKey('mailbox_list'),
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsetsDirectional.only(end: responsiveUtils.isDesktop(context) ? 16 : 0),
          child: Column(children: [
            if (!responsiveUtils.isDesktop(context))
              buildUserInformation(context),
            buildLoadingView(),
            AppConfig.appGridDashboardAvailable && responsiveUtils.isWebNotDesktop(context)
              ? buildAppGridDashboard(context, responsiveUtils, imagePaths, controller)
              : const SizedBox.shrink(),
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
            const Divider(color: AppColor.colorDividerMailbox, height: 0.5, thickness: 0.2),
            const SizedBox(height: 13),
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: responsiveUtils.isDesktop(context) ? 0 : 12,
                bottom: 8
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context).mailBoxes,
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
                  Padding(
                    padding: EdgeInsetsDirectional.only(end: responsiveUtils.isDesktop(context) ? 0 : 12),
                    child: Row(
                      children: [
                        buildIconWeb(
                          minSize: 40,
                          iconPadding: EdgeInsets.zero,
                          icon: SvgPicture.asset(
                            imagePaths.icSearchBar,
                            colorFilter: AppColor.colorTextButton.asFilter(),
                            fit: BoxFit.fill
                          ),
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
                      ],
                      )),
                ]),
            ),
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
            right: responsiveUtils.isDesktop(context) ? 0 : 16,
            left: responsiveUtils.isDesktop(context) ? 0 : 16),
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
            responsiveUtils,
            imagePaths,
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
          parent: Obx(() => (MailBoxFolderTileBuilder(
                context,
                imagePaths,
                mailboxNode,
                responsiveUtils: responsiveUtils,
                lastNode: lastNode,
                mailboxNodeSelected: controller.mailboxDashBoardController.selectedMailbox.value)
            ..addOnClickOpenMailboxNodeAction((mailboxNode) => controller.openMailbox(context, mailboxNode.item))
            ..addOnClickExpandMailboxNodeAction((mailboxNode) =>
              controller.toggleMailboxFolder(mailboxNode, controller.mailboxListScrollController))
            ..addOnClickOpenMenuMailboxNodeAction((position, mailboxNode) {
              openMailboxMenuActionOnWeb(
                context,
                imagePaths,
                responsiveUtils,
                position,
                mailboxNode.item,
                controller
              );
            })
            ..addOnSelectMailboxNodeAction((mailboxNode) => controller.selectMailboxNode(mailboxNode))
            ..addOnDragEmailToMailboxAccepted(_handleDragItemAccepted)
          ).build()),
          children: _buildListChildTileWidget(context, mailboxNode)
        ).build();
      } else {
        return Obx(() => (MailBoxFolderTileBuilder(
            context,
              imagePaths,
              mailboxNode,
              responsiveUtils: responsiveUtils,
              lastNode: lastNode,
              mailboxNodeSelected: controller.mailboxDashBoardController.selectedMailbox.value)
          ..addOnClickOpenMailboxNodeAction((mailboxNode) => controller.openMailbox(context, mailboxNode.item))
          ..addOnClickOpenMenuMailboxNodeAction((position, mailboxNode) {
            openMailboxMenuActionOnWeb(
              context,
              imagePaths,
              responsiveUtils,
              position,
              mailboxNode.item,
              controller
            );
          })
          ..addOnSelectMailboxNodeAction((mailboxNode) => controller.selectMailboxNode(mailboxNode))
          ..addOnDragEmailToMailboxAccepted(_handleDragItemAccepted)
        ).build());
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

  Widget _buildVersionInformation(BuildContext context, PackageInfo packageInfo) {
    return Container(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        'v.${packageInfo.version}',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, color: AppColor.colorContentEmail, fontWeight: FontWeight.w500),
      ),
    );
  }
}