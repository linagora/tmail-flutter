import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/bottom_bar_selection_mailbox_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_folder_tile_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_tile_builder.dart';
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
    return SafeArea(
        top: _responsiveUtils.isMobile(context) ? true : false,
        bottom: false,
        left: false,
        right: false,
        child: ClipRRect(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(_responsiveUtils.isMobile(context) ? 14 : 0),
                topLeft: Radius.circular(_responsiveUtils.isMobile(context) ? 14 : 0)),
            child: Drawer(
                child: Scaffold(
                  backgroundColor: _responsiveUtils.isDesktop(context) ? AppColor.colorBgDesktop : Colors.white,
                  body: Column(
                      children: [
                        if (_responsiveUtils.isDesktop(context))
                          Container(
                            color: Colors.white,
                            padding: EdgeInsets.only(left: 20, top: 20, bottom: 24),
                            child: (SloganBuilder(arrangedByHorizontal: true)
                                ..setSloganText(AppLocalizations.of(context).app_name)
                                ..setSloganTextAlign(TextAlign.center)
                                ..setSloganTextStyle(TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold))
                                ..setSizeLogo(28)
                                ..setLogo(_imagePaths.icLogoTMail))
                              .build()),
                        if (!_responsiveUtils.isDesktop(context)) _buildHeaderMailbox(context),
                        if (_responsiveUtils.isDesktop(context))
                          Row(children: [
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
                          ]),
                        Obx(() => !controller.isSearchActive() && _responsiveUtils.isDesktop(context)
                            ? Row(children: [
                                Expanded(child: _buildSearchBarWidget(context)),
                                buildIconWeb(
                                    icon: SvgPicture.asset(_imagePaths.icAddNewFolder, color: AppColor.colorTextButton, fit: BoxFit.fill),
                                    tooltip: AppLocalizations.of(context).new_mailbox,
                                    onTap: () => controller.goToCreateNewMailboxView()),
                              ])
                            : SizedBox.shrink()),
                        Obx(() => controller.isSearchActive() ? _buildInputSearchFormWidget(context) : SizedBox.shrink()),
                        Expanded(child: Obx(() => Container(
                          color: _responsiveUtils.isDesktop(context)
                            ? Colors.transparent
                            : controller.isSearchActive() ? Colors.white : AppColor.colorBgMailbox,
                          child: RefreshIndicator(
                              color: AppColor.primaryColor,
                              onRefresh: () async => controller.refreshAllMailbox(),
                              child: controller.isSearchActive()
                                  ? _buildListMailboxSearched(context, controller.listMailboxSearched)
                                  : _buildListMailbox(context)),
                        ))),
                        Obx(() => controller.isSelectionEnabled()
                            ? _buildOptionSelectionMailbox(context)
                            : SizedBox.shrink()),
                      ]
                  ),
                )
            )
        )
    );
  }

  Widget _buildHeaderMailbox(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
              top: _responsiveUtils.isMobile(context) ? 14 : 30,
              bottom: 10),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            !_responsiveUtils.isDesktop(context) && !_responsiveUtils.isTabletLarge(context)
                ? _buildCloseScreenButton(context)
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
              style: TextStyle(fontSize: 20, color: AppColor.colorNameEmail, fontWeight: FontWeight.w700))),
            Obx(() {
              if (controller.isSearchActive()) {
                return controller.listMailboxSearched.isNotEmpty
                    ? _buildEditMailboxButton(context, controller.isSelectionEnabled())
                    : SizedBox(width: 25);
              } else {
                return _buildEditMailboxButton(context, controller.isSelectionEnabled());
              }
            }),
            _buildAddNewFolderButton(context),
          ])),
        Divider(color: AppColor.colorDividerMailbox, height: 0.5, thickness: 0.2),
      ]
    );
  }

  Widget _buildCloseScreenButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16),
      child: IconButton(
        key: Key('mailbox_close_button'),
        onPressed: () => controller.closeMailboxScreen(context),
        icon: SvgPicture.asset(_imagePaths.icCloseMailbox, width: 30, height: 30, fit: BoxFit.fill)));
  }

  Widget _buildAddNewFolderButton(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(right: 10),
        child: IconButton(
            key: Key('create_new_mailbox_button'),
            onPressed: () => controller.goToCreateNewMailboxView(),
            icon: SvgPicture.asset(_imagePaths.icAddNewFolder, width: 30, height: 30, fit: BoxFit.fill)));
  }

  Widget _buildEditMailboxButton(BuildContext context, bool isSelectionEnabled) {
    return Material(
        shape: CircleBorder(),
        color: Colors.transparent,
        child: TextButton(
            child: Text(
              !isSelectionEnabled ? AppLocalizations.of(context).edit : AppLocalizations.of(context).cancel,
              style: TextStyle(fontSize: 17, color: AppColor.colorTextButton)),
            onPressed: () => !isSelectionEnabled
                ? controller.enableSelectionMailbox()
                : controller.disableSelectionMailbox()
        )
    );
  }

  Widget _buildUserInformationWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, top: 8.0, right: 16),
      child: Obx(() => (UserInformationWidgetBuilder(
          _imagePaths,
          context,
          controller.mailboxDashBoardController.userProfile.value)
        ..addOnLogoutAction(() => controller.logoutAction()))
      .build()));
  }

  Widget _buildSearchBarWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: _responsiveUtils.isDesktop(context) ? 16 : 12, bottom: 16, left: 16, right: 16),
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
      key: PageStorageKey('mailbox_list'),
      primary: false,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        Obx(() => (controller.isSelectionEnabled() && _responsiveUtils.isMobileDevice(context) && _responsiveUtils.isLandscape(context))
            || _responsiveUtils.isDesktop(context) ? SizedBox.shrink() : _buildUserInformationWidget(context)),
        Obx(() => (controller.isSelectionEnabled() && _responsiveUtils.isMobileDevice(context) && _responsiveUtils.isLandscape(context))
            || _responsiveUtils.isDesktop(context) ? SizedBox.shrink() : _buildLineSpaceUserInformation()),
        if (!_responsiveUtils.isDesktop(context)) _buildSearchBarWidget(context),
        _buildLoadingView(),
        Obx(() => controller.defaultMailboxTree.value.root.childrenItems?.isNotEmpty ?? false
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white),
              margin: EdgeInsets.only(left: 16, right: 16, top: 4),
              child: _buildDefaultMailbox(context))
          : SizedBox.shrink()),
        Obx(() => controller.folderMailboxTree.value.root.childrenItems?.isNotEmpty ?? false
           ? Padding(
              padding: EdgeInsets.only(left: 25, top: 26, bottom: 12),
              child: Text(
                AppLocalizations.of(context).folders,
                maxLines: 1,
                style: TextStyle(fontSize: 20, color: AppColor.colorNameEmail, fontWeight: FontWeight.w600)))
          : SizedBox.shrink()),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white),
          margin: EdgeInsets.only(left: 16, right: 16, bottom: 30),
          child: _buildFolderMailbox(context),
        ),
      ]
    );
  }

  Widget _buildLineSpaceUserInformation() {
    return Padding(
        padding: EdgeInsets.only(top: 16),
        child: Divider(color: AppColor.colorDividerMailbox, height: 0.5, thickness: 0.2));
  }

  Widget _buildDefaultMailbox(BuildContext context) {
    return Obx(() => controller.defaultMailboxTree.value.root.childrenItems?.isNotEmpty ?? false
        ? Transform(
            transform: Matrix4.translationValues(-4.0, 0.0, 0.0),
            child: Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: TreeView(
                startExpanded: false,
                key: Key('default_mailbox_list'),
                children: _buildListChildTileWidget(context, controller.defaultMailboxTree.value.root)))
          )
        : SizedBox.shrink()
    );
  }

  Widget _buildFolderMailbox(BuildContext context) {
    return Obx(() => controller.folderMailboxTree.value.root.childrenItems?.isNotEmpty ?? false
        ? Transform(
            transform: Matrix4.translationValues(-4.0, 0.0, 0.0),
            child: Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: TreeView(
                startExpanded: false,
                key: Key('folder_mailbox_list'),
                children: _buildListChildTileWidget(context, controller.folderMailboxTree.value.root)))
          )
        : SizedBox.shrink()
    );
  }

  List<Widget> _buildListChildTileWidget(BuildContext context, MailboxNode parentNode) {
    return parentNode.childrenItems
      ?.map((mailboxNode) => mailboxNode.hasChildren()
          ? Padding(
              padding: EdgeInsets.only(left: 16),
              child: TreeViewChild(
                  context,
                  key: Key('children_tree_mailbox_child'),
                  isExpanded: mailboxNode.expandMode == ExpandMode.EXPAND,
                  parent: Obx(() => (MailBoxFolderTileBuilder(
                          context,
                          _imagePaths,
                          mailboxNode,
                          allSelectMode: controller.currentSelectMode.value)
                      ..addOnOpenMailboxFolderClick((mailboxNode) => controller.openMailbox(context, mailboxNode.item))
                      ..addOnExpandFolderActionClick((mailboxNode) => controller.toggleMailboxFolder(mailboxNode))
                      ..addOnSelectMailboxFolderClick((mailboxNode) => controller.selectMailboxNode(mailboxNode)))
                    .build()),
                  children: _buildListChildTileWidget(context, mailboxNode)
              ).build())
          : Padding(
              padding: EdgeInsets.only(left: 16),
              child: Obx(() => (MailBoxFolderTileBuilder(
                      context,
                      _imagePaths,
                      mailboxNode,
                      allSelectMode: controller.currentSelectMode.value)
                  ..addOnOpenMailboxFolderClick((mailboxNode) => controller.openMailbox(context, mailboxNode.item))
                  ..addOnSelectMailboxFolderClick((mailboxNode) => controller.selectMailboxNode(mailboxNode)))
                .build(),
              )
            )
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

  Widget _buildListMailboxSearched(BuildContext context, List<PresentationMailbox> listMailbox) {
    return Container(
        margin: _responsiveUtils.isDesktop(context)
            ? EdgeInsets.only(left: 16, right: 16)
            : EdgeInsets.zero,
        decoration: _responsiveUtils.isDesktop(context)
          ? BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.white)
          : null,
        child: ListView.builder(
            padding: EdgeInsets.only(left: 16, right: 8),
            key: Key('list_mailbox_searched'),
            itemCount: listMailbox.length,
            shrinkWrap: true,
            primary: false,
            itemBuilder: (context, index) => Obx(() => (MailboxTileBuilder(
                    _imagePaths,
                    listMailbox[index],
                    isSearchActive: controller.isSearchActive(),
                    allSelectMode: controller.currentSelectMode.value,
                    isLastElement: index == listMailbox.length - 1)
                ..addOnOpenMailboxAction((mailbox) => controller.openMailbox(context, mailbox))
                ..addOnSelectMailboxActionClick((mailbox) => controller.selectMailbox(context, mailbox)))
              .build()))
    );
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
        Padding(
          padding: EdgeInsets.only(bottom: 30, top: 5),
          child: (BottomBarSelectionMailboxWidget(context, _imagePaths, controller.listMailboxSelected)
              ..addOnMailboxActionsClick((actions, listMailboxSelected) => controller.pressMailboxSelectionAction(context, actions, listMailboxSelected)))
            .build()
        )
      ]);
    }
  }
}