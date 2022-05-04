import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/destination_picker_controller.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/widgets/app_bar_destination_picker_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_displayed.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_folder_tile_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_search_tile_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/search_app_bar_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class DestinationPickerView extends GetWidget<DestinationPickerController> {

  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  DestinationPickerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MailboxActions? actions;
    final arguments = Get.arguments;
    if (arguments != null && arguments is DestinationPickerArguments) {
      actions = arguments.mailboxAction;
    }

    if (actions == MailboxActions.create) {
      return PointerInterceptor(child: Card(
          margin: EdgeInsets.zero,
          borderOnForeground: false,
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () => controller.closeDestinationPicker(),
            child: ResponsiveWidget(
                responsiveUtils: _responsiveUtils,
                mobile: SizedBox(child: _buildBodyMailboxLocation(context, actions), width: double.infinity),
                landscapeMobile: Row(children: [
                  SizedBox(child: _buildBodyMailboxLocation(context, actions), width: _responsiveUtils.defaultSizeDrawer),
                  Expanded(child: Container(color: Colors.transparent)),
                ]),
                tablet: Row(children: [
                  Expanded(child: Container(color: Colors.transparent)),
                  SizedBox(
                      child: _buildBodyMailboxLocation(context, actions),
                      width: _responsiveUtils.getSizeScreenWidth(context) - _responsiveUtils.defaultSizeDrawer),
                ]),
                tabletLarge: Row(children: [
                  Expanded(child: Container(color: Colors.transparent)),
                  SizedBox(
                      child: _buildBodyMailboxLocation(context, actions),
                      width: _responsiveUtils.getSizeScreenWidth(context) - _responsiveUtils.defaultSizeDrawer),
                ]),
                desktop: Row(children: [
                  Expanded(child: Container(color: Colors.transparent)),
                  SizedBox(
                      child: _buildBodyMailboxLocation(context, actions),
                      width: _responsiveUtils.getSizeScreenWidth(context) - _responsiveUtils.defaultSizeDrawer),
                ]),
            ),
          )
      ));
    } else {
      return PointerInterceptor(child: Card(
          margin: EdgeInsets.zero,
          borderOnForeground: false,
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () => controller.closeDestinationPicker(),
            child: ResponsiveWidget(
                responsiveUtils: _responsiveUtils,
                mobile: SizedBox(child: _buildBodyMailboxLocation(context, actions), width: double.infinity),
                landscapeMobile: Row(children: [
                  SizedBox(child: _buildBodyMailboxLocation(context, actions), width: _responsiveUtils.defaultSizeDrawer),
                  Expanded(child: Container(color: Colors.transparent)),
                ]),
                tablet: Row(children: [
                  SizedBox(child: _buildBodyMailboxLocation(context, actions), width: _responsiveUtils.defaultSizeDrawer),
                  Expanded(child: Container(color: Colors.transparent)),
                ]),
                tabletLarge: Row(children: [
                  SizedBox(child: _buildBodyMailboxLocation(context, actions), width: _responsiveUtils.defaultSizeDrawer),
                  Expanded(child: Container(color: Colors.transparent)),
                ]),
                desktop: Row(children: [
                  SizedBox(child: _buildBodyMailboxLocation(context, actions), width: _responsiveUtils.defaultSizeDrawer),
                  Expanded(child: Container(color: Colors.transparent)),
                ]),
            ),
          )
      ));
    }
  }

  Widget _buildBodyMailboxLocation(BuildContext context, MailboxActions? actions) {
    return SafeArea(top: _responsiveUtils.isPortraitMobile(context), bottom: false, left: false, right: false,
        child: GestureDetector(
          onTap: () => {},
          child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(_responsiveUtils.isPortraitMobile(context) ? 14 : 0),
                  topLeft: Radius.circular(_responsiveUtils.isPortraitMobile(context) ? 14 : 0)),
              child: Container(
                  color: Colors.white,
                  child: Column(children: [
                      SafeArea(left: false, right: false, bottom: false, child: _buildAppBar(context)),
                      const Divider(color: AppColor.colorDividerMailbox, height: 0.5, thickness: 0.2),
                      Obx(() => controller.isSearchActive()
                          ? SafeArea(bottom: false, top: false, right: false, child: _buildInputSearchFormWidget(context))
                          : const SizedBox.shrink()),
                      Expanded(child: Container(
                          color: actions == MailboxActions.create ? AppColor.colorBgMailbox : Colors.white,
                          child: SafeArea(
                              top: false,
                              bottom: false,
                              left: _responsiveUtils.isLandscapeMobile(context) ? true : false,
                              right: false,
                              child: _buildBodyDestinationPicker(context, actions))))
                  ])
              )
          ),
        )
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Obx(() => (AppBarDestinationPickerBuilder(context, _imagePaths, controller.mailboxAction.value)
        ..addCloseActionClick(() => controller.closeDestinationPicker()))
      .build());
  }

  Widget _buildSearchBarWidget(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(
            top: _responsiveUtils.isScreenWithShortestSide(context) || kIsWeb ? 12 : 0,
            left: _responsiveUtils.isLandscapeMobile(context) ? 0 : 16,
            right: 16),
        child: (SearchBarView(_imagePaths)
            ..hintTextSearch(AppLocalizations.of(context).hint_search_mailboxes)
            ..addOnOpenSearchViewAction(() => controller.enableSearch()))
          .build());
  }

  Widget _buildBodyDestinationPicker(BuildContext context, MailboxActions? actions) {
    return RefreshIndicator(
      color: AppColor.primaryColor,
      onRefresh: () async => controller.getAllMailboxAction(),
      child: Obx(() => controller.isSearchActive()
        ? _buildListMailboxSearched(context)
        : _buildListMailbox(context, actions)));
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
              child: CircularProgressIndicator(color: AppColor.primaryColor))))
        : const SizedBox.shrink()));
  }

  Widget _buildListMailbox(BuildContext context, MailboxActions? actions) {
    return ListView(
      primary: false,
      shrinkWrap: true,
      children: [
        if (actions == MailboxActions.moveEmail) _buildSearchBarWidget(context),
        _buildLoadingView(),
        if (actions == MailboxActions.create && !BuildUtils.isWeb && _responsiveUtils.isScreenWithShortestSide(context))
          const SizedBox(height: 12),
        if (actions == MailboxActions.create) _buildUnifiedMailbox(context),
        const SizedBox(height: 12),
        Obx(() => controller.defaultMailboxTree.value.root.childrenItems?.isNotEmpty ?? false
            ? _buildMailboxCategory(context, MailboxCategories.exchange, controller.defaultMailboxTree.value.root, actions)
            : const SizedBox.shrink()),
        if (actions == MailboxActions.create) const SizedBox(height: 12),
        if (actions != MailboxActions.create && !kIsWeb)
          const Padding(
            padding: EdgeInsets.only(left: 60),
            child: Divider(color: AppColor.lineItemListColor, height: 0.5, thickness: 0.2)),
        Obx(() => controller.folderMailboxTree.value.root.childrenItems?.isNotEmpty ?? false
            ? _buildMailboxCategory(context, MailboxCategories.folders, controller.folderMailboxTree.value.root, actions)
            : const SizedBox.shrink()),
      ]
    );
  }

  Widget _buildMailboxCategory(BuildContext context, MailboxCategories categories, MailboxNode mailboxNode, MailboxActions? actions) {
    if (actions == MailboxActions.moveEmail) {
      return _buildBodyMailboxCategory(context, categories, mailboxNode, actions);
    }
    return Column(children: [
      _buildHeaderMailboxCategory(context, categories),
      AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          child: categories.getExpandMode(controller.mailboxCategoriesExpandMode.value) == ExpandMode.EXPAND
              ? _buildBodyMailboxCategory(context, categories, mailboxNode, actions)
              : const Offstage())
    ]);
  }

  Widget _buildHeaderMailboxCategory(BuildContext context, MailboxCategories categories) {
    return Padding(
        padding: EdgeInsets.only(
            left: _responsiveUtils.isLandscapeMobile(context) ? 8 : 28,
            right: 16),
        child: Row(children: [
          Expanded(child: Text(categories.getTitle(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold))),
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

  Widget _buildBodyMailboxCategory(BuildContext context, MailboxCategories categories, MailboxNode mailboxNode, MailboxActions? actions) {
    final lastNode = mailboxNode.childrenItems?.last;

    return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.white),
        margin: EdgeInsets.only(
            left: actions == MailboxActions.moveEmail ? 8 : _responsiveUtils.isLandscapeMobile(context) ? 0 : 16,
            right: actions == MailboxActions.moveEmail ? 0 : 16),
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: TreeView(
            key: Key('${categories.keyValue}_mailbox_list'),
            children: _buildListChildTileWidget(context, mailboxNode, lastNode: lastNode)));
  }

  List<Widget> _buildListChildTileWidget(BuildContext context, MailboxNode parentNode, {MailboxNode? lastNode}) {
    return parentNode.childrenItems
        ?.map((mailboxNode) => mailboxNode.hasChildren()
          ? TreeViewChild(
                  context,
                  key: const Key('children_tree_mailbox_child'),
                  isExpanded: mailboxNode.expandMode == ExpandMode.EXPAND,
                  parent: (MailBoxFolderTileBuilder(context, _imagePaths, mailboxNode,
                            lastNode: lastNode,
                            mailboxDisplayed: MailboxDisplayed.destinationPicker)
                        ..addOnOpenMailboxFolderClick(_handleOpenMailboxClick)
                        ..addOnExpandFolderActionClick((mailboxNode) => controller.toggleMailboxFolder(mailboxNode)))
                      .build(),
                  children: _buildListChildTileWidget(context, mailboxNode)
              ).build()
          : (MailBoxFolderTileBuilder(context, _imagePaths, mailboxNode, lastNode: lastNode,
                  mailboxDisplayed: MailboxDisplayed.destinationPicker)
              ..addOnOpenMailboxFolderClick(_handleOpenMailboxClick))
            .build())
      .toList() ?? <Widget>[];
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
            padding: const EdgeInsets.only(left: 16, right: 8),
            key: const Key('list_mailbox_searched'),
            itemCount: controller.listMailboxSearched.length,
            shrinkWrap: true,
            primary: false,
            itemBuilder: (context, index) =>
                Obx(() => (MailboxSearchTileBuilder(
                        _imagePaths,
                        controller.listMailboxSearched[index],
                        lastMailbox: controller.listMailboxSearched.last)
                    ..addOnOpenMailboxAction((mailbox) => controller.selectMailboxAction(mailbox)))
                  .build())
        )
    ));
  }

  Widget _buildUnifiedMailbox(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(
          left: !_responsiveUtils.isLandscapeMobile(context) ? 16 : 0,
          top: kIsWeb ? 16 : 0,
          right: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.white),
      child: MediaQuery(
        data: const MediaQueryData(padding: EdgeInsets.zero),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: () => controller.selectMailboxAction(null),
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: SvgPicture.asset(_imagePaths.icFolderMailbox, width: 28, height: 28, fit: BoxFit.fill)),
          title: Transform(
            transform: Matrix4.translationValues(-5.0, 0.0, 0.0),
            child: Row(
              children: [
                Expanded(child: Text(
                  AppLocalizations.of(context).default_mailbox,
                  maxLines: 1,
                  overflow:TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, color: AppColor.colorNameEmail),
                ))
              ]
            )
          ),
        ),
      )
    );
  }

  void _handleOpenMailboxClick(MailboxNode mailboxNode) {
    var presentationMailbox;
    final path = controller.findNodePath(mailboxNode.item.id)
        ?? mailboxNode.item.name?.name;
    if (path != null) {
      presentationMailbox = mailboxNode.item
          .toPresentationMailboxWithMailboxPath(path);
    } else {
      presentationMailbox = mailboxNode.item;
    }
    controller.selectMailboxAction(presentationMailbox);
  }

  Widget _buildInputSearchFormWidget(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: Row(
            children: [
              Padding(padding: const EdgeInsets.only(left: 5), child: buildIconWeb(
                  icon: SvgPicture.asset(_imagePaths.icBack, color: AppColor.colorTextButton, fit: BoxFit.fill),
                  onTap: () => controller.disableSearch(context))),
              Expanded(child: (SearchAppBarWidget(context, _imagePaths, _responsiveUtils,
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
}