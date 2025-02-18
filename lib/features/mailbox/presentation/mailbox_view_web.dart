import 'package:core/core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/widget/application_logo_with_text_widget.dart';
import 'package:tmail_ui_user/features/base/widget/application_version_widget.dart';
import 'package:tmail_ui_user/features/base/widget/scrollbar_list_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/base_mailbox_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/app_grid_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_loading_bar_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/user_information_widget.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_view.dart';
import 'package:tmail_ui_user/features/quotas/presentation/styles/quotas_view_styles.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/draggable_email_data.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MailboxView extends BaseMailboxView {

  MailboxView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        elevation: controller.responsiveUtils.isDesktop(context) ? 0 : 16.0,
        shape: controller.responsiveUtils.isDesktop(context)
          ? const RoundedRectangleBorder()
          : null,
        child: Scaffold(
          backgroundColor: controller.responsiveUtils.isWebDesktop(context)
            ? AppColor.colorBgDesktop
            : Colors.white,
          body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (!controller.responsiveUtils.isDesktop(context))
              ApplicationLogoWidthTextWidget(
                margin: const EdgeInsetsDirectional.only(
                  top: 16,
                  bottom: 16,
                  start: 16,
                ),
              ),
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
            const Divider(color: AppColor.colorDividerHorizontal),
            if (controller.responsiveUtils.isWebDesktop(context) ||
                controller.contactSupportCapability?.isAvailable != true)
              const QuotasView(
                padding: EdgeInsetsDirectional.only(
                  start: QuotasViewStyles.padding,
                  top: QuotasViewStyles.padding,
                ),
              )
            else
              Row(
                children: [
                  const Expanded(
                    child: QuotasView(
                      padding: EdgeInsetsDirectional.only(
                        start: QuotasViewStyles.padding,
                        top: QuotasViewStyles.padding,
                      ),
                    ),
                  ),
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
                      onTapActionCallback: () =>
                        controller.onGetHelpOrReportBug(
                          controller.contactSupportCapability!,
                        ),
                    ),
                  ),
                ],
              ),
            Container(
              color: AppColor.colorBgMailbox,
              width: double.infinity,
              alignment: controller.responsiveUtils.isDesktop(context)
                ? AlignmentDirectional.centerStart
                : AlignmentDirectional.center,
              padding: const EdgeInsets.all(16),
              child: ApplicationVersionWidget(
                padding: EdgeInsets.zero,
                title: '${AppLocalizations.of(context).version.toLowerCase()} ',
                textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  color: AppColor.colorTextBody,
                  fontWeight: FontWeight.normal
                ),
              ),
            ),
          ]),
        )
    );
  }

  Widget _buildListMailbox(BuildContext context) {
    final mailboxListWidget = SingleChildScrollView(
      controller: controller.mailboxListScrollController,
      key: const PageStorageKey('mailbox_list'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsetsDirectional.only(end: controller.responsiveUtils.isDesktop(context) ? 16 : 0),
      child: Column(children: [
        if (!controller.responsiveUtils.isDesktop(context))
          Obx(() => UserInformationWidget(
            userName: controller.mailboxDashBoardController.accountId.value != null
              ? UserName(controller.mailboxDashBoardController.sessionCurrent!.getOwnEmailAddress())
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
        Obx(() {
          final linagoraApps = controller
              .mailboxDashBoardController
              .appGridDashboardController
              .listLinagoraApp;

          if (linagoraApps.isNotEmpty && !controller.responsiveUtils.isDesktop(context)) {
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
        const SizedBox(height: 8),
        const Divider(color: AppColor.colorDividerMailbox, height: 1),
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: controller.responsiveUtils.isWebDesktop(context) ? 0 : 12,
                  ),
                  child: Text(
                    AppLocalizations.of(context).folders,
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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
    );
    return Stack(
      children: [
        if (!PlatformInfo.isCanvasKit)
          ScrollbarListView(
            scrollController: controller.mailboxListScrollController,
            scrollBehavior: ScrollConfiguration.of(context).copyWith(
              physics: const BouncingScrollPhysics(),
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad
              },
              scrollbars: false
            ),
            child: RefreshIndicator(
              color: AppColor.primaryColor,
              onRefresh: controller.refreshAllMailbox,
              child: mailboxListWidget,
            ),
          )
        else
          ScrollbarListView(
            scrollController: controller.mailboxListScrollController,
            child: mailboxListWidget
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
            toggleMailboxCategories: controller.toggleMailboxCategories,
            padding: controller.responsiveUtils.isDesktop(context)
              ? null
              : const EdgeInsetsDirectional.only(start: 16)
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

  void _handleDragItemAccepted(
    DraggableEmailData draggableEmailData,
    PresentationMailbox presentationMailbox,
  ) {
    final mailboxPath = controller.findNodePath(presentationMailbox.id)
        ?? presentationMailbox.name?.name;
    log('MailboxView::_handleDragItemAccepted(): mailboxPath: $mailboxPath');
    if (mailboxPath != null) {
      presentationMailbox = presentationMailbox
        .toPresentationMailboxWithMailboxPath(mailboxPath);
    }

    if (draggableEmailData.isSelectAllEmailsEnabled) {
      controller
        .mailboxDashBoardController
        .dragAllSelectedEmailToMailboxAction(presentationMailbox);
    } else {
      controller
        .mailboxDashBoardController
        .dragSelectedMultipleEmailToMailboxAction(
          draggableEmailData.listEmails!,
          presentationMailbox,
        );
    }
  }
}