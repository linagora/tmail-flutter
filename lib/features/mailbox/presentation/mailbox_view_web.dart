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

  MailboxView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        elevation: _responsiveUtils.isDesktop(context) ? 0 : 16.0,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
              children: [
                if (!_responsiveUtils.isDesktop(context)) _buildLogoApp(context),
                if (!_responsiveUtils.isDesktop(context)) const Divider(color: AppColor.colorDividerMailbox, height: 0.5, thickness: 0.2),
                Expanded(child: Container(
                  padding: EdgeInsets.zero,
                  color: _responsiveUtils.isDesktop(context) ? AppColor.colorBgDesktop : Colors.white,
                  child: Column(children: [
                    if (_responsiveUtils.isDesktop(context)) _buildComposerButton(context),
                    Obx(() => controller.isSearchActive() ? _buildInputSearchFormWidget(context) : const SizedBox.shrink()),
                    Expanded(child: Obx(() => Container(
                      color: _responsiveUtils.isDesktop(context) ? AppColor.colorBgDesktop : Colors.white,
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.only(top: _responsiveUtils.isDesktop(context) ? 16 : 0),
                      child: RefreshIndicator(
                          color: AppColor.primaryColor,
                          onRefresh: () async => controller.refreshAllMailbox(),
                          child: controller.isSearchActive()
                              ? _buildListMailboxSearched(context, controller.listMailboxSearched)
                              : _buildListMailbox(context)),
                    ))),
                  ]),
                )),
                Obx(() {
                  if (controller.isSearchActive()) {
                    return controller.listPresentationMailboxSelected.isNotEmpty
                        ? _buildOptionSelectionMailbox(context)
                        : const SizedBox.shrink();
                  } else {
                    return controller.listMailboxNodeSelected.isNotEmpty
                        ? _buildOptionSelectionMailbox(context)
                        : const SizedBox.shrink();
                  }
                }),
              ]
          ),
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
        padding: const EdgeInsets.only(top: 16, right: 16, left: 20),
        color: AppColor.colorBgDesktop,
        alignment: Alignment.centerLeft,
        child: (ButtonBuilder(_imagePaths.icCompose)
            ..key(const Key('button_compose_email'))
            ..decoration(BoxDecoration(borderRadius: BorderRadius.circular(25), color: AppColor.colorTextButton))
            ..paddingIcon(const EdgeInsets.only(right: 8))
            ..iconColor(Colors.white)
            ..maxWidth(140)
            ..size(20)
            ..radiusSplash(10)
            ..padding(const EdgeInsets.symmetric(vertical: 13))
            ..textStyle(const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500))
            ..onPressActionClick(() => controller.mailboxDashBoardController.composeEmailAction())
            ..text(AppLocalizations.of(context).compose, isVertical: false))
          .build());
  }

  Widget _buildSearchBarWidget(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 16, bottom: 16, right: 4, left: _responsiveUtils.isDesktop(context) ? 0 : 12),
        child: (SearchBarView(_imagePaths)
            ..hintTextSearch(AppLocalizations.of(context).hint_search_mailboxes)
            ..addOnOpenSearchViewAction(() => controller.enableSearch()))
          .build());
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
    return ListView(
        controller: controller.mailboxListScrollController,
        key: const PageStorageKey('mailbox_list'),
        primary: false,
        shrinkWrap: true,
        padding: EdgeInsets.only(
            right: _responsiveUtils.isDesktop(context) ? 8 : 0,
            left: _responsiveUtils.isDesktop(context) ? 20 : 0),
        children: [
          Obx(() {
            if (controller.isSelectionEnabled() || _responsiveUtils.isDesktop(context)) {
              return const SizedBox.shrink();
            }
            return _buildUserInformation(context);
          }),
          _buildLoadingView(),
          Obx(() => controller.defaultMailboxTree.value.root.childrenItems?.isNotEmpty ?? false
              ? _buildMailboxCategory(context, MailboxCategories.exchange, controller.defaultMailboxTree.value.root)
              : const SizedBox.shrink()),
          const SizedBox(height: 8),
          Obx(() => controller.folderMailboxTree.value.root.childrenItems?.isNotEmpty ?? false
              ? Column(children: const [
                  Divider(color: AppColor.colorDividerMailbox, height: 0.5, thickness: 0.2),
                  SizedBox(height: 8),
                ])
              : const SizedBox.shrink()),
          Obx(() => controller.folderMailboxTree.value.root.childrenItems?.isNotEmpty ?? false
              ? _buildMailboxCategory(context, MailboxCategories.folders, controller.folderMailboxTree.value.root)
              : const SizedBox.shrink()),
          const SizedBox(height: 8),
          const Divider(color: AppColor.colorDividerMailbox, height: 0.5, thickness: 0.2),
          Row(children: [
            Expanded(child: _buildSearchBarWidget(context)),
            Padding(
                padding: const EdgeInsets.only(right: 8),
                child: buildIconWeb(
                    icon: SvgPicture.asset(_imagePaths.icAddNewFolder, color: AppColor.colorTextButton, fit: BoxFit.fill),
                    tooltip: AppLocalizations.of(context).new_mailbox,
                    onTap: () => controller.goToCreateNewMailboxView())),
          ]),
        ]
    );
  }

  Widget _buildUserInformation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 10),
          child: (UserInformationWidgetBuilder(_imagePaths, context, controller.mailboxDashBoardController.userProfile.value)
              ..addOnLogoutAction(() => controller.mailboxDashBoardController.goToSettings()))
            .build()),
        const Divider(color: AppColor.colorDividerMailbox, height: 0.5, thickness: 0.2)
      ]),
    );
  }

  Widget _buildHeaderMailboxCategory(BuildContext context, MailboxCategories categories) {
    return Padding(
        padding: EdgeInsets.only(left: _responsiveUtils.isDesktop(context) ? 12 : 16, right: _responsiveUtils.isDesktop(context) ? 4 : 12),
        child: Row(children: [
          Expanded(child: Text(categories.getTitle(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.bold))),
          buildIconWeb(
              splashRadius: 12,
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
        margin: EdgeInsets.zero,
        padding: EdgeInsets.only(right: _responsiveUtils.isDesktop(context) ? 8 : 16, left: _responsiveUtils.isDesktop(context) ? 0 : 12),
        child: TreeView(
            key: Key('${categories.keyValue}_mailbox_list'),
            children: _buildListChildTileWidget(context, mailboxNode, lastNode: lastNode)));
  }

  Widget _buildMailboxCategory(BuildContext context, MailboxCategories categories, MailboxNode mailboxNode) {
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
        ?.map((mailboxNode) => mailboxNode.hasChildren()
          ? TreeViewChild(
                context,
                key: const Key('children_tree_mailbox_child'),
                isExpanded: mailboxNode.expandMode == ExpandMode.EXPAND,
                parent: Obx(() => (MailBoxFolderTileBuilder(context, _imagePaths, mailboxNode, lastNode: lastNode,
                        mailboxNodeSelected: controller.mailboxDashBoardController.selectedMailbox.value)
                    ..addOnOpenMailboxFolderClick((mailboxNode) => controller.openMailbox(context, mailboxNode.item))
                    ..addOnExpandFolderActionClick((mailboxNode) => controller.toggleMailboxFolder(mailboxNode))
                    ..addOnSelectMailboxFolderClick((mailboxNode) => controller.selectMailboxNode(mailboxNode)))
                  .build()),
                children: _buildListChildTileWidget(context, mailboxNode)
            ).build()
          : Obx(() => (MailBoxFolderTileBuilder(context, _imagePaths, mailboxNode, lastNode: lastNode,
                  mailboxNodeSelected: controller.mailboxDashBoardController.selectedMailbox.value)
              ..addOnOpenMailboxFolderClick((mailboxNode) => controller.openMailbox(context, mailboxNode.item))
              ..addOnSelectMailboxFolderClick((mailboxNode) => controller.selectMailboxNode(mailboxNode)))
            .build())
    ).toList() ?? <Widget>[];
  }

  Widget _buildInputSearchFormWidget(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 8, top: 16),
        child: Row(
            children: [
              buildIconWeb(
                  icon: SvgPicture.asset(_imagePaths.icBack, color: AppColor.colorTextButton, fit: BoxFit.fill),
                  onTap: () => controller.disableSearch(context)),
              Expanded(child: (SearchAppBarWidget(context, _imagePaths, _responsiveUtils, controller.searchQuery.value,
                      controller.searchFocus, controller.searchInputController, hasBackButton: false, hasSearchButton: true)
                  ..addPadding(EdgeInsets.zero)
                  ..setMargin(const EdgeInsets.only(right: 16))
                  ..addDecoration(BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColor.colorBgSearchBar))
                  ..addIconClearText(SvgPicture.asset(_imagePaths.icClearTextSearch, width: 16, height: 16, fit: BoxFit.fill))
                  ..setHintText(AppLocalizations.of(context).hint_search_mailboxes)
                  ..addOnClearTextSearchAction(() => controller.clearSearchText())
                  ..addOnTextChangeSearchAction((query) => controller.searchMailbox(query))
                  ..addOnSearchTextAction((query) => controller.searchMailbox(query)))
                .build())
            ]
        )
    );
  }

  Widget _buildListMailboxSearched(BuildContext context, List<PresentationMailbox> listMailbox) {
    return Container(
        margin: EdgeInsets.zero,
        color: _responsiveUtils.isDesktop(context) ? AppColor.colorBgDesktop : Colors.white,
        child: ListView.builder(
            padding: const EdgeInsets.only(left: 16, right: 8),
            key: const Key('list_mailbox_searched'),
            itemCount: listMailbox.length,
            shrinkWrap: true,
            primary: false,
            itemBuilder: (context, index) =>
                Obx(() => (MailboxSearchTileBuilder(
                      _imagePaths,
                      listMailbox[index],
                      lastMailbox: controller.listMailboxSearched.last)
                  ..addOnOpenMailboxAction((mailbox) => controller.openMailbox(context, mailbox))
                  ..addOnSelectMailboxActionClick((mailbox) => controller.selectMailboxSearched(context, mailbox)))
                .build()))
    );
  }

  Widget _buildOptionSelectionMailbox(BuildContext context) {
    return Column(children: [
      const Divider(color: AppColor.lineItemListColor, height: 1, thickness: 0.2),
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: (BottomBarSelectionMailboxWidget(context, _imagePaths, controller.listMailboxSelected)
              ..addOnMailboxActionsClick((actions, listMailboxSelected) => controller.pressMailboxSelectionAction(context, actions, listMailboxSelected)))
            .build()
      )
    ]);
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