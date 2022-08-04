import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/destination_picker_controller.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/widgets/app_bar_destination_picker_builder.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/widgets/top_bar_destination_picker_web_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_displayed.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_folder_tile_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_search_tile_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/search_app_bar_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class DestinationPickerView extends GetWidget<DestinationPickerController>
    with AppLoaderMixin {

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

    if (BuildUtils.isWeb) {
      return PointerInterceptor(
        child: GestureDetector(
          onTap: () => controller.closeDestinationPicker(),
          child: Scaffold(
            backgroundColor: AppColor.colorShadowDestinationPicker,
            body: Align(
              alignment: Alignment.center,
              child: Card(
                color: Colors.white,
                margin: _getMarginDestinationPicker(context),
                elevation: 16,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14))),
                child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(14))),
                    width: _getWidthDestinationPicker(context),
                    child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(14)),
                        child: GestureDetector(
                            onTap: () => {},
                            child: _buildDestinationPickerWebWidget(context, actions))
                    )
                )
              )
            )
          ),
        ),
      );
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
                  SizedBox(child: _buildBodyMailboxLocation(context, actions), width: ResponsiveUtils.defaultSizeDrawer),
                  Expanded(child: Container(color: Colors.transparent)),
                ]),
                tablet: Row(children: [
                  Expanded(child: Container(color: Colors.transparent)),
                  SizedBox(
                      child: _buildBodyMailboxLocation(context, actions),
                      width: _responsiveUtils.getSizeScreenWidth(context) - ResponsiveUtils.defaultSizeDrawer),
                ]),
                tabletLarge: Row(children: [
                  Expanded(child: Container(color: Colors.transparent)),
                  SizedBox(
                      child: _buildBodyMailboxLocation(context, actions),
                      width: _responsiveUtils.getSizeScreenWidth(context) - ResponsiveUtils.defaultSizeDrawer),
                ]),
                desktop: Row(children: [
                  Expanded(child: Container(color: Colors.transparent)),
                  SizedBox(
                      child: _buildBodyMailboxLocation(context, actions),
                      width: _responsiveUtils.getSizeScreenWidth(context) - ResponsiveUtils.defaultSizeDrawer),
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
                  SizedBox(child: _buildBodyMailboxLocation(context, actions), width: ResponsiveUtils.defaultSizeDrawer),
                  Expanded(child: Container(color: Colors.transparent)),
                ]),
                tablet: Row(children: [
                  SizedBox(child: _buildBodyMailboxLocation(context, actions), width: ResponsiveUtils.defaultSizeDrawer),
                  Expanded(child: Container(color: Colors.transparent)),
                ]),
                tabletLarge: Row(children: [
                  SizedBox(child: _buildBodyMailboxLocation(context, actions), width: ResponsiveUtils.defaultSizeDrawer),
                  Expanded(child: Container(color: Colors.transparent)),
                ]),
                desktop: Row(children: [
                  SizedBox(child: _buildBodyMailboxLocation(context, actions), width: ResponsiveUtils.defaultSizeDrawer),
                  Expanded(child: Container(color: Colors.transparent)),
                ]),
            ),
          )
      ));
    }
  }

  Widget _buildDestinationPickerWebWidget(BuildContext context, MailboxActions? actions) {
    return Column(children: [
      Obx(() => TopBarDestinationPickerWebBuilder(
          controller.mailboxAction.value,
          onCloseAction: () => controller.closeDestinationPicker())),
      Obx(() => controller.isSearchActive()
          ? _buildInputSearchFormWidget(context)
          : const SizedBox.shrink()),
      Expanded(child: Container(
          color: actions?.getBackgroundColor(),
          child: _buildBodyDestinationPicker(context, actions)))
    ]);
  }

  Widget _buildBodyMailboxLocation(BuildContext context, MailboxActions? actions) {
    return SafeArea(
        top: !BuildUtils.isWeb && _responsiveUtils.isPortraitMobile(context),
        bottom: false,
        left: false,
        right: false,
        child: GestureDetector(
          onTap: () => {},
          child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(
                      !BuildUtils.isWeb && _responsiveUtils.isPortraitMobile(context)
                          ? 14 : 0),
                  topLeft: Radius.circular(
                      !BuildUtils.isWeb && _responsiveUtils.isPortraitMobile(context)
                          ? 14 : 0)),
              child: Container(
                  color: Colors.white,
                  child: Column(children: [
                      SafeArea(
                          left: !BuildUtils.isWeb && _responsiveUtils.isLandscapeMobile(context),
                          right: false,
                          bottom: false,
                          child: _buildAppBar(context)),
                      const Divider(color: AppColor.colorDividerMailbox, height: 0.5, thickness: 0.2),
                      Obx(() => controller.isSearchActive()
                          ? SafeArea(bottom: false, top: false, right: false, child: _buildInputSearchFormWidget(context))
                          : const SizedBox.shrink()),
                      Expanded(child: Container(
                          color: actions == MailboxActions.create ? AppColor.colorBgMailbox : Colors.white,
                          child: SafeArea(
                              top: false,
                              bottom: false,
                              left: !BuildUtils.isWeb && _responsiveUtils.isLandscapeMobile(context),
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
            top: _responsiveUtils.isScreenWithShortestSide(context) &&
                !BuildUtils.isWeb ? 12 : 0,
            left: _responsiveUtils.isLandscapeMobile(context) &&
                !BuildUtils.isWeb ? 0 : 16,
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
        ? Padding(
            padding: const EdgeInsets.only(top: 16),
            child: loadingWidget)
        : const SizedBox.shrink()));
  }

  Widget _buildListMailbox(BuildContext context, MailboxActions? actions) {
    return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(children: [
          if (actions?.hasSearchActive() == true)
            _buildSearchBarWidget(context),
          _buildLoadingView(),
          if (actions == MailboxActions.create && !BuildUtils.isWeb && _responsiveUtils.isScreenWithShortestSide(context))
            const SizedBox(height: 12),
          if (actions?.hasAllMailboxDefault() == true)
            _buildUnifiedMailbox(context, actions),
          const SizedBox(height: 12),
          Obx(() => controller.defaultMailboxHasChild
              ? _buildMailboxCategory(context, MailboxCategories.exchange, controller.defaultRootNode, actions)
              : const SizedBox.shrink()),
          if (actions == MailboxActions.create) const SizedBox(height: 12),
          if (actions != MailboxActions.create && !BuildUtils.isWeb)
            const Padding(
                padding: EdgeInsets.only(left: 55, right: 20),
                child: Divider(color: AppColor.lineItemListColor, height: 0.5, thickness: 0.2)),
          Obx(() => controller.folderMailboxHasChild
              ? _buildMailboxCategory(context, MailboxCategories.folders, controller.folderRootNode, actions)
              : const SizedBox.shrink()),
          const SizedBox(height: 12),
        ])
    );
  }

  Widget _buildMailboxCategory(BuildContext context, MailboxCategories categories, MailboxNode mailboxNode, MailboxActions? actions) {
    if (actions?.canCollapseMailboxGroup() == false) {
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
              overflow: CommonTextStyle.defaultTextOverFlow,
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
        margin: _marginMailboxList(context, actions),
        padding: _paddingMailboxList(context, actions),
        child: TreeView(
            key: Key('${categories.keyValue}_mailbox_list'),
            children: _buildListChildTileWidget(context, mailboxNode, lastNode: lastNode)));
  }

  EdgeInsets _marginMailboxList(BuildContext context, MailboxActions? actions) {
    if (BuildUtils.isWeb) {
      return EdgeInsets.only(
          left: actions?.canCollapseMailboxGroup() == false ? 0 : 16,
          right: actions?.canCollapseMailboxGroup() == false ? 0 : 16);
    } else {
      return EdgeInsets.only(
          left: _responsiveUtils.isLandscapeMobile(context) ? 0 : 16,
          right: actions == MailboxActions.create
              ? 16
              : _responsiveUtils.isLandscapeMobile(context) ? 0 : 8);
    }
  }

  EdgeInsets _paddingMailboxList(BuildContext context, MailboxActions? actions) {
    if (BuildUtils.isWeb) {
      return EdgeInsets.only(
          left: actions == MailboxActions.create ? 0 : 8,
          right: actions == MailboxActions.create ? 8 : 16);
    } else {
      return EdgeInsets.only(
          left: actions == MailboxActions.create ? 16 : 8,
          right: 0);
    }
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
        margin: const EdgeInsets.only(
            right: 8,
            bottom: 12,
            top: BuildUtils.isWeb ? 8 : 0),
        decoration: _responsiveUtils.isDesktop(context)
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white)
            : null,
        child: ListView.builder(
            padding: const EdgeInsets.only(left: 16, right: 8),
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
                        mailboxDisplayed: MailboxDisplayed.destinationPicker,
                        lastMailbox: controller.listMailboxSearched.last)
                    ..addOnOpenMailboxAction((mailbox) => controller.selectMailboxAction(mailbox)))
                  .build())
        )
    ));
  }

  Widget _buildUnifiedMailbox(BuildContext context, MailboxActions? actions) {
    if (actions == MailboxActions.move || actions == MailboxActions.select) {
      return InkWell(
        onTap: () => controller.selectMailboxAction(PresentationMailbox.unifiedMailbox),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          child: Container(
              color: Colors.white,
              margin: const EdgeInsets.only(
                  left: BuildUtils.isWeb ? 8 : 0,
                  top: 8),
              padding: const EdgeInsets.only(left: 16, top: 16),
              child: Row(children: [
                SvgPicture.asset(
                    _imagePaths.icFolderMailbox,
                    width: BuildUtils.isWeb ? 20 : 24,
                    height: BuildUtils.isWeb ? 20 : 24,
                    fit: BoxFit.fill),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  AppLocalizations.of(context).allMailboxes,
                  maxLines: 1,
                  overflow: CommonTextStyle.defaultTextOverFlow,
                  style: const TextStyle(
                      fontSize: 15,
                      color: AppColor.colorNameEmail,
                      fontWeight: FontWeight.normal),
                )),
                const SizedBox(width: 8),
              ])
          ),
        ),
      );
    }

    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(
          left: !_responsiveUtils.isLandscapeMobile(context) ? 16 : 0,
          top: BuildUtils.isWeb ? 16 : 0,
          right: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.white),
      child: MediaQuery(
        data: const MediaQueryData(padding: EdgeInsets.zero),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: () => controller.selectMailboxAction(PresentationMailbox.unifiedMailbox),
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: SvgPicture.asset(_imagePaths.icFolderMailbox,
                width: BuildUtils.isWeb ? 20 : 24,
                height: BuildUtils.isWeb ? 20 : 24,
                fit: BoxFit.fill)),
          title: Transform(
            transform: Matrix4.translationValues(-5.0, 0.0, 0.0),
            child: Row(
              children: [
                Expanded(child: Text(
                  AppLocalizations.of(context).default_mailbox,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
    PresentationMailbox presentationMailbox;
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
        padding: const EdgeInsets.symmetric(
            vertical: BuildUtils.isWeb ? 0 : 16),
        child: Row(
            children: [
              Padding(padding: const EdgeInsets.only(left: 5), child: buildIconWeb(
                  icon: SvgPicture.asset(_imagePaths.icBack, color: AppColor.colorTextButton, fit: BoxFit.fill),
                  onTap: () => controller.disableSearch(context))),
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

  double _getWidthDestinationPicker(BuildContext context) {
    if (BuildUtils.isWeb) {
      if (_responsiveUtils.isMobile(context)) {
        return double.infinity;
      } else {
        return 500;
      }
    } else {
      return 500;
    }
  }

  EdgeInsets _getMarginDestinationPicker(BuildContext context) {
    if (BuildUtils.isWeb) {
      if (_responsiveUtils.isMobile(context)) {
        return EdgeInsets.zero;
      } else {
        return const EdgeInsets.symmetric(vertical: 50);
      }
    } else {
      return EdgeInsets.zero;
    }
  }
}