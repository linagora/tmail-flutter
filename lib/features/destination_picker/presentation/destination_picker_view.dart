import 'package:core/core.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          margin: _responsiveUtils.getMarginDestinationPicker(context),
          child: ClipRRect(
            borderRadius: _responsiveUtils.radiusDestinationPicker(context, 20),
            child: GestureDetector(
              onTap: () => {},
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.white,
                body: SafeArea(
                  right: false,
                  left: false,
                  child: Column(
                    children: [
                      _buildAppBar(context),
                      Expanded(child: _buildBodyDestinationPicker(context))
                    ],
                  )
                )
              )
            )
          )
        )
      )
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 24, right: 12),
      child: (AppBarDestinationPickerBuilder(context, _imagePaths, _responsiveUtils)
          ..addCloseActionClick(() => controller.closeDestinationPicker()))
        .build()
    );
  }

  Widget _buildBodyDestinationPicker(BuildContext context) {
    return RefreshIndicator(
      color: AppColor.primaryColor,
      onRefresh: () async => controller.getAllMailboxAction(),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          alignment: Alignment.center,
          color: AppColor.bgMailboxListMail,
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
      (success) => success == UIState.loading
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
      primary: false,
      shrinkWrap: true,
      children: [
        _buildDefaultMailbox(context),
        SizedBox(height: 20),
        _buildFolderMailbox(context),
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
            padding: EdgeInsets.only(top: 16, right: 10),
            key: Key('default_mailbox_list'),
            itemCount: defaultMailboxList.length,
            shrinkWrap: true,
            primary: false,
            itemBuilder: (context, index) => (MailboxTileBuilder(
                    context,
                    _imagePaths,
                    _responsiveUtils,
                    defaultMailboxList[index],
                    mailboxDisplayed: MailboxDisplayed.destinationPicker)
                ..onOpenMailboxAction((mailbox) => controller.moveEmailToMailboxAction(mailbox)))
              .build());
        } else {
          return SizedBox.shrink();
        }
      })
    );
  }

  Widget _buildFolderMailbox(BuildContext context) {
    return Obx(() => controller.folderMailboxTree.value.root.hasChildren()
      ? Transform(
          transform: Matrix4.translationValues(-12.0, 0.0, 0.0),
          child: Padding(
            padding: EdgeInsets.zero,
            child: TreeView(
              startExpanded: false,
              key: Key('folder_mailbox_list'),
              children: _buildListChildTileWidget(context, controller.folderMailboxTree.value.root.childrenItems!))))
      : SizedBox.shrink()
    );
  }

  List<Widget> _buildListChildTileWidget(BuildContext context, List<MailboxNode> listMailboxNode) {
    return listMailboxNode
      .map((mailboxNode) => mailboxNode.hasChildren()
          ? Padding(
              padding: EdgeInsets.only(left: 20),
              child: TreeViewChild(
                key: Key('children_tree_mailbox_child'),
                parent: MailBoxFolderTileBuilder(
                        context,
                        _imagePaths,
                        _responsiveUtils,
                        mailboxNode,
                        mailboxDisplayed: MailboxDisplayed.destinationPicker)
                    .build(),
                children: _buildListChildTileWidget(context, mailboxNode.childrenItems!)))
          : Padding(
              padding: EdgeInsets.only(left: 20),
              child: GestureDetector(
                onTap: () => controller.moveEmailToMailboxAction(mailboxNode.item),
                child: MailBoxFolderTileBuilder(
                      context,
                      _imagePaths,
                      _responsiveUtils,
                      mailboxNode,
                      mailboxDisplayed: MailboxDisplayed.destinationPicker)
                  .build(),
              )))
      .toList();
  }
}