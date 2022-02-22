import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/destination_picker_controller.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/widgets/app_bar_destination_picker_builder.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_displayed.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_folder_tile_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_tile_builder.dart';

class DestinationPickerView extends GetWidget<DestinationPickerController> {

  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.closeDestinationPicker(),
      child: Card(
        margin: EdgeInsets.zero,
        borderOnForeground: false,
        color: Colors.transparent,
        child: Container(
          margin: _getMarginDestinationPicker(context),
          child: ClipRRect(
            borderRadius: _radiusDestinationPicker(context, 20),
            child: GestureDetector(
              onTap: () => {},
              child: SafeArea(
                  top: _responsiveUtils.isMobile(context) ? true : false,
                  bottom: false,
                  right: false,
                  left: false,
                  child: Column(
                    children: [
                      _buildAppBar(context),
                      Expanded(child:
                      Container(
                          color: AppColor.colorBgMailbox,
                          child: _buildBodyDestinationPicker(context)))
                    ],
                  )
              )
            )
          )
        )
      )
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return (AppBarDestinationPickerBuilder(context, _imagePaths, _responsiveUtils)
        ..addCloseActionClick(() => controller.closeDestinationPicker()))
      .build();
  }

  Widget _buildBodyDestinationPicker(BuildContext context) {
    return RefreshIndicator(
      color: AppColor.primaryColor,
      onRefresh: () async => controller.getAllMailboxAction(),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          alignment: Alignment.center,
          color: AppColor.colorBgMailbox,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLoadingView(),
              _buildListMailbox(context)
            ]
          )
        )
      )
    );
  }

  Widget _buildLoadingView() {
    return Obx(() => controller.viewState.value.fold(
      (failure) => SizedBox.shrink(),
      (success) => success is LoadingState
        ? Center(
          child: Padding(
            padding: EdgeInsets.only(top: 16),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: AppColor.primaryColor))))
        : SizedBox.shrink()));
  }

  Widget _buildListMailbox(BuildContext context) {
    return ListView(
      primary: false,
      shrinkWrap: true,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white),
          margin: EdgeInsets.only(left: 16, right: 16, top: 16),
          child: _buildDefaultMailbox(context)),
        SizedBox(height: 20),
        Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white),
            margin: EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 30),
            child: _buildFolderMailbox(context)),
      ]
    );
  }

  Widget _buildDefaultMailbox(BuildContext context) {
    return Obx(() => controller.viewState.value.fold(
      (failure) => SizedBox.shrink(),
      (success) {
        if (success is GetAllMailboxSuccess) {
          final defaultMailboxList = success.defaultMailboxList;
          return ListView.builder(
            padding: EdgeInsets.only(top: 8, left: 8, right: 10, bottom: 8),
            key: Key('default_mailbox_list'),
            itemCount: defaultMailboxList.length,
            shrinkWrap: true,
            primary: false,
            itemBuilder: (context, index) => (MailboxTileBuilder(
                    _imagePaths,
                    defaultMailboxList[index],
                    mailboxDisplayed: MailboxDisplayed.destinationPicker,
                    isLastElement: index == defaultMailboxList.length - 1)
                ..onOpenMailboxAction((mailbox) =>
                    controller.moveEmailToMailboxAction(mailbox.toPresentationMailboxWithMailboxPath(mailbox.name?.name ?? ''))))
              .build());
        } else {
          return SizedBox.shrink();
        }
      })
    );
  }

  Widget _buildFolderMailbox(BuildContext context) {
    return Obx(() => controller.folderMailboxNodeList.isNotEmpty
      ? Padding(
          padding: EdgeInsets.only(top: 8, bottom: 8),
          child: TreeView(
              startExpanded: false,
              key: Key('folder_mailbox_list'),
              children: _buildListChildTileWidget(context, controller.folderMailboxNodeList)))
      : SizedBox.shrink()
    );
  }

  List<Widget> _buildListChildTileWidget(BuildContext context, List<MailboxNode> listMailboxNode) {
    return listMailboxNode
      .map((mailboxNode) => mailboxNode.hasChildren()
          ? Padding(
              padding: EdgeInsets.only(left: 20),
              child:  TreeViewChild(
                  context,
                  key: Key('children_tree_mailbox_child'),
                  isExpanded: mailboxNode.expandMode == ExpandMode.EXPAND,
                  parent: (MailBoxFolderTileBuilder(
                            context,
                            _imagePaths,
                            mailboxNode,
                            mailboxDisplayed: MailboxDisplayed.destinationPicker)
                        ..addOnSelectMailboxFolderClick((mailboxNode) => controller.moveEmailToMailboxAction(mailboxNode.item.toPresentationMailboxWithMailboxPath(
                            mailboxNode.getPathMailboxNode(
                              controller.folderMailboxTree,
                              controller.defaultMailboxList,
                            ))))
                        ..addOnExpandFolderActionClick((mailboxNode) => controller.toggleMailboxFolder(mailboxNode)))
                      .build(),
                  children: _buildListChildTileWidget(context, mailboxNode.childrenItems!)
              ).build())
          : Padding(
              padding: EdgeInsets.only(left: 20),
              child: (MailBoxFolderTileBuilder(
                      context,
                      _imagePaths,
                      mailboxNode,
                      mailboxDisplayed: MailboxDisplayed.destinationPicker)
                  ..addOnSelectMailboxFolderClick((mailboxNode) => controller.moveEmailToMailboxAction(mailboxNode.item.toPresentationMailboxWithMailboxPath(
                      mailboxNode.getPathMailboxNode(
                        controller.folderMailboxTree,
                        controller.defaultMailboxList,
                      )))))
                .build(),
              ))
      .toList();
  }

  EdgeInsets _getMarginDestinationPicker(BuildContext context) {
    if (_responsiveUtils.isMobileDevice(context) && _responsiveUtils.isLandscape(context)) {
      return EdgeInsets.only(
          left: _responsiveUtils.tabletHorizontalMargin,
          right: _responsiveUtils.tabletHorizontalMargin,
          top: 50.0);
    } else if (_responsiveUtils.isTablet(context)) {
      return _responsiveUtils.getSizeHeightScreen(context) <= _responsiveUtils.tabletVerticalMargin * 2
          ? EdgeInsets.symmetric(
              horizontal: _responsiveUtils.tabletHorizontalMargin,
              vertical: 0.0)
          : EdgeInsets.symmetric(
              horizontal: _responsiveUtils.tabletHorizontalMargin,
              vertical: _responsiveUtils.tabletVerticalMargin);
    } else if (_responsiveUtils.isDesktop(context) || _responsiveUtils.isTabletLarge(context)) {
      return _responsiveUtils.getSizeHeightScreen(context) <= _responsiveUtils.desktopVerticalMargin * 2
          ? EdgeInsets.symmetric(
              horizontal: _responsiveUtils.desktopHorizontalMargin,
              vertical: 0.0)
          : EdgeInsets.symmetric(
              horizontal: _responsiveUtils.desktopHorizontalMargin,
              vertical: _responsiveUtils.desktopVerticalMargin);
    } else {
      return EdgeInsets.zero;
    }
  }

  BorderRadius _radiusDestinationPicker(BuildContext context, double radius) {
    if (_responsiveUtils.isMobileDevice(context) && _responsiveUtils.isLandscape(context)) {
      return BorderRadius.only(topLeft: Radius.circular(radius), topRight: Radius.circular(radius));
    } else if (_responsiveUtils.isTablet(context)) {
      return _responsiveUtils.getSizeHeightScreen(context) <= _responsiveUtils.tabletVerticalMargin * 2
          ? BorderRadius.only(topLeft: Radius.circular(radius), topRight: Radius.circular(radius))
          : BorderRadius.circular(radius);
    } else if (_responsiveUtils.isDesktop(context) || _responsiveUtils.isTabletLarge(context)) {
      return _responsiveUtils.getSizeHeightScreen(context) <= _responsiveUtils.desktopVerticalMargin * 2
          ? BorderRadius.only(topLeft: Radius.circular(radius), topRight: Radius.circular(radius))
          : BorderRadius.circular(radius);
    } else {
      return BorderRadius.only(topLeft: Radius.circular(radius), topRight: Radius.circular(radius));
    }
  }
}