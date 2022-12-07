import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_menu_widget_mixin.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/context_item_mailbox_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_bottom_sheet_action_tile_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_folder_tile_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_search_tile_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/user_information_widget_builder.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/app_dashboard/app_list_dashboard_item.dart';
import 'package:tmail_ui_user/features/quotas/presentation/widget/quotas_footer_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/search_app_bar_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class MailboxView extends GetWidget<MailboxController> with AppLoaderMixin, PopupMenuWidgetMixin {

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
              padding: EdgeInsets.only(
                  left: _responsiveUtils.isDesktop(context) ? 16 : 0),
              color: _responsiveUtils.isDesktop(context)
                  ? AppColor.colorBgDesktop
                  : Colors.white,
              child: Column(children: [
                if (_responsiveUtils.isDesktop(context))
                  _buildComposerButton(context),
                Obx(() => controller.isSearchActive()
                    ? _buildInputSearchFormWidget(context)
                    : const SizedBox.shrink()),
                Expanded(child: Obx(() {
                  return Container(
                    color: _responsiveUtils.isDesktop(context)
                        ? AppColor.colorBgDesktop
                        : Colors.white,
                    padding: EdgeInsets.zero,
                    margin: EdgeInsets.only(
                        top: _responsiveUtils.isDesktop(context) ? 16 : 0),
                    child: RefreshIndicator(
                        color: AppColor.primaryColor,
                        onRefresh: () async => controller.refreshAllMailbox(),
                        child: controller.isSearchActive()
                            ? _buildListMailboxSearched(
                                context, controller.listMailboxSearched)
                            : _buildListMailbox(context)),
                  );
                })),
              ]),
            )),
            const QuotasFooterWidget(),
          ]),
        )
    );
  }

  Widget _buildLogoApp(BuildContext context) {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.only(
            top: _responsiveUtils.isDesktop(context) ? 25 : 16,
            bottom: _responsiveUtils.isDesktop(context) ? 25 : 16,
            left: _responsiveUtils.isDesktop(context) ? 32 : 16),
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

  Widget _buildComposerButton(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(top: 16, right: 16),
        color: AppColor.colorBgDesktop,
        alignment: Alignment.centerLeft,
        child: (ButtonBuilder(_imagePaths.icComposeWeb)
            ..key(const Key('button_compose_email'))
            ..decoration(BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColor.colorTextButton,
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 12.0,
                    color: AppColor.colorShadowComposerButton
                  )
                ]))
            ..paddingIcon(const EdgeInsets.only(right: 8))
            ..iconColor(Colors.white)
            ..size(16)
            ..radiusSplash(10)
            ..padding(const EdgeInsets.symmetric(vertical: 8))
            ..textStyle(const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500))
            ..onPressActionClick(() => controller.mailboxDashBoardController.goToComposer(ComposerArguments()))
            ..text(AppLocalizations.of(context).compose, isVertical: false))
          .build());
  }

  Widget _buildSearchBarWidget(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 16, bottom: 16, right: 4, left: _responsiveUtils.isDesktop(context) ? 0 : 12),
        child: SearchBarView(
            _imagePaths,
            hintTextSearch: AppLocalizations.of(context).hint_search_mailboxes,
            onOpenSearchViewAction: controller.enableSearch));
  }

  Widget _buildLoadingView() {
    return Obx(() => controller.viewState.value.fold(
        (failure) => const SizedBox.shrink(),
        (success) => success is LoadingState
            ? Padding(padding: const EdgeInsets.only(top: 16), child: loadingWidget)
            : const SizedBox.shrink()));
  }

  Widget _buildListMailbox(BuildContext context) {
    return SingleChildScrollView(
        controller: controller.mailboxListScrollController,
        key: const PageStorageKey('mailbox_list'),
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.only(right: _responsiveUtils.isDesktop(context) ? 16 : 0),
        child: Column(children: [
          Obx(() {
            if (controller.isSelectionEnabled() || _responsiveUtils.isDesktop(context)) {
              return const SizedBox.shrink();
            }
            return _buildUserInformation(context);
          }),
          _buildLoadingView(),
          AppConfig.appGridDashboardAvailable && _responsiveUtils.isWebNotDesktop(context)
            ? Column(children: [
                _buildAppGridDashboard(context),
                const SizedBox(height: 8),
                const Divider(color: AppColor.colorDividerMailbox, height: 0.5, thickness: 0.2),
                const SizedBox(height: 8),
              ])
            : const SizedBox.shrink(),
          Obx(() => controller.defaultMailboxHasChild
              ? _buildMailboxCategory(context, MailboxCategories.exchange, controller.defaultRootNode)
              : const SizedBox.shrink()),
          const SizedBox(height: 8),
          const Divider(color: AppColor.colorDividerMailbox, height: 0.5, thickness: 0.2),
          const SizedBox(height: 8),
          _buildHeaderMailboxCategory(context, MailboxCategories.folders),
          Row(children: [
            Expanded(child: _buildSearchBarWidget(context)),
            Padding(
                padding: EdgeInsets.only(right: _responsiveUtils.isDesktop(context) ? 0 : 12),
                child: buildIconWeb(
                    minSize: 40,
                    iconPadding: EdgeInsets.zero,
                    splashRadius: 15,
                    icon: SvgPicture.asset(_imagePaths.icAddNewFolder, color: AppColor.colorTextButton, fit: BoxFit.fill),
                    tooltip: AppLocalizations.of(context).new_mailbox,
                    onTap: () => controller.goToCreateNewMailboxView(context))),
          ]),
          Obx(() => controller.folderMailboxHasChild
              ? _buildMailboxCategory(context, MailboxCategories.folders, controller.folderRootNode)
              : const SizedBox.shrink()),
        ])
    );
  }

  Widget _buildUserInformation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 10),
          child: UserInformationWidgetBuilder(
            _imagePaths,
            controller.mailboxDashBoardController.userProfile.value,
            subtitle: AppLocalizations.of(context).manage_account,
            onSubtitleClick: () => controller.mailboxDashBoardController.goToSettings())),
        const Divider(color: AppColor.colorDividerMailbox, height: 0.5, thickness: 0.2)
      ]),
    );
  }

  Widget _buildHeaderMailboxCategory(BuildContext context, MailboxCategories categories) {
    return Padding(
        padding: EdgeInsets.only(
            top: 10,
            left: _responsiveUtils.isDesktop(context) ? 0 : 16,
            right: _responsiveUtils.isDesktop(context) ? 0 : 16),
        child: Row(children: [
          buildIconWeb(
              splashRadius: 5,
              iconPadding: EdgeInsets.zero,
              minSize: 12,
              icon: SvgPicture.asset(
                  categories.getExpandMode(controller.mailboxCategoriesExpandMode.value) == ExpandMode.EXPAND
                      ? _imagePaths.icExpandFolder
                      : _imagePaths.icCollapseFolder,
                  color: AppColor.primaryColor,
                  fit: BoxFit.fill),
              tooltip: AppLocalizations.of(context).collapse,
              onTap: () => controller.toggleMailboxCategories(categories)),
          Expanded(child: Text(categories.getTitle(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  fontWeight: FontWeight.bold))),
        ]));
  }

  Widget _buildBodyMailboxCategory(BuildContext context,
      MailboxCategories categories, MailboxNode mailboxNode) {
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

  Widget _buildMailboxCategory(BuildContext context, MailboxCategories categories, MailboxNode mailboxNode) {
    if (categories == MailboxCategories.exchange) {
      return _buildBodyMailboxCategory(context, categories, mailboxNode);
    }
    return AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        child: categories.getExpandMode(controller.mailboxCategoriesExpandMode.value) == ExpandMode.EXPAND
            ? _buildBodyMailboxCategory(context, categories, mailboxNode)
            : const Offstage());
  }

  List<Widget> _buildListChildTileWidget(BuildContext context,
      MailboxNode parentNode, {MailboxNode? lastNode}) {
    return parentNode.childrenItems
        ?.map((mailboxNode) => mailboxNode.hasChildren()
          ? TreeViewChild(
                context,
                key: const Key('children_tree_mailbox_child'),
                isExpanded: mailboxNode.expandMode == ExpandMode.EXPAND,
                parent: Obx(() => (MailBoxFolderTileBuilder(context, _imagePaths, mailboxNode, lastNode: lastNode,
                        mailboxNodeSelected: controller.mailboxDashBoardController.selectedMailbox.value)
                    ..addOnOpenMailboxFolderClick((mailboxNode) =>
                        controller.openMailbox(context, mailboxNode.item))
                    ..addOnExpandFolderActionClick((mailboxNode) =>
                        controller.toggleMailboxFolder(mailboxNode))
                    ..addOnMenuActionClick((position, mailboxNode) =>
                        _openMailboxMenuAction(context, position, mailboxNode.item))
                    ..addOnSelectMailboxFolderClick((mailboxNode) =>
                        controller.selectMailboxNode(mailboxNode))
                    ..addOnDragItemAccepted(_handleDragItemAccepted))
                  .build()),
                children: _buildListChildTileWidget(context, mailboxNode)
            ).build()
          : Obx(() => (MailBoxFolderTileBuilder(context, _imagePaths, mailboxNode, lastNode: lastNode,
                  mailboxNodeSelected: controller.mailboxDashBoardController.selectedMailbox.value)
              ..addOnOpenMailboxFolderClick((mailboxNode) =>
                  controller.openMailbox(context, mailboxNode.item))
              ..addOnMenuActionClick((position, mailboxNode) =>
                  _openMailboxMenuAction(context, position, mailboxNode.item))
              ..addOnSelectMailboxFolderClick((mailboxNode) =>
                  controller.selectMailboxNode(mailboxNode))
              ..addOnDragItemAccepted(_handleDragItemAccepted))
            .build())
    ).toList() ?? <Widget>[];
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

  Widget _buildInputSearchFormWidget(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Transform(
          transform: Matrix4.translationValues(
              _responsiveUtils.isDesktop(context) ? -10.0 : 0.0,
              0.0,
              0.0),
          child: Row(
              children: [
                if (!_responsiveUtils.isDesktop(context))
                  const SizedBox(width: 10),
                buildIconWeb(
                    iconPadding: EdgeInsets.zero,
                    minSize: 40,
                    splashRadius: 15,
                    icon: SvgPicture.asset(_imagePaths.icBack, color: AppColor.colorTextButton),
                    onTap: () => controller.disableSearch()),
                Expanded(child: (SearchAppBarWidget(
                        _imagePaths,
                        controller.searchQuery.value,
                        controller.searchFocus,
                        controller.searchInputController,
                        hasBackButton: false,
                        hasSearchButton: true)
                    ..addPadding(EdgeInsets.zero)
                    ..setMargin(EdgeInsets.only(right: _responsiveUtils.isDesktop(context) ? 8 : 16))
                    ..addDecoration(BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColor.colorBgSearchBar))
                    ..addIconClearText(SvgPicture.asset(_imagePaths.icClearTextSearch, width: 16, height: 16, fit: BoxFit.fill))
                    ..setHintText(AppLocalizations.of(context).hint_search_mailboxes)
                    ..addOnClearTextSearchAction(() => controller.clearSearchText())
                    ..addOnTextChangeSearchAction((query) => controller.searchMailbox(query))
                    ..addOnSearchTextAction((query) => controller.searchMailbox(query)))
                  .build())
              ]
          ),
        )
    );
  }

  Widget _buildListMailboxSearched(BuildContext context, List<PresentationMailbox> listMailbox) {
    return Container(
        margin: EdgeInsets.zero,
        color: _responsiveUtils.isDesktop(context) ? AppColor.colorBgDesktop : Colors.white,
        child: ListView.builder(
            padding: EdgeInsets.only(
                right: 16,
                left: _responsiveUtils.isDesktop(context) ? 0 : 16,
                bottom: 16,
                top: _responsiveUtils.isDesktop(context) ? 0 : 16),
            key: const Key('list_mailbox_searched'),
            itemCount: listMailbox.length,
            shrinkWrap: true,
            primary: false,
            itemBuilder: (context, index) =>
                Obx(() => (MailboxSearchTileBuilder(
                      context,
                      _imagePaths,
                      _responsiveUtils,
                      listMailbox[index])
                  ..addOnDragItemAccepted(controller.mailboxDashBoardController.dragSelectedMultipleEmailToMailboxAction)
                  ..addOnOpenMailboxAction((mailbox) => controller.openMailbox(context, mailbox))
                  ..addOnMenuActionClick((position, mailbox) => _openMailboxMenuAction(context, position, mailbox))
                  ..addOnSelectMailboxActionClick((mailbox) => controller.selectMailboxSearched(context, mailbox)))
                .build()))
    );
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

  void _openMailboxMenuAction(
      BuildContext context,
      RelativeRect position,
      PresentationMailbox mailbox
  ) {
    final mailboxActionsSupported = [
      MailboxActions.openInNewTab,
      MailboxActions.markAsRead,
      MailboxActions.move,
      MailboxActions.rename,
      MailboxActions.delete
    ];

    final listContextMenuItemAction = mailboxActionsSupported
        .map((action) => ContextMenuItemMailboxAction(
            action,
            action.getContextMenuItemState(mailbox)))
        .toList();

    if (_responsiveUtils.isScreenWithShortestSide(context)) {
      controller.openContextMenuAction(
          context,
          _bottomSheetIdentityActionTiles(
              context,
              mailbox,
              listContextMenuItemAction));
    } else {
      controller.openPopupMenuAction(
          context,
          position,
          _popupMenuMailboxActionTiles(
              context,
              mailbox,
              listContextMenuItemAction));
    }
  }

  List<Widget> _bottomSheetIdentityActionTiles(
      BuildContext context,
      PresentationMailbox mailbox,
      List<ContextMenuItemMailboxAction> contextMenuActions
  ) {
    return contextMenuActions
        .map((action) => _mailboxContextMenuActionTile(context, action, mailbox))
        .toList();
  }

  Widget _mailboxContextMenuActionTile(
      BuildContext context,
      ContextMenuItemMailboxAction contextMenuItem,
      PresentationMailbox mailbox
  ) {
    return (MailboxBottomSheetActionTileBuilder(
            Key('${contextMenuItem.action.name}_action'),
            SvgPicture.asset(
                contextMenuItem.action.getContextMenuIcon(_imagePaths),
                color: contextMenuItem.action.getColorContextMenuIcon()),
            contextMenuItem.action.getTitleContextMenu(context),
            mailbox,
            absorbing: !contextMenuItem.isActivated,
            opacity: !contextMenuItem.isActivated)
        ..onActionClick((mailbox) =>
            controller.handleMailboxAction(context, contextMenuItem.action, mailbox)))
      .build();
  }

  List<PopupMenuEntry> _popupMenuMailboxActionTiles(
      BuildContext context,
      PresentationMailbox mailbox,
      List<ContextMenuItemMailboxAction> contextMenuActions
  ) {
    return contextMenuActions
        .map((action) => _mailboxPopupMenuActionTile(context, action, mailbox))
        .toList();
  }

  PopupMenuItem _mailboxPopupMenuActionTile(
      BuildContext context,
      ContextMenuItemMailboxAction contextMenuItem,
      PresentationMailbox mailbox
  ) {
    return PopupMenuItem(
        padding: EdgeInsets.zero,
        child: AbsorbPointer(
          absorbing: !contextMenuItem.isActivated,
          child: Opacity(
            opacity: contextMenuItem.isActivated ? 1.0 : 0.3,
            child: popupItem(contextMenuItem.action.getContextMenuIcon(_imagePaths),
                contextMenuItem.action.getTitleContextMenu(context),
                colorIcon: contextMenuItem.action.getColorContextMenuIcon(),
                styleName: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 17,
                    color: contextMenuItem.action.getColorContextMenuIcon()),
                onCallbackAction: () =>
                    controller.handleMailboxAction(context, contextMenuItem.action, mailbox)),
          ),
        ));
  }

  Widget _buildAppGridDashboard(BuildContext context) {
    return Column(
      children: [
        _buildGoToApplicationsCategory(context, MailboxCategories.appGrid),
        AnimatedContainer(
          padding: const EdgeInsets.only(top: 8),
          duration: const Duration(milliseconds: 400),
          child: controller.mailboxDashBoardController.appGridDashboardController.appDashboardExpandMode.value == ExpandMode.EXPAND
            ? _buildAppGridInMailboxView(context)
            : const Offstage())
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
              color: AppColor.primaryColor,
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
              color: AppColor.primaryColor,
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