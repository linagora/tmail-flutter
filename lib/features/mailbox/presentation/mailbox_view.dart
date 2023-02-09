import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/context_item_mailbox_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/bottom_bar_selection_mailbox_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_bottom_sheet_action_tile_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_folder_tile_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_search_tile_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/user_information_widget_builder.dart';
import 'package:tmail_ui_user/features/quotas/presentation/widget/quotas_footer_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/search_app_bar_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MailboxView extends GetWidget<MailboxController> {

  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  MailboxView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeUtils.setStatusBarTransparentColor();

    return SafeArea(bottom: false, left: false, right: false,
        top: _responsiveUtils.isMobile(context),
        child: ClipRRect(
            borderRadius: _responsiveUtils.isPortraitMobile(context)
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
                            Obx(() => controller.isSearchActive()
                                ? SafeArea(bottom: false, top: false, right: false,
                                      child: _buildInputSearchFormWidget(context))
                                : const SizedBox.shrink()),
                            Expanded(child: Obx(() => Container(
                              color: controller.isSearchActive()
                                  ? Colors.white
                                  : AppColor.colorBgMailbox,
                              child: RefreshIndicator(
                                color: AppColor.primaryColor,
                                onRefresh: () async => controller.refreshAllMailbox(),
                                child: SafeArea(
                                  top: false,
                                  right: false,
                                  bottom: false,
                                  child: controller.isSearchActive()
                                      ? _buildListMailboxSearched(context)
                                      : _buildListMailbox(context)
                                )
                              ),
                            ))),
                            Obx(() => controller.isSelectionEnabled()
                                ? _buildOptionSelectionMailbox(context)
                                : const SizedBox.shrink()),
                          ]),
                        ),
                        Obx(() => controller.isMailboxListScrollable.isTrue
                          && !controller.isSearchActive()
                          && !controller.isSelectionEnabled()
                            ? const QuotasFooterWidget()
                            : const SizedBox.shrink(),
                        ),
                        Obx(() {
                          final appInformation = controller.mailboxDashBoardController.appInformation.value;
                          if (appInformation != null
                              && !controller.isSearchActive()
                              && !controller.isSelectionEnabled()) {
                            if (_responsiveUtils.isLandscapeMobile(context)) {
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
          padding: EdgeInsets.only(top: _responsiveUtils.isMobile(context) ? 10 : 30, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: _buildCloseScreenButton(context)),
              Expanded(child: Text(
                AppLocalizations.of(context).folders,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 21, color: Colors.black, fontWeight: FontWeight.bold))),
              Obx(() {
                if (controller.isSearchActive()) {
                  return controller.listMailboxSearched.isNotEmpty
                      ? _buildEditMailboxButton(context, controller.isSelectionEnabled())
                      : const SizedBox(width: 60);
                } else {
                  return _buildEditMailboxButton(context, controller.isSelectionEnabled());
                }
              })
            ]
          )
        ),
        if (!_responsiveUtils.isTabletLarge(context))
          const Divider(color: AppColor.colorDividerMailbox, height: 0.5, thickness: 0.2),
      ]
    );
  }

  Widget _buildCloseScreenButton(BuildContext context) {
    return buildIconWeb(
        icon: SvgPicture.asset(_imagePaths.icCloseMailbox, width: 28, height: 28, fit: BoxFit.fill),
        tooltip: AppLocalizations.of(context).close,
        onTap: () => controller.closeMailboxScreen(context));
  }

  Widget _buildEditMailboxButton(BuildContext context, bool isSelectionEnabled) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
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

  Widget _buildUserInformation(BuildContext context) {
    return Column(children: [
      Padding(
        padding: EdgeInsets.only(
          left: _responsiveUtils.isLandscapeMobile(context) ? 0 : 16,
          right: 16),
        child: UserInformationWidgetBuilder(
          _imagePaths,
          controller.mailboxDashBoardController.userProfile.value,
          subtitle: AppLocalizations.of(context).manage_account,
          onSubtitleClick: () => controller.mailboxDashBoardController.goToSettings())),
      const Divider(color: AppColor.colorDividerMailbox, height: 0.5, thickness: 0.2)
    ]);
  }

  Widget _buildLoadingView() {
    return Obx(() => controller.viewState.value.fold(
      (failure) => const SizedBox.shrink(),
      (success) => success is LoadingState
        ? const Center(child: Padding(
            padding: EdgeInsets.only(top: 16),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CupertinoActivityIndicator(color: AppColor.colorTextButton))))
        : const SizedBox.shrink()));
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
            if (controller.isSelectionEnabled() && _responsiveUtils.isLandscapeMobile(context)) {
              return const SizedBox.shrink();
            }
            return _buildUserInformation(context);
          }),
          _buildLoadingView(),
          Obx(() => controller.defaultMailboxTree.value.root.childrenItems?.isNotEmpty ?? false
              ? _buildMailboxCategory(context, MailboxCategories.exchange, controller.defaultMailboxTree.value.root)
              : const SizedBox.shrink()),
          const Divider(color: AppColor.colorDividerMailbox, height: 0.5, thickness: 0.2),
          const SizedBox(height: 12),
          Container(
            margin: EdgeInsets.only(
              left: _responsiveUtils.isLandscapeMobile(context) ? 0 : 8,
              right: 16),
            padding: const EdgeInsets.only(left: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context).mailBoxes,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      buildIconWeb(
                        minSize: 40,
                        iconPadding: EdgeInsets.zero,
                        icon: SvgPicture.asset(
                          _imagePaths.icSearchBar,
                          color: AppColor.colorTextButton,
                          fit: BoxFit.fill
                        ),
                          tooltip: AppLocalizations.of(context).search_folder,
                        onTap: controller.enableSearch
                      ),
                      buildIconWeb(
                          minSize: 40,
                          iconSize: 20,
                          iconPadding: EdgeInsets.zero,
                          splashRadius: 15,
                          icon: SvgPicture.asset(_imagePaths.icAddNewFolder, color: AppColor.colorTextButton, fit: BoxFit.fill),
                          tooltip: AppLocalizations.of(context).new_mailbox,
                          onTap: () => controller.goToCreateNewMailboxView(context)),
                    ],
                  ),
                ]),
            ),
            const SizedBox(height: 8),
            Obx(() => controller.personalMailboxTree.value.root.childrenItems?.isNotEmpty ?? false
                ? _buildMailboxCategory(context, MailboxCategories.personalMailboxes, controller.personalMailboxTree.value.root)
                : const SizedBox.shrink()),
            const SizedBox(height: 8),
            Obx(() => controller.teamMailboxesTree.value.root.childrenItems?.isNotEmpty ?? false
                ? _buildMailboxCategory(context, MailboxCategories.teamMailboxes, controller.teamMailboxesTree.value.root)
                : const SizedBox.shrink()),
          Obx(() => controller.isMailboxListScrollable.isFalse
            && !controller.isSearchActive()
            && !controller.isSelectionEnabled()
              ? const QuotasFooterWidget()
              : const SizedBox.shrink(),
          ),
        ])
      ),
    );
  }

  Widget _buildHeaderMailboxCategory(BuildContext context, MailboxCategories categories) {
    return Padding(
        padding: EdgeInsets.only(
            right: _responsiveUtils.isLandscapeMobile(context) ? 8 : 28,
            left: 4),
        child: Row(children: [
         buildIconWeb(
              minSize: 40,
              iconSize: 20,
              iconPadding: EdgeInsets.zero,
              splashRadius: 15,
              icon: SvgPicture.asset(
                  categories.getExpandMode(controller.mailboxCategoriesExpandMode.value) == ExpandMode.EXPAND
                    ? _imagePaths.icExpandFolder
                    : _imagePaths.icCollapseFolder,
                  color: AppColor.primaryColor, fit: BoxFit.fill),
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
        margin: EdgeInsets.only(
            left: _responsiveUtils.isLandscapeMobile(context) ? 0 : 8,
            right: 16),
        padding: const EdgeInsets.only(left: 12),
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

  MailboxActions _mailboxActionForSpam() {
    return controller.mailboxDashBoardController.enableSpamReport
      ? MailboxActions.disableSpamReport
      : MailboxActions.enableSpamReport;
  }

  List<MailboxActions> _listActionForMailbox(PresentationMailbox mailbox) {
    return [
      if (BuildUtils.isWeb)
        MailboxActions.openInNewTab,
      if (mailbox.isSpam)
        _mailboxActionForSpam(),
      MailboxActions.markAsRead,
      MailboxActions.move,
      MailboxActions.rename,
      MailboxActions.delete,
      if (mailbox.isSupportedDisableMailbox)
        MailboxActions.disableMailbox
    ];
  }

  void _openBottomSheetMailboxMenuAction(BuildContext context, PresentationMailbox mailbox) {
    final mailboxActionsSupported = _listActionForMailbox(mailbox);

    final listContextMailboxPopupMenuItemAction = mailboxActionsSupported
      .map((action) => ContextMenuItemMailboxAction(action, action.getContextMenuItemState(mailbox)))
      .toList();

    controller.openContextMenuAction(
      context,
      _bottomSheetMailboxActionTiles(
        context,
        mailbox,
        listContextMailboxPopupMenuItemAction
      )
    );
  }

  List<Widget> _bottomSheetMailboxActionTiles(
    BuildContext context,
    PresentationMailbox mailbox,
    List<ContextMenuItemMailboxAction> contextMenuActions
  ) {
    return contextMenuActions
      .map((action) => _openBottomSheetMailboxMenuActionTile(context, action, mailbox))
      .toList();
  }

  Widget _openBottomSheetMailboxMenuActionTile(
    BuildContext context,
    ContextMenuItemMailboxAction contextMenuItem,
    PresentationMailbox mailbox
  ) {
    return (MailboxBottomSheetActionTileBuilder(
        Key('${contextMenuItem.action.name}_action'),
        SvgPicture.asset(
            contextMenuItem.action.getContextMenuIcon(_imagePaths),
            color: AppColor.primaryColor),
        contextMenuItem.action.getTitleContextMenu(context),
        mailbox,
        absorbing: !contextMenuItem.isActivated,
        opacity: !contextMenuItem.isActivated)
      ..onActionClick((mailbox) => controller.handleMailboxAction(context, contextMenuItem.action, mailbox)))
    .build();
  }
  
  List<Widget> _buildListChildTileWidget(BuildContext context, MailboxNode parentNode, {MailboxNode? lastNode}) {
    return parentNode.childrenItems
      ?.map((mailboxNode) => mailboxNode.hasChildren()
          ? TreeViewChild(
                  context,
                  key: const Key('children_tree_mailbox_child'),
                  isExpanded: mailboxNode.expandMode == ExpandMode.EXPAND,
                  parent: Obx(() => (MailBoxFolderTileBuilder(context, _imagePaths, mailboxNode, lastNode: lastNode,
                          allSelectMode: controller.currentSelectMode.value)
                      ..addOnLongPressMailboxNodeAction((mailboxNode) => _openBottomSheetMailboxMenuAction(context, mailboxNode.item))
                      ..addOnClickOpenMailboxNodeAction((mailboxNode) => controller.openMailbox(context, mailboxNode.item))
                      ..addOnClickExpandMailboxNodeAction((mailboxNode) => controller.toggleMailboxFolder(mailboxNode))
                      ..addOnSelectMailboxNodeAction((mailboxNode) => controller.selectMailboxNode(mailboxNode)))
                    .build()),
                  children: _buildListChildTileWidget(context, mailboxNode)
              ).build()
          : Obx(() => (MailBoxFolderTileBuilder(context, _imagePaths, mailboxNode, lastNode: lastNode,
                  allSelectMode: controller.currentSelectMode.value)
              ..addOnLongPressMailboxNodeAction((mailboxNode) => _openBottomSheetMailboxMenuAction(context, mailboxNode.item))
              ..addOnClickOpenMailboxNodeAction((mailboxNode) => controller.openMailbox(context, mailboxNode.item))
              ..addOnSelectMailboxNodeAction((mailboxNode) => controller.selectMailboxNode(mailboxNode)))
            .build())
      ).toList() ?? <Widget>[];
  }

  Widget _buildInputSearchFormWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: Row(
          children: [
            _buildBackSearchButton(context),
            Expanded(child: (SearchAppBarWidget(
                  _imagePaths,
                  controller.searchQuery.value,
                  controller.searchFocus,
                  controller.searchInputController,
                  hasBackButton: false,
                  hasSearchButton: true)
              ..addPadding(EdgeInsets.zero)
              ..setMargin(const EdgeInsets.only(right: 16))
              ..addDecoration(BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColor.colorBgSearchBar))
              ..addIconClearText(SvgPicture.asset(_imagePaths.icClearTextSearch, width: 18, height: 18, fit: BoxFit.fill))
              ..setHintText(AppLocalizations.of(context).hint_search_mailboxes)
              ..addOnClearTextSearchAction(() => controller.clearSearchText())
              ..addOnTextChangeSearchAction((query) => controller.searchMailbox(query))
              ..addOnSearchTextAction((query) => controller.searchMailbox(query)))
            .build())
          ]
      )
    );
  }

  Widget _buildBackSearchButton(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: _responsiveUtils.isLandscapeMobile(context) ? 0 : 5),
        child: buildIconWeb(
          onTap: () => controller.disableSearch(),
          icon: SvgPicture.asset(_imagePaths.icBack, color: AppColor.colorTextButton),
        ));
  }

  Widget _buildListMailboxSearched(BuildContext context) {
    return Obx(() => Container(
        margin: _responsiveUtils.isDesktop(context)
            ? const EdgeInsets.only(left: 16, right: 16)
            : EdgeInsets.zero,
        decoration: _responsiveUtils.isDesktop(context)
            ? BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.white)
            : null,
        child: ListView.builder(
            padding: EdgeInsets.only(left: _responsiveUtils.isLandscapeMobile(context) ? 0 : 16, right: 8),
            key: const Key('list_mailbox_searched'),
            itemCount: controller.listMailboxSearched.length,
            shrinkWrap: true,
            primary: false,
            itemBuilder: (context, index) =>
                Obx(() => (MailboxSearchTileBuilder(
                        context,
                        _imagePaths,
                        _responsiveUtils,
                        controller.listMailboxSearched[index],
                        allSelectMode: controller.currentSelectMode.value,
                        lastMailboxIdInSearchedList: controller.listMailboxSearched.last.id)
                    ..addOnOpenMailboxAction((mailbox) => controller.openMailbox(context, mailbox))
                    ..addOnSelectMailboxAction((mailbox) => controller.selectMailboxSearched(context, mailbox)))
                  .build())
        )
    ));
  }

  Widget _buildOptionSelectionMailbox(BuildContext context) {
    return Column(children: [
      const Divider(color: AppColor.lineItemListColor, height: 1, thickness: 0.2),
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: (BottomBarSelectionMailboxWidget(context,
                  _imagePaths,
                  controller.listMailboxSelected)
              ..addOnMailboxActionsClick((actions, listMailboxSelected) =>
                  controller.pressMailboxSelectionAction(
                      context,
                      actions,
                      listMailboxSelected)))
            .build()))
    ]);
  }

  Widget _buildVersionInformation(BuildContext context, PackageInfo packageInfo) {
    return SafeArea(
      top: false,
      child: Container(
        color: AppColor.colorBgMailbox,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Text(
          '${AppLocalizations.of(context).version} ${packageInfo.version}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: AppColor.colorContentEmail, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}