import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/list/tree_view.dart';
import 'package:core/presentation/views/search/search_bar_view.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/base/widget/scrollbar_list_view.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/destination_picker_controller.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_screen_type.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/widgets/destination_picker_search_mailbox_item_builder.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/widgets/top_bar_destination_picker_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mixin/mailbox_widget_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_displayed.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/widgets/create_mailbox_name_input_decoration_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/search_app_bar_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class DestinationPickerView extends GetWidget<DestinationPickerController>
  with AppLoaderMixin,
    MailboxWidgetMixin {

  final _maxHeight = 656.0;

  @override
  final controller = Get.find<DestinationPickerController>();

  DestinationPickerView({super.key});

  @override
  Widget build(BuildContext context) {
    MailboxActions? actions = controller.arguments?.mailboxAction;
    MailboxId? mailboxIdSelected = controller.arguments?.mailboxIdSelected;

    return PointerInterceptor(
      child: GestureDetector(
        onTap: () => controller.closeDestinationPicker(context),
        child: Card(
          margin: EdgeInsets.zero,
          borderOnForeground: false,
          color: Colors.transparent,
          child: SafeArea(
            top: PlatformInfo.isMobile && controller.responsiveUtils.isPortraitMobile(context),
            bottom: false,
            left: false,
            right: false,
            child: Center(
                child: Container(
                    margin: _getMarginDestinationPicker(context),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: _getRadiusDestinationPicker(context),
                        boxShadow: const [
                          BoxShadow(
                              color: AppColor.colorShadowLayerBottom,
                              blurRadius: 96,
                              spreadRadius: 96,
                              offset: Offset.zero),
                          BoxShadow(
                              color: AppColor.colorShadowLayerTop,
                              blurRadius: 2,
                              spreadRadius: 2,
                              offset: Offset.zero),
                        ]),
                    width: _getWidthDestinationPicker(context),
                    height: _getHeightDestinationPicker(context),
                    child: ClipRRect(
                        borderRadius: _getRadiusDestinationPicker(context),
                        child: GestureDetector(
                            onTap: () => {},
                            child: SafeArea(
                              top: false,
                              bottom: false,
                              left: PlatformInfo.isMobile && controller.responsiveUtils.isLandscapeMobile(context),
                              right: PlatformInfo.isMobile && controller.responsiveUtils.isLandscapeMobile(context),
                              child: Column(children: [
                                Obx(() => TopBarDestinationPickerBuilder(
                                  controller.mailboxAction.value,
                                  controller.destinationScreenType.value,
                                  mailboxIdDestination: controller.mailboxDestination.value?.id,
                                  isCreateMailboxValidated: controller.isCreateMailboxValidated(context),
                                  onCloseAction: () =>
                                    controller.closeDestinationPicker(context),
                                  onBackToAction: () =>
                                    controller.backToDestinationScreen(context),
                                  onSelectedMailboxDestinationAction: () =>
                                    controller.dispatchSelectMailboxDestination(context),
                                  onCreateNewMailboxAction: () =>
                                    controller.createNewMailboxAction(context),
                                  onOpenCreateNewMailboxScreenAction: () =>
                                    controller.openCreateNewMailboxView(context))),
                                const Divider(
                                  color: AppColor.colorDividerDestinationPicker,
                                  height: 1),
                                Obx(() {
                                  if (controller.destinationScreenType.value == DestinationScreenType.destinationPicker) {
                                    return controller.isSearchActive()
                                      ? _buildInputSearchFormWidget(context)
                                      : const SizedBox.shrink();
                                  } else {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildCreateMailboxNameInput(context),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 12),
                                          child: Text(
                                            AppLocalizations.of(context).selectParentFolder,
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: AppColor.colorHintSearchBar,
                                              fontWeight: FontWeight.normal)),
                                        )
                                    ]);
                                  }
                                }),
                                Expanded(
                                  child: Container(
                                    color: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Obx(() {
                                      if (controller.isSearchActive()) {
                                        if (PlatformInfo.isMobile) {
                                          return RefreshIndicator(
                                            color: AppColor.primaryColor,
                                            onRefresh: () async => controller.getAllMailboxAction(),
                                            child: _buildListMailboxSearched(context, actions, mailboxIdSelected)
                                          );
                                        } else {
                                          return ScrollbarListView(
                                            scrollBehavior: ScrollConfiguration.of(context).copyWith(
                                              physics: const BouncingScrollPhysics(),
                                              dragDevices: {
                                                PointerDeviceKind.touch,
                                                PointerDeviceKind.mouse,
                                                PointerDeviceKind.trackpad
                                              },
                                              scrollbars: false
                                            ),
                                            scrollController: controller.destinationListScrollController,
                                            child: RefreshIndicator(
                                              color: AppColor.primaryColor,
                                              onRefresh: () async => controller.getAllMailboxAction(),
                                              child: _buildListMailboxSearched(context, actions, mailboxIdSelected)
                                            )
                                          );
                                        }
                                      } else {
                                        if (PlatformInfo.isMobile) {
                                          return RefreshIndicator(
                                            color: AppColor.primaryColor,
                                            onRefresh: () async => controller.getAllMailboxAction(),
                                            child: _buildListMailbox(context, actions, mailboxIdSelected)
                                          );
                                        } else {
                                          return ScrollbarListView(
                                            scrollBehavior: ScrollConfiguration.of(context).copyWith(
                                              physics: const BouncingScrollPhysics(),
                                              dragDevices: {
                                                PointerDeviceKind.touch,
                                                PointerDeviceKind.mouse,
                                                PointerDeviceKind.trackpad
                                              },
                                              scrollbars: false
                                            ),
                                            scrollController: controller.destinationListScrollController,
                                            child: RefreshIndicator(
                                              color: AppColor.primaryColor,
                                              onRefresh: () async => controller.getAllMailboxAction(),
                                              child: _buildListMailbox(context, actions, mailboxIdSelected)
                                            )
                                          );
                                        }
                                      }
                                    })
                                  )
                                )
                              ]),
                            ))
                    )
                )
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateMailboxNameInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Obx(() => TextFieldBuilder(
        key: const Key('create_mailbox_name_input'),
        onTextChange: controller.setNewNameMailbox,
        keyboardType: TextInputType.visiblePassword,
        cursorColor: AppColor.colorTextButton,
        controller: controller.nameInputController,
        textDirection: DirectionUtils.getDirectionByLanguage(context),
        maxLines: 1,
        textStyle: const TextStyle(
          color: AppColor.colorNameEmail,
          fontSize: 16,
          overflow: CommonTextStyle.defaultTextOverFlow),
        focusNode: controller.nameInputFocusNode,
        decoration: (CreateMailboxNameInputDecorationBuilder()
          ..setHintText(AppLocalizations.of(context).hintInputCreateNewFolder)
          ..setErrorText(controller.getErrorInputNameString(context)))
        .build(),
      ))
    );
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

  Widget _buildListMailbox(
      BuildContext context,
      MailboxActions? actions,
      MailboxId? mailboxIdSelected
  ) {
    return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        controller: controller.destinationListScrollController,
        child: Column(children: [
          if (actions?.canSearch() == true &&
            controller.destinationScreenType.value == DestinationScreenType.destinationPicker)
              SearchBarView(
                key: const Key('folder_search_bar_view'),
                imagePaths: controller.imagePaths,
                margin: const EdgeInsets.all(16),
                hintTextSearch: AppLocalizations.of(context).hintSearchFolders,
                onOpenSearchViewAction: controller.enableSearch
              ),
          _buildLoadingView(),
          if (actions?.hasAllMailboxDefault() == true)
            _buildAllMailboxes(context, actions, mailboxIdSelected),
          Obx(() => controller.defaultMailboxIsNotEmpty
            ? _buildMailboxCategory(
                context,
                MailboxCategories.exchange,
                controller.defaultRootNode,
                actions,
                mailboxIdSelected)
            : const SizedBox.shrink()),
          Obx(() {
            if (controller.personalMailboxIsNotEmpty) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(
                    color: AppColor.colorDividerMailbox,
                    height: 1,
                  ),
                  const SizedBox(height: 8),
                  _buildMailboxCategory(
                    context,
                    MailboxCategories.personalFolders,
                    controller.personalRootNode,
                    actions,
                    mailboxIdSelected
                  )
                ]
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
          Obx(() {
            if (controller.teamMailboxesIsNotEmpty
                && controller.mailboxAction.value == MailboxActions.moveEmail) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(
                    color: AppColor.colorDividerMailbox,
                    height: 1,
                  ),
                  const SizedBox(height: 8),
                  _buildMailboxCategory(
                    context,
                    MailboxCategories.teamMailboxes,
                    controller.teamMailboxesRootNode,
                    actions,
                    mailboxIdSelected
                  )
                ]
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
          const SizedBox(height: 12)
        ])
    );
  }

  Widget _buildMailboxCategory(
      BuildContext context,
      MailboxCategories categories,
      MailboxNode mailboxNode,
      MailboxActions? actions,
      MailboxId? mailboxIdSelected
  ) {
    if (categories == MailboxCategories.exchange) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _buildBodyMailboxCategory(
          context,
          categories,
          mailboxNode,
          actions,
          mailboxIdSelected
        ),
      );
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            child: categories.getExpandMode(controller.mailboxCategoriesExpandMode.value) == ExpandMode.EXPAND
              ? _buildBodyMailboxCategory(
                  context,
                  categories,
                  mailboxNode,
                  actions,
                  mailboxIdSelected
                )
              : const Offstage()
          ),
          const SizedBox(height: 8)
        ],
      );
    }
  }

  Widget _buildBodyMailboxCategory(
    BuildContext context,
    MailboxCategories categories,
    MailboxNode mailboxNode,
    MailboxActions? actions,
    MailboxId? mailboxIdSelected
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TreeView(
        key: Key('${categories.keyValue}_mailbox_list'),
        children: _buildListChildTileWidget(
          context,
          mailboxNode,
          mailboxIdSelected,
          lastNode: mailboxNode.childrenItems?.last,
          actions: actions
        )
      )
    );
  }

  List<Widget> _buildListChildTileWidget(
      BuildContext context,
      MailboxNode parentNode,
      MailboxId? mailboxIdSelected,
      {
        MailboxNode? lastNode,
        MailboxActions? actions
      }
  ) {
    return parentNode.childrenItems
      ?.map((mailboxNode) {
        if (mailboxNode.hasChildren()) {
          return TreeViewChild(
            context,
            key: const Key('children_tree_mailbox_child'),
            isExpanded: mailboxNode.expandMode == ExpandMode.EXPAND,
            paddingChild: const EdgeInsetsDirectional.only(start: 14),
            parent: MailboxItemWidget(
              mailboxNode: mailboxNode,
              mailboxActions: actions,
              mailboxIdAlreadySelected: mailboxIdSelected,
              mailboxDisplayed: MailboxDisplayed.destinationPicker,
              onOpenMailboxFolderClick: (node) => _pickMailboxNode(context, node),
              onExpandFolderActionClick: (mailboxNode) => controller.toggleMailboxFolder(mailboxNode, controller.destinationListScrollController),
            ),
            children: _buildListChildTileWidget(
              context,
              mailboxNode,
              mailboxIdSelected,
              actions: actions
            )
          ).build();
        } else {
          return MailboxItemWidget(
            mailboxNode: mailboxNode,
            mailboxDisplayed: MailboxDisplayed.destinationPicker,
            mailboxIdAlreadySelected: mailboxIdSelected,
            mailboxActions: actions,
            onOpenMailboxFolderClick: (node) => _pickMailboxNode(context, node),
          );
        }})
      .toList() ?? <Widget>[];
  }

  void _pickMailboxNode(BuildContext context, MailboxNode mailboxNode) {
    _handleOpenMailboxNodeClick(mailboxNode);
    controller.dispatchSelectMailboxDestination(context);
  }

  Widget _buildListMailboxSearched(
      BuildContext context,
      MailboxActions? actions,
      MailboxId? mailboxIdSelected
  ) {
    return Obx(() => ListView.builder(
        key: const Key('list_mailbox_searched'),
        itemCount: controller.listMailboxSearched.length,
        shrinkWrap: true,
        controller: controller.destinationListScrollController,
        primary: false,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          return Obx(() => DestinationPickerSearchMailboxItemBuilder(
            controller.imagePaths,
            controller.responsiveUtils,
            controller.listMailboxSearched[index],
            mailboxActions: actions,
            mailboxIdAlreadySelected: mailboxIdSelected,
            onClickOpenMailboxAction: (mailbox) => _pickPresentationMailbox(context, mailbox),
          ));
        }
    ));
  }

  void _pickPresentationMailbox(BuildContext context, PresentationMailbox mailbox) {
    _handleOpenPresentationMailboxClick(context, mailbox);
    controller.dispatchSelectMailboxDestination(context);
  }

  Widget _buildAllMailboxes(
      BuildContext context,
      MailboxActions? actions,
      MailboxId? mailboxIdSelected
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (mailboxIdSelected != null
                && mailboxIdSelected != PresentationMailbox.unifiedMailbox.id
            ) {
              controller.selectMailboxAction(PresentationMailbox.unifiedMailbox);
              controller.dispatchSelectMailboxDestination(context);
            }
          },
          customBorder: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          hoverColor: AppColor.colorMailboxHovered,
          child: Obx(() => Container(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 8,
              vertical: 10,
            ),
            color: controller.mailboxDestination.value == PresentationMailbox.unifiedMailbox
              ? AppColor.colorItemSelected
              : Colors.transparent,
            child: Row(children: [
              const SizedBox(width: 26),
              SvgPicture.asset(
                controller.imagePaths.icFolderMailbox,
                width: 20,
                height: 20,
                fit: BoxFit.fill
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(
                AppLocalizations.of(context).allFolders,
                maxLines: 1,
                softWrap: CommonTextStyle.defaultSoftWrap,
                overflow: CommonTextStyle.defaultTextOverFlow,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.normal
                ),
              )),
              const SizedBox(width: 8),
              if (_validateDisplaySelectedIcon(
                actions: actions,
                mailboxIdSelected: mailboxIdSelected
              ))
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 30.0),
                  child: SvgPicture.asset(
                    actions == MailboxActions.create
                      ? controller.imagePaths.icSelectedSB
                      : controller.imagePaths.icFilterSelected,
                    width: 20,
                    height: 20,
                    fit: BoxFit.fill
                  ),
                )
            ])
          )),
        ),
      ),
    );
  }

  bool _validateDisplaySelectedIcon({
    MailboxActions? actions,
    MailboxId? mailboxIdSelected
  }) {
    return (actions == MailboxActions.select || actions == MailboxActions.create)
      && (mailboxIdSelected == null || mailboxIdSelected == PresentationMailbox.unifiedMailbox.id);
  }

  void _handleOpenMailboxNodeClick(MailboxNode mailboxNode) {
    PresentationMailbox presentationMailbox;
    final path = controller.findNodePath(mailboxNode.item.id)
        ?? mailboxNode.item.name?.name;
    if (path != null) {
      presentationMailbox = mailboxNode.item
          .toPresentationMailboxWithMailboxPath(path);
    } else {
      presentationMailbox = mailboxNode.item;
    }
    controller.selectMailboxAction(presentationMailbox, mailboxNode: mailboxNode);
  }

  void _handleOpenPresentationMailboxClick(
      BuildContext context,
      PresentationMailbox presentationMailbox
  ) {
    PresentationMailbox newPresentationMailbox;
    if (presentationMailbox.id == PresentationMailbox.unifiedMailbox.id) {
      newPresentationMailbox = presentationMailbox
          .toPresentationMailboxWithMailboxPath(AppLocalizations.of(context).allFolders);
    } else {
      final path = controller.findNodePath(presentationMailbox.id)
          ?? presentationMailbox.name?.name;
      if (path != null) {
        newPresentationMailbox = presentationMailbox.toPresentationMailboxWithMailboxPath(path);
      } else {
        newPresentationMailbox = presentationMailbox;
      }
    }

    controller.selectMailboxAction(newPresentationMailbox);
  }

  Widget _buildInputSearchFormWidget(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: AppUtils.isDirectionRTL(context) ? 0 : 5,
                  right: AppUtils.isDirectionRTL(context) ? 5 : 0,
                ),
                child: buildIconWeb(
                  icon: SvgPicture.asset(
                    controller.imagePaths.icBack,
                    colorFilter: AppColor.colorTextButton.asFilter(),
                    fit: BoxFit.fill),
                  onTap: () => controller.disableSearch(context))),
              Expanded(child: SearchAppBarWidget(
                imagePaths: controller.imagePaths,
                searchQuery: controller.searchQuery.value,
                searchFocusNode: controller.searchFocus,
                searchInputController: controller.searchInputController,
                hasBackButton: false,
                hasSearchButton: true,
                padding: EdgeInsets.zero,
                margin: EdgeInsets.only(
                  right: DirectionUtils.isDirectionRTLByLanguage(context) ? 0 : 16,
                  left: DirectionUtils.isDirectionRTLByLanguage(context) ? 16 : 0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  color: AppColor.colorBgSearchBar),
                hintText: AppLocalizations.of(context).hintSearchFolders,
                onClearTextSearchAction: controller.clearSearchText,
                onTextChangeSearchAction: (query) => controller.searchMailbox(context, query),
                onSearchTextAction: (query) => controller.searchMailbox(context, query),
              ))
            ]
        )
    );
  }

  BorderRadius _getRadiusDestinationPicker(BuildContext context) {
    if (PlatformInfo.isMobile && controller.responsiveUtils.isLandscapeMobile(context)) {
      return BorderRadius.zero;
    } else if (controller.responsiveUtils.isMobile(context)) {
      return const BorderRadius.only(
          topRight: Radius.circular(16),
          topLeft: Radius.circular(16));
    } else {
      return const BorderRadius.all(Radius.circular(16));
    }
  }

  double _getWidthDestinationPicker(BuildContext context) {
    if (PlatformInfo.isWeb) {
      if (controller.responsiveUtils.isMobile(context)) {
        return double.infinity;
      } else {
        return 556;
      }
    } else {
      if (controller.responsiveUtils.isLandscapeMobile(context) ||
          controller.responsiveUtils.isPortraitMobile(context)) {
        return double.infinity;
      } else {
        return 556;
      }
    }
  }

  double _getHeightDestinationPicker(BuildContext context) {
    if (PlatformInfo.isWeb) {
      if (controller.responsiveUtils.isMobile(context)) {
        return double.infinity;
      } else {
        if (controller.responsiveUtils.getSizeScreenHeight(context) > _maxHeight) {
          return _maxHeight;
        } else {
          return double.infinity;
        }
      }
    } else {
      if (controller.responsiveUtils.isLandscapeMobile(context) ||
          controller.responsiveUtils.isPortraitMobile(context)) {
        return double.infinity;
      } else {
        if (controller.responsiveUtils.getSizeScreenHeight(context) > _maxHeight) {
          return _maxHeight;
        } else {
          return double.infinity;
        }
      }
    }

  }

  EdgeInsets _getMarginDestinationPicker(BuildContext context) {
    if (PlatformInfo.isWeb) {
      if (controller.responsiveUtils.isMobile(context)) {
        return EdgeInsets.zero;
      } else {
        if (controller.responsiveUtils.getSizeScreenHeight(context) > _maxHeight) {
          return const EdgeInsets.symmetric(vertical: 12);
        } else {
          return const EdgeInsets.symmetric(vertical: 50);
        }
      }
    } else {
      if (controller.responsiveUtils.isLandscapeMobile(context) ||
          controller.responsiveUtils.isPortraitMobile(context)) {
        return EdgeInsets.zero;
      } else {
        if (controller.responsiveUtils.getSizeScreenHeight(context) > _maxHeight) {
          return const EdgeInsets.symmetric(vertical: 12);
        } else {
          return const EdgeInsets.symmetric(vertical: 50);
        }
      }
    }
  }
}