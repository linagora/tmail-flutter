import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/bottom_bar_selection_mailbox_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_folder_tile_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_search_tile_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/user_information_widget_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/search_app_bar_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MailboxView extends GetWidget<MailboxController> {

  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  @override
  Widget build(BuildContext context) {
    return _buildBodyMailbox(context);
  }

  Widget _buildBodyMailbox(BuildContext context) {
    return SafeArea(bottom: false, left: false, right: false, top: _responsiveUtils.isMobile(context),
        child: ClipRRect(
            borderRadius: _responsiveUtils.isMobile(context) && _responsiveUtils.isPortrait(context)
              ? BorderRadius.only(topRight: Radius.circular(14), topLeft: Radius.circular(14))
              : BorderRadius.all(Radius.zero),
            child: Drawer(
                child: Scaffold(
                  backgroundColor: _responsiveUtils.isDesktop(context) ? AppColor.colorBgDesktop : Colors.white,
                  body: Stack(children: [
                    Column(children: [
                      if (_responsiveUtils.isDesktop(context)) _buildLogoApp(context),
                      if (!_responsiveUtils.isDesktop(context)) _buildHeaderMailbox(context),
                      if (_responsiveUtils.isDesktop(context)) _buildComposerButton(context),
                      Obx(() => !controller.isSearchActive() && _responsiveUtils.isDesktop(context)
                          ? Row(children: [
                              Expanded(child: _buildSearchBarWidget(context)),
                              _buildAddNewFolderButton(context),
                            ])
                          : SizedBox.shrink()),
                      Obx(() => controller.isSearchActive()
                          ? SafeArea(bottom: false, top: false, right: false, child: _buildInputSearchFormWidget(context))
                          : SizedBox.shrink()),
                      Expanded(child: Obx(() => Container(
                        color: _responsiveUtils.isDesktop(context)
                            ? Colors.transparent
                            : controller.isSearchActive() ? Colors.white : AppColor.colorBgMailbox,
                        child: RefreshIndicator(
                            color: AppColor.primaryColor,
                            onRefresh: () async => controller.refreshAllMailbox(),
                            child: controller.isSearchActive()
                                ? SafeArea(
                                    bottom: !controller.isSelectionEnabled(),
                                    top: false,
                                    right: false,
                                    child: _buildListMailboxSearched(context))
                                : SafeArea(
                                    bottom: !controller.isSelectionEnabled(),
                                    right: false,
                                    child: Padding(
                                        padding: EdgeInsets.only(bottom: (_responsiveUtils.isMobile(context) && _responsiveUtils.isLandscape(context)) || controller.isSelectionEnabled() ? 0 : 55),
                                        child: _buildListMailbox(context)))
                        ),
                      ))),
                      Obx(() => controller.isSelectionEnabled() ? _buildOptionSelectionMailbox(context) : SizedBox.shrink()),
                    ]),
                    Obx(() {
                      if (controller.mailboxDashBoardController.appInformation.value != null
                          && !controller.isSearchActive() && !controller.isSelectionEnabled()) {
                        if (_responsiveUtils.isMobile(context) && _responsiveUtils.isLandscape(context)) {
                          return SizedBox.shrink();
                        }
                        return Align(
                            alignment: Alignment.bottomCenter,
                            child: _buildVersionInformation(context, controller.mailboxDashBoardController.appInformation.value!));
                      } else {
                        return SizedBox.shrink();
                      }
                    })
                  ]),
                )
            )
        )
    );
  }

  Widget _buildLogoApp(BuildContext context) {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.only(left: 32, top: 20, bottom: 24),
        child: (SloganBuilder(arrangedByHorizontal: true)
            ..setSloganText(AppLocalizations.of(context).app_name)
            ..setSloganTextAlign(TextAlign.center)
            ..setSloganTextStyle(TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold))
            ..setSizeLogo(24)
            ..setLogo(_imagePaths.icLogoTMail))
          .build());
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
              _responsiveUtils.isMobile(context) || _responsiveUtils.isTablet(context)
                  ? Padding(padding: EdgeInsets.only(left: 10), child: _buildCloseScreenButton(context))
                  : SizedBox(width: 50),
              Obx(() {
                if (controller.isSearchActive()) {
                  return controller.listMailboxSearched.isNotEmpty
                      ? SizedBox(width: controller.isSelectionEnabled() ? 49 : 40)
                      : SizedBox.shrink();
                } else {
                  return SizedBox(width: controller.isSelectionEnabled() ? 49 : 40);
                }
              }),
              Expanded(child: Text(
                AppLocalizations.of(context).folders,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 21, color: Colors.black, fontWeight: FontWeight.bold))),
              Obx(() {
                if (controller.isSearchActive()) {
                  return controller.listMailboxSearched.isNotEmpty
                      ? _buildEditMailboxButton(context, controller.isSelectionEnabled())
                      : SizedBox(width: 25);
                } else {
                  return _buildEditMailboxButton(context, controller.isSelectionEnabled());
                }
              }),
              Padding(padding: EdgeInsets.only(right: 5), child: _buildAddNewFolderButton(context)),
            ]
          )
        ),
        if (!_responsiveUtils.isTabletLarge(context))
          Divider(color: AppColor.colorDividerMailbox, height: 0.5, thickness: 0.2),
      ]
    );
  }

  Widget _buildComposerButton(BuildContext context) {
    return Row(children: [
      Expanded(child: Container(
          padding: EdgeInsets.only(top: 16, left: 20),
          color: AppColor.colorBgDesktop,
          alignment: Alignment.centerLeft,
          child: (ButtonBuilder(_imagePaths.icCompose)
              ..key(Key('button_compose_email'))
              ..decoration(BoxDecoration(borderRadius: BorderRadius.circular(25), color: AppColor.colorTextButton))
              ..paddingIcon(EdgeInsets.only(right: 8))
              ..iconColor(Colors.white)
              ..maxWidth(140)
              ..size(20)
              ..radiusSplash(10)
              ..padding(EdgeInsets.symmetric(vertical: 13))
              ..textStyle(TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500))
              ..onPressActionClick(() => controller.mailboxDashBoardController.composeEmailAction())
              ..text(AppLocalizations.of(context).compose, isVertical: false))
            .build())
      ),
      Obx(() {
        if (controller.isSearchActive()) {
          return controller.listMailboxSearched.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: _buildEditMailboxButton(context, controller.isSelectionEnabled()))
              : SizedBox.shrink();
        } else {
          return Padding(
              padding: EdgeInsets.only(top: 16),
              child: _buildEditMailboxButton(context, controller.isSelectionEnabled()));
        }
      })
    ]);
  }

  Widget _buildCloseScreenButton(BuildContext context) {
    return buildIconWeb(
        icon: SvgPicture.asset(_imagePaths.icCloseMailbox, width: 28, height: 28, fit: BoxFit.fill),
        tooltip: AppLocalizations.of(context).close,
        onTap: () => controller.closeMailboxScreen(context));
  }

  Widget _buildAddNewFolderButton(BuildContext context) {
    return buildIconWeb(
        icon: SvgPicture.asset(_imagePaths.icAddNewFolder, width: 28, height: 24, color: AppColor.colorTextButton, fit: BoxFit.fill),
        tooltip: AppLocalizations.of(context).new_mailbox,
        onTap: () => controller.goToCreateNewMailboxView());
  }

  Widget _buildEditMailboxButton(BuildContext context, bool isSelectionEnabled) {
    return Material(
        shape: CircleBorder(),
        color: Colors.transparent,
        child: TextButton(
            child: Text(
              !isSelectionEnabled ? AppLocalizations.of(context).edit : AppLocalizations.of(context).cancel,
              style: TextStyle(fontSize: 17, color: AppColor.colorTextButton, fontWeight: FontWeight.normal)),
            onPressed: () => !isSelectionEnabled
                ? controller.enableSelectionMailbox()
                : controller.disableSelectionMailbox()
        )
    );
  }

  Widget _buildUserInformation(BuildContext context) {
    return Container(
      child: Column(children: [
        Padding(
          padding: EdgeInsets.only(
            left: _responsiveUtils.isMobile(context) && _responsiveUtils.isLandscape(context) ? 0 : 16,
            right: 16),
          child: (UserInformationWidgetBuilder(_imagePaths, context, controller.mailboxDashBoardController.userProfile.value)
                ..addOnLogoutAction(() => controller.mailboxDashBoardController.logoutAction()))
              .build()),
        Divider(color: AppColor.colorDividerMailbox, height: 0.5, thickness: 0.2)
      ]),
    );
  }

  Widget _buildSearchBarWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: _responsiveUtils.isDesktop(context) ? 16 : 12,
          bottom: 16,
          left: _responsiveUtils.isMobile(context) && _responsiveUtils.isLandscape(context) ? 0 : 16,
          right: 16),
      child: (SearchBarView(_imagePaths)
          ..hintTextSearch(AppLocalizations.of(context).hint_search_mailboxes)
          ..addOnOpenSearchViewAction(() => controller.enableSearch()))
        .build());
  }

  Widget _buildLoadingView() {
    return Obx(() => controller.viewState.value.fold(
      (failure) => SizedBox.shrink(),
      (success) => success is LoadingState
        ? Center(child: Padding(
            padding: EdgeInsets.only(top: 16),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CupertinoActivityIndicator(color: AppColor.colorTextButton))))
        : SizedBox.shrink()));
  }

  Widget _buildListMailbox(BuildContext context) {
    return ListView(
      controller: controller.mailboxListScrollController,
      key: PageStorageKey('mailbox_list'),
      primary: false,
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: controller.isSelectionEnabled() ? 16 : 0),
      children: [
        Obx(() {
          if ((controller.isSelectionEnabled()
              && _responsiveUtils.isMobile(context)
              && _responsiveUtils.isLandscape(context))
              || _responsiveUtils.isDesktop(context)) {
            return SizedBox.shrink();
          }
          return _buildUserInformation(context);
        }),
        if (!_responsiveUtils.isDesktop(context)) _buildSearchBarWidget(context),
        _buildLoadingView(),
        Obx(() => controller.defaultMailboxTree.value.root.childrenItems?.isNotEmpty ?? false
          ? _buildMailboxCategory(context, MailboxCategories.exchange, controller.defaultMailboxTree.value.root)
          : SizedBox.shrink()),
        SizedBox(height: 12),
        Obx(() => controller.folderMailboxTree.value.root.childrenItems?.isNotEmpty ?? false
          ? _buildMailboxCategory(context, MailboxCategories.folders, controller.folderMailboxTree.value.root)
          : SizedBox.shrink()),
      ]
    );
  }

  Widget _buildHeaderMailboxCategory(BuildContext context, MailboxCategories categories) {
    return Padding(
        padding: EdgeInsets.only(
            left: _responsiveUtils.isMobile(context) && _responsiveUtils.isLandscape(context) ? 8 : 28,
            right: 16),
        child: Row(children: [
          Expanded(child: Text(categories.getTitle(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold))),
          buildIconWeb(
              icon: SvgPicture.asset(
                  categories.getExpandMode(controller.mailboxCategoriesExpandMode.value) == ExpandMode.EXPAND
                    ? _imagePaths.icExpandFolder
                    : _imagePaths.icCollapseFolder,
                  color: AppColor.primaryColor, fit: BoxFit.fill),
              tooltip: AppLocalizations.of(context).collapse,
              onTap: () => controller.toggleMailboxCategories(categories))
        ]));
  }

  Widget _buildBodyMailboxCategory(BuildContext context, MailboxCategories categories, MailboxNode mailboxNode) {
    final lastNode = mailboxNode.childrenItems?.last;

    return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.white),
        margin: EdgeInsets.only(
            left: _responsiveUtils.isMobile(context) && _responsiveUtils.isLandscape(context) ? 0 : 16,
            right: 16),
        padding: EdgeInsets.only(left: 12, right: 8),
        child: TreeView(
            key: Key('${categories.keyValue}_mailbox_list'),
            children: _buildListChildTileWidget(context, mailboxNode, lastNode: lastNode)));
  }

  Widget _buildMailboxCategory(BuildContext context, MailboxCategories categories, MailboxNode mailboxNode) {
    return Column(children: [
      _buildHeaderMailboxCategory(context, categories),
      AnimatedContainer(
        duration: Duration(milliseconds: 400),
        child: categories.getExpandMode(controller.mailboxCategoriesExpandMode.value) == ExpandMode.EXPAND
            ? _buildBodyMailboxCategory(context, categories, mailboxNode)
            : Offstage())
    ]);
  }

  List<Widget> _buildListChildTileWidget(BuildContext context, MailboxNode parentNode, {MailboxNode? lastNode}) {
    return parentNode.childrenItems
      ?.map((mailboxNode) => mailboxNode.hasChildren()
          ? TreeViewChild(
                  context,
                  key: Key('children_tree_mailbox_child'),
                  isExpanded: mailboxNode.expandMode == ExpandMode.EXPAND,
                  parent: Obx(() => (MailBoxFolderTileBuilder(context, _imagePaths, mailboxNode, lastNode: lastNode,
                          allSelectMode: controller.currentSelectMode.value)
                      ..addOnOpenMailboxFolderClick((mailboxNode) => controller.openMailbox(context, mailboxNode.item))
                      ..addOnExpandFolderActionClick((mailboxNode) => controller.toggleMailboxFolder(mailboxNode))
                      ..addOnSelectMailboxFolderClick((mailboxNode) => controller.selectMailboxNode(mailboxNode)))
                    .build()),
                  children: _buildListChildTileWidget(context, mailboxNode)
              ).build()
          : Obx(() => (MailBoxFolderTileBuilder(context, _imagePaths, mailboxNode, lastNode: lastNode,
                  allSelectMode: controller.currentSelectMode.value)
              ..addOnOpenMailboxFolderClick((mailboxNode) => controller.openMailbox(context, mailboxNode.item))
              ..addOnSelectMailboxFolderClick((mailboxNode) => controller.selectMailboxNode(mailboxNode)))
            .build())
      ).toList() ?? <Widget>[];
  }

  Widget _buildInputSearchFormWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: 16),
      child: Row(
          children: [
            _buildBackSearchButton(context),
            Expanded(child: (SearchAppBarWidget(
                  context,
                  _imagePaths,
                  _responsiveUtils,
                  controller.searchQuery.value,
                  controller.searchFocus,
                  controller.searchInputController,
                  hasBackButton: false,
                  hasSearchButton: true)
              ..addPadding(EdgeInsets.zero)
              ..setMargin(EdgeInsets.only(right: 16))
              ..addDecoration(BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColor.colorBgSearchBar))
              ..addIconClearText(SvgPicture.asset(_imagePaths.icClearTextSearch, width: 20, height: 20, fit: BoxFit.fill))
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
        padding: EdgeInsets.only(left: 5),
        child: Material(
            shape: CircleBorder(),
            color: Colors.transparent,
            child: IconButton(
                splashRadius: 20,
                color: AppColor.colorTextButton,
                icon: SvgPicture.asset(_imagePaths.icBack, width: 20, height: 20, color: AppColor.colorTextButton, fit: BoxFit.fill),
                onPressed: () => controller.disableSearch(context)
            )
        ));
  }

  Widget _buildListMailboxSearched(BuildContext context) {
    return Obx(() => Container(
        margin: _responsiveUtils.isDesktop(context)
            ? EdgeInsets.only(left: 16, right: 16)
            : EdgeInsets.zero,
        decoration: _responsiveUtils.isDesktop(context)
            ? BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.white)
            : null,
        child: ListView.builder(
            padding: EdgeInsets.only(left: 16, right: 8),
            key: Key('list_mailbox_searched'),
            itemCount: controller.listMailboxSearched.length,
            shrinkWrap: true,
            primary: false,
            itemBuilder: (context, index) =>
                Obx(() => (MailboxSearchTileBuilder(
                        _imagePaths,
                        controller.listMailboxSearched[index],
                        allSelectMode: controller.currentSelectMode.value,
                        lastMailbox: controller.listMailboxSearched.last)
                    ..addOnOpenMailboxAction((mailbox) => controller.openMailbox(context, mailbox))
                    ..addOnSelectMailboxActionClick((mailbox) => controller.selectMailboxSearched(context, mailbox)))
                  .build())
        )
    ));
  }

  Widget _buildOptionSelectionMailbox(BuildContext context) {
    if (_responsiveUtils.isDesktop(context)) {
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColor.colorEmailAddressTag, spreadRadius: 1, blurRadius: 1, offset: Offset(0, 0.5))],
            color: Colors.white),
        margin: EdgeInsets.only(left: 10, bottom: 10, right: 10),
        padding: EdgeInsets.all(8),
        child: (BottomBarSelectionMailboxWidget(context, _imagePaths, controller.listMailboxSelected)
            ..addOnMailboxActionsClick((actions, listMailboxSelected) => controller.pressMailboxSelectionAction(context, actions, listMailboxSelected)))
          .build(),
      );
    } else {
      return Column(children: [
        Divider(color: AppColor.lineItemListColor, height: 1, thickness: 0.2),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: (BottomBarSelectionMailboxWidget(context, _imagePaths, controller.listMailboxSelected)
                ..addOnMailboxActionsClick((actions, listMailboxSelected) => controller.pressMailboxSelectionAction(context, actions, listMailboxSelected)))
              .build()))
      ]);
    }
  }

  Widget _buildVersionInformation(BuildContext context, PackageInfo packageInfo) {
    return SafeArea(child: Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Text(
        '${AppLocalizations.of(context).version} ${packageInfo.version}',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: AppColor.colorContentEmail, fontWeight: FontWeight.w500),
      ),
    ));
  }
}