import 'package:core/core.dart';
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
import 'package:tmail_ui_user/features/thread/presentation/widgets/search_bar_thread_view_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MailboxView extends GetWidget<MailboxController> {

  final imagePaths = Get.find<ImagePaths>();
  final responsiveUtils = Get.find<ResponsiveUtils>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: responsiveUtils.isMobile(context) ? true : false,
      bottom: false,
      left: false,
      right: false,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(responsiveUtils.isMobile(context) ? 14 : 0),
          topLeft: Radius.circular(responsiveUtils.isMobile(context) ? 14 : 0)),
        child: Drawer(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Column(
                children: [
                  _buildHeaderMailbox(context),
                  Obx(() => controller.isSearchActive() ? _buildInputSearchFormWidget(context) : SizedBox.shrink()),
                  Expanded(child: Obx(() => Container(
                    color: controller.isSearchActive() ? Colors.white : AppColor.colorBgMailbox,
                    child: RefreshIndicator(
                        color: AppColor.primaryColor,
                        onRefresh: () async => controller.refreshAllMailbox(),
                        child: controller.isSearchActive()
                            ? _buildListMailboxSearched(context, controller.listMailboxSearched)
                            : _buildListMailbox(context)),
                  ))),
                  Obx(() => controller.isSelectionEnabled()
                      ? Column(children: [
                          Divider(color: AppColor.lineItemListColor, height: 1, thickness: 0.2),
                          _buildOptionSelectionBottomBar(context)
                        ])
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
              top: responsiveUtils.isMobile(context) ? 14 : 30,
              bottom: 10),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            !responsiveUtils.isDesktop(context) ? _buildCloseScreenButton(context) : SizedBox(width: 50),
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
        icon: SvgPicture.asset(imagePaths.icCloseMailbox, width: 30, height: 30, fit: BoxFit.fill)));
  }

  Widget _buildAddNewFolderButton(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(right: 10),
        child: IconButton(
            key: Key('create_new_mailbox_button'),
            onPressed: () => controller.goToCreateNewMailboxView(),
            icon: SvgPicture.asset(imagePaths.icAddNewFolder, width: 30, height: 30, fit: BoxFit.fill)));
  }

  Widget _buildEditMailboxButton(BuildContext context, bool isSelectionEnabled) {
    return Material(
        borderRadius: BorderRadius.circular(20),
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
          imagePaths,
          context,
          controller.mailboxDashBoardController.userProfile.value)
        ..addOnLogoutAction(() => controller.logoutAction()))
      .build()));
  }

  Widget _buildSearchBarWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12),
      child: (SearchBarThreadViewWidget(imagePaths)
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
              child: CircularProgressIndicator(color: AppColor.primaryColor))))
        : SizedBox.shrink()));
  }

  Widget _buildListMailbox(BuildContext context) {
    return ListView(
      key: PageStorageKey('mailbox_list'),
      primary: false,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        Obx(() => (controller.isSelectionEnabled() && responsiveUtils.isMobileDevice(context) && responsiveUtils.isLandscape(context))
            ? SizedBox.shrink()
            : _buildUserInformationWidget(context)),
        Obx(() => (controller.isSelectionEnabled() && responsiveUtils.isMobileDevice(context) && responsiveUtils.isLandscape(context))
            ? SizedBox.shrink()
            : _buildLineSpaceUserInformation()),
        _buildSearchBarWidget(context),
        _buildLoadingView(),
        Obx(() => controller.defaultMailboxList.isNotEmpty
          ? Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white),
              margin: EdgeInsets.only(left: 16, right: 16, top: 4),
              child: _buildDefaultMailbox(context, controller.defaultMailboxList))
          : SizedBox.shrink()),
        Padding(
          padding: EdgeInsets.only(left: 25, top: 26, bottom: 12),
          child: Text(
            AppLocalizations.of(context).folders,
            maxLines: 1,
            style: TextStyle(fontSize: 20, color: AppColor.colorNameEmail, fontWeight: FontWeight.w600))
        ),
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

  Widget _buildDefaultMailbox(BuildContext context, List<PresentationMailbox> defaultMailbox) {
    return ListView.builder(
      padding: EdgeInsets.all(8),
      key: PageStorageKey('default_mailbox_list'),
      itemCount: defaultMailbox.length,
      shrinkWrap: true,
      primary: false,
      itemBuilder: (context, index) =>
        Obx(() => (MailboxTileBuilder(
              imagePaths,
              defaultMailbox[index],
              allSelectMode: controller.currentSelectMode.value,
              isLastElement: index == defaultMailbox.length - 1)
          ..addOnOpenMailboxAction((mailbox) => controller.openMailbox(context, mailbox))
          ..addOnSelectMailboxActionClick((mailbox) => controller.selectMailbox(context, mailbox)))
        .build()));
  }

  Widget _buildFolderMailbox(BuildContext context) {
    return Obx(() => controller.folderMailboxNodeList.isNotEmpty
        ? Transform(
            transform: Matrix4.translationValues(-4.0, 0.0, 0.0),
            child: Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: TreeView(
                startExpanded: false,
                key: Key('folder_mailbox_list'),
                children: _buildListChildTileWidget(context, controller.folderMailboxNodeList)))
          )
        : SizedBox.shrink()
    );
  }

  List<Widget> _buildListChildTileWidget(BuildContext context, List<MailboxNode> listMailboxNode) {
    return listMailboxNode
      .map((mailboxNode) => mailboxNode.hasChildren()
          ? Padding(
              padding: EdgeInsets.only(left: 16),
              child: TreeViewChild(
                  context,
                  key: Key('children_tree_mailbox_child'),
                  isExpanded: mailboxNode.expandMode == ExpandMode.EXPAND,
                  parent: Obx(() => (MailBoxFolderTileBuilder(
                          context,
                          imagePaths,
                          mailboxNode,
                          allSelectMode: controller.currentSelectMode.value)
                      ..addOnOpenMailboxFolderClick((mailboxNode) => controller.openMailbox(context, mailboxNode.item))
                      ..addOnExpandFolderActionClick((mailboxNode) => controller.toggleMailboxFolder(mailboxNode))
                      ..addOnSelectMailboxFolderClick((mailboxNode) => controller.selectMailboxNode(context, mailboxNode)))
                    .build()),
                  children: _buildListChildTileWidget(context, mailboxNode.childrenItems!)
              ).build())
          : Padding(
              padding: EdgeInsets.only(left: 16),
              child: Obx(() => (MailBoxFolderTileBuilder(
                      context,
                      imagePaths,
                      mailboxNode,
                      allSelectMode: controller.currentSelectMode.value)
                  ..addOnOpenMailboxFolderClick((mailboxNode) => controller.openMailbox(context, mailboxNode.item))
                  ..addOnSelectMailboxFolderClick((mailboxNode) => controller.selectMailboxNode(context, mailboxNode)))
                .build(),
              )))
      .toList();
  }

  Widget _buildInputSearchFormWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: 16),
      child: Row(
          children: [
            _buildBackSearchButton(context),
            Expanded(child: (SearchAppBarWidget(
                  imagePaths,
                  controller.searchQuery.value,
                  controller.searchFocus,
                  controller.searchInputController,
                  hasBackButton: false,
                  hasSearchButton: true)
              ..addPadding(EdgeInsets.zero)
              ..setMargin(EdgeInsets.only(right: 16))
              ..addDecoration(BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColor.colorBgSearchBar))
              ..addIconClearText(SvgPicture.asset(imagePaths.icClearTextSearch, width: 20, height: 20, fit: BoxFit.fill))
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
            borderRadius: BorderRadius.circular(12),
            color: Colors.transparent,
            child: IconButton(
                color: AppColor.colorTextButton,
                icon: SvgPicture.asset(
                    imagePaths.icBack,
                    width: 20,
                    height: 20,
                    color: AppColor.colorTextButton,
                    fit: BoxFit.fill),
                onPressed: () => controller.disableSearch(context)
            )
        ));
  }

  Widget _buildListMailboxSearched(BuildContext context, List<PresentationMailbox> listMailbox) {
    return ListView.builder(
        padding: EdgeInsets.only(left: 16, right: 8, bottom: 30),
        key: Key('list_mailbox_searched'),
        itemCount: listMailbox.length,
        shrinkWrap: true,
        primary: false,
        itemBuilder: (context, index) =>
            Obx(() => (MailboxTileBuilder(
                    imagePaths,
                    listMailbox[index],
                    isSearchActive: controller.isSearchActive(),
                    allSelectMode: controller.currentSelectMode.value,
                    isLastElement: index == listMailbox.length - 1)
                ..addOnOpenMailboxAction((mailbox) => controller.openMailbox(context, mailbox))
                ..addOnSelectMailboxActionClick((mailbox) => controller.selectMailbox(context, mailbox)))
              .build()));
  }

  Widget _buildOptionSelectionBottomBar(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: 30, top: 5),
        child: (BottomBarSelectionMailboxWidget(
              context,
              imagePaths,
              controller.listMailboxSelected)
            ..addOnMailboxActionsClick((actions, listMailboxSelected) =>
                controller.pressMailboxSelectionAction(context, actions, listMailboxSelected)))
          .build()
    );
  }
}