import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mixin/mailbox_widget_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_folder_tile_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/user_information_widget_builder.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/app_dashboard/app_list_dashboard_item.dart';
import 'package:tmail_ui_user/features/quotas/presentation/widget/quotas_footer_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class MailboxView extends GetWidget<MailboxController>
  with AppLoaderMixin,
    MailboxWidgetMixin {

  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  MailboxView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        elevation: _responsiveUtils.isDesktop(context) ? 0 : 16.0,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(children: [
            if (!_responsiveUtils.isDesktop(context)) _buildLogoApp(context),
            if (!_responsiveUtils.isDesktop(context))
              const Divider(
                  color: AppColor.colorDividerMailbox,
                  height: 0.5,
                  thickness: 0.2),
            Expanded(child: Container(
              padding: _getViewPadding(context),
              color: _responsiveUtils.isDesktop(context)
                  ? AppColor.colorBgDesktop
                  : Colors.white,
              child: Container(
                color: _responsiveUtils.isDesktop(context)
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

  EdgeInsets _getViewPadding(BuildContext context) {
    if (AppUtils.isDirectionRTL(context)) {
      return EdgeInsets.only(right: _responsiveUtils.isDesktop(context) ? 16 : 0);
    } else {
      return EdgeInsets.only(left: _responsiveUtils.isDesktop(context) ? 16 : 0);
    }
  }

  Widget _buildLogoApp(BuildContext context) {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          top: _responsiveUtils.isDesktop(context) ? 25 : 16,
          bottom: _responsiveUtils.isDesktop(context) ? 25 : 16,
          left: AppUtils.isDirectionRTL(context) ? 0 : _responsiveUtils.isDesktop(context) ? 32 : 16,
          right: AppUtils.isDirectionRTL(context) ? _responsiveUtils.isDesktop(context) ? 32 : 16 : 0
        ),
        child: Row(children: [
          (SloganBuilder(arrangedByHorizontal: true)
            ..setSloganText(AppLocalizations.of(context).app_name)
            ..setSloganTextAlign(TextAlign.center)
            ..setSloganTextStyle(const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))
            ..setSizeLogo(24)
            ..setLogo(_imagePaths.icLogoTMail))
          .build(),
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

  Widget _buildLoadingView() {
    return Obx(() => controller.viewState.value.fold(
      (failure) => const SizedBox.shrink(),
      (success) => success is LoadingState
        ? Padding(padding: const EdgeInsets.only(top: 16), child: loadingWidget)
        : const SizedBox.shrink()));
  } 

  Widget _buildListMailbox(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: controller.mailboxListScrollController,
          key: const PageStorageKey('mailbox_list'),
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.only(
            right: AppUtils.isDirectionRTL(context) ? 0 : _responsiveUtils.isDesktop(context) ? 16 : 0,
            left: AppUtils.isDirectionRTL(context) ? _responsiveUtils.isDesktop(context) ? 16 : 0 : 0
          ),
          child: Column(children: [
            if (!_responsiveUtils.isDesktop(context))
              _buildUserInformation(context),
            _buildLoadingView(),
            AppConfig.appGridDashboardAvailable && _responsiveUtils.isWebNotDesktop(context)
              ? Column(children: [
                  _buildAppGridDashboard(context),
                  const SizedBox(height: 8),
                  const Divider(color: AppColor.colorDividerMailbox, height: 0.5, thickness: 0.2),
                  const SizedBox(height: 8),
                ])
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
              padding: EdgeInsets.only(
                left: AppUtils.isDirectionRTL(context) ? 0 : _responsiveUtils.isDesktop(context) ? 0 : 12,
                right: AppUtils.isDirectionRTL(context) ? _responsiveUtils.isDesktop(context) ? 0 : 12 : 0,
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
                    padding: EdgeInsets.only(
                      right: AppUtils.isDirectionRTL(context) ? 0 : _responsiveUtils.isDesktop(context) ? 0 : 12,
                      left: AppUtils.isDirectionRTL(context) ? _responsiveUtils.isDesktop(context) ? 0 : 12 : 0,
                    ),
                    child: Row(
                      children: [
                        buildIconWeb(
                          minSize: 40,
                          iconPadding: EdgeInsets.zero,
                          icon: SvgPicture.asset(
                            _imagePaths.icSearchBar,
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
                              _imagePaths.icAddNewFolder,
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

  Widget _buildUserInformation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 10, right: 16),
          child: Obx(() => UserInformationWidgetBuilder(
            _imagePaths,
            controller.mailboxDashBoardController.userProfile.value,
            subtitle: AppLocalizations.of(context).manage_account,
            onSubtitleClick: () => controller.mailboxDashBoardController.goToSettings()),
          )),
        const Divider(color: AppColor.colorDividerMailbox, height: 0.5, thickness: 0.2)
      ]),
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
            right: _responsiveUtils.isDesktop(context) ? 0 : 16,
            left: _responsiveUtils.isDesktop(context) ? 0 : 16),
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
            _responsiveUtils,
            _imagePaths,
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
          isDirectionRTL: AppUtils.isDirectionRTL(context),
          isExpanded: mailboxNode.expandMode == ExpandMode.EXPAND,
          paddingChild: EdgeInsets.only(
            left: AppUtils.isDirectionRTL(context) ? 0 : 14,
            right: AppUtils.isDirectionRTL(context) ? 14 : 0,
          ),
          parent: Obx(() => (MailBoxFolderTileBuilder(
                context,
                _imagePaths,
                mailboxNode,
                responsiveUtils: _responsiveUtils,
                lastNode: lastNode,
                mailboxNodeSelected: controller.mailboxDashBoardController.selectedMailbox.value)
            ..addOnClickOpenMailboxNodeAction((mailboxNode) => controller.openMailbox(context, mailboxNode.item))
            ..addOnClickExpandMailboxNodeAction((mailboxNode) =>
              controller.toggleMailboxFolder(mailboxNode, controller.mailboxListScrollController))
            ..addOnClickOpenMenuMailboxNodeAction((position, mailboxNode) {
              openMailboxMenuActionOnWeb(
                context,
                _imagePaths,
                _responsiveUtils,
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
              _imagePaths,
              mailboxNode,
              responsiveUtils: _responsiveUtils,
              lastNode: lastNode,
              mailboxNodeSelected: controller.mailboxDashBoardController.selectedMailbox.value)
          ..addOnClickOpenMailboxNodeAction((mailboxNode) => controller.openMailbox(context, mailboxNode.item))
          ..addOnClickOpenMenuMailboxNodeAction((position, mailboxNode) {
            openMailboxMenuActionOnWeb(
              context,
              _imagePaths,
              _responsiveUtils,
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

  Widget _buildAppGridDashboard(BuildContext context) {
    return Column(
      children: [
        _buildGoToApplicationsCategory(context, MailboxCategories.appGrid),
        AnimatedContainer(
          padding: const EdgeInsets.only(top: 8),
          duration: const Duration(milliseconds: 400),
          child: Obx(() {
            return controller.mailboxDashBoardController.appGridDashboardController.appDashboardExpandMode.value == ExpandMode.EXPAND
              ? _buildAppGridInMailboxView(context)
              : const Offstage();
          })
        )
    ]);
  }

  Widget _buildGoToApplicationsCategory(BuildContext context, MailboxCategories categories) {
    return Padding(
      padding: EdgeInsets.only(
        top: 8,
        left: _responsiveUtils.isDesktop(context) ? 0 : 36,
        right: _responsiveUtils.isDesktop(context) ? 0 : 28
      ),
      child: Row(
        children: [
          buildIconWeb(
            splashRadius: 5,
            iconPadding: EdgeInsets.zero,
            minSize: 12,
            iconSize: 28,
            icon: SvgPicture.asset(
              _imagePaths.icAppDashboard,
              colorFilter: AppColor.primaryColor.asFilter(),
              fit: BoxFit.fill
            ),
            tooltip: AppLocalizations.of(context).appGridTittle),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(categories.getTitle(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColor.colorTextButton,
                  fontWeight: FontWeight.w500
                )
              )
            )
          ),
          buildIconWeb(
            splashRadius: 5,
            iconPadding: EdgeInsets.zero,
            minSize: 12,
            iconSize: 28,
            icon: Obx(() => SvgPicture.asset(
              controller.mailboxDashBoardController.appGridDashboardController.appDashboardExpandMode.value == ExpandMode.COLLAPSE
                ? _imagePaths.icCollapseFolder
                : _imagePaths.icExpandFolder,
              colorFilter: AppColor.primaryColor.asFilter(),
              fit: BoxFit.fill
            )),
            tooltip: AppLocalizations.of(context).appGridTittle,
            onTap: () => controller.toggleMailboxCategories(categories)
          ),
        ]
      )
    );
  }

  Widget _buildAppGridInMailboxView(BuildContext context) {
    return Obx(() {
      final linagoraApps = controller.mailboxDashBoardController.appGridDashboardController.linagoraApplications.value;
      if (linagoraApps != null && linagoraApps.apps.isNotEmpty) {
        return ListView.builder(
          shrinkWrap: true,
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