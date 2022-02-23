import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/destination_picker_controller.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/widgets/app_bar_destination_picker_builder.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_displayed.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_folder_tile_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_tile_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class DestinationPickerView extends GetWidget<DestinationPickerController> {

  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  @override
  Widget build(BuildContext context) {
    MailboxActions? actions;
    final arguments = Get.arguments;
    if (arguments != null && arguments is DestinationPickerArguments) {
      actions = arguments.mailboxAction;
    }

    if (actions == MailboxActions.create) {
      return Card(
          margin: EdgeInsets.zero,
          borderOnForeground: false,
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () => controller.closeDestinationPicker(),
            child: ResponsiveWidget(
                responsiveUtils: _responsiveUtils,
                mobile: _responsiveUtils.isPortrait(context)
                  ? Container(
                      child: _buildBodyMailboxLocation(context, actions),
                      width: _responsiveUtils.getSizeWidthScreen(context))
                  : _buildBodyMailboxDestination(context, actions),
                tablet: Container(
                    child: Row(
                        children: [
                          Expanded(flex: 1, child: Container(color: Colors.transparent)),
                          Expanded(flex: 1, child: _buildBodyMailboxLocation(context, actions)),
                        ]
                    )
                ),
                tabletLarge: Container(
                    child: Row(
                        children: [
                          Expanded(flex: 7, child: Container(color: Colors.transparent)),
                          Expanded(flex: 13, child: _buildBodyMailboxLocation(context, actions)),
                        ]
                    )
                ),
                desktop: Container(
                    child: Row(
                        children: [
                          Expanded(flex: 1, child: Container(color: Colors.transparent)),
                          Expanded(flex: 3, child: _buildBodyMailboxLocation(context, actions)),
                        ]
                    )
                )
            ),
          )
      );
    } else {
      return _buildBodyMailboxDestination(context, actions);
    }
  }

  Widget _buildBodyMailboxDestination(BuildContext context, MailboxActions? actions) {
    return GestureDetector(
        onTap: () => controller.closeDestinationPicker(),
        child: Card(
            margin: EdgeInsets.zero,
            borderOnForeground: false,
            color: Colors.transparent,
            child: Container(
                margin: _getMarginDestinationPicker(context),
                child: ClipRRect(
                    borderRadius: _radiusDestinationPicker(context, 14),
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
                                    child: _buildBodyDestinationPicker(context, actions)))
                              ],
                            )
                        )
                    )
                )
            )
        )
    );
  }

  Widget _buildBodyMailboxLocation(BuildContext context, MailboxActions? actions) {
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
                child: Container(
                    color: AppColor.colorBgMailbox,
                    width: double.infinity,
                    child: SafeArea(
                      top: false,
                      bottom: false,
                      left: _responsiveUtils.isMobileDevice(context) ? true : false,
                      right: _responsiveUtils.isMobileDevice(context) ? true : false,
                      child: Column(
                          children: [
                            _buildAppBar(context),
                            Expanded(
                              child: Container(
                                color: AppColor.colorBgMailbox,
                                child: _buildBodyDestinationPicker(context, actions)
                              )
                            )
                          ]
                      ),
                    )
                )
            )
        )
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Obx(() => (AppBarDestinationPickerBuilder(
            context,
            _imagePaths,
            _responsiveUtils,
            controller.mailboxAction.value)
        ..addCloseActionClick(() => controller.closeDestinationPicker()))
      .build());
  }

  Widget _buildBodyDestinationPicker(BuildContext context, MailboxActions? actions) {
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
              if (actions == MailboxActions.create) _buildUnifiedMailbox(context),
              _buildListMailbox(context, actions)
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

  Widget _buildListMailbox(BuildContext context, MailboxActions? actions) {
    return ListView(
      primary: false,
      shrinkWrap: true,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white),
          margin: EdgeInsets.only(left: 16, right: 16, top: _getTopPaddingListMailbox(context, actions)),
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

  double _getTopPaddingListMailbox(BuildContext context, MailboxActions? actions) {
    if (actions == MailboxActions.create) {
      return (_responsiveUtils.isMobile(context) || _responsiveUtils.isMobileDevice(context)) ? 20.0 : 5.0;
    } else {
      return (_responsiveUtils.isMobile(context) || _responsiveUtils.isMobileDevice(context)) ? 16.0 : 10.0;
    }
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
                    controller.selectMailboxAction(mailbox.toPresentationMailboxWithMailboxPath(mailbox.name?.name ?? ''))))
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
                        ..addOnSelectMailboxFolderClick((mailboxNode) => controller.selectMailboxAction(mailboxNode.item.toPresentationMailboxWithMailboxPath(
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
                  ..addOnSelectMailboxFolderClick((mailboxNode) => controller.selectMailboxAction(mailboxNode.item.toPresentationMailboxWithMailboxPath(
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

  Widget _buildUnifiedMailbox(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(left: 16, right: 16, top: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.white),
      child: MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.zero),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: () => controller.selectMailboxAction(null),
          leading: Padding(
            padding: EdgeInsets.only(left: 16),
            child: SvgPicture.asset(_imagePaths.icFolderMailbox, width: 28, height: 28, fit: BoxFit.fill)),
          title: Transform(
            transform: Matrix4.translationValues(-5.0, 0.0, 0.0),
            child: Row(
              children: [
                Expanded(child: Text(
                  AppLocalizations.of(context).default_mailbox,
                  maxLines: 1,
                  overflow:TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, color: AppColor.colorNameEmail),
                ))
              ]
            )
          ),
        ),
      )
    );
  }
}