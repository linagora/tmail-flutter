import 'package:core/core.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_button_new_folder_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_folder_tile_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_tile_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/search_form_widget_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/storage_widget_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/user_information_widget_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MailboxView extends GetWidget<MailboxController> {

  final imagePaths = Get.find<ImagePaths>();
  final responsiveUtils = Get.find<ResponsiveUtils>();

  @override
  Widget build(BuildContext context) {
    return  Drawer(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColor.primaryLightColor,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            right: false,
            left: false,
            child: RefreshIndicator(
              color: AppColor.primaryColor,
              onRefresh: () async => controller.refreshGetAllMailboxAction(),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderMailbox(context),
                        _buildSearchFormWidget(context),
                        _buildLoadingView(),
                        _buildListMailbox(context)
                      ]
                    )
                  )
                )
              )
            )
          )),
        bottomNavigationBar: responsiveUtils.isMobile(context) ? _buildStorageWidget(context) : null
      )
    );
  }

  Widget _buildHeaderMailbox(BuildContext context) {
    return ResponsiveWidget(
      tablet: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCloseScreenButton(context),
          _buildUserInformationWidget(context)
        ]),
      mobile: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCloseScreenButton(context),
          Expanded(child: _buildUserInformationWidget(context))
        ]),
      responsiveUtils: responsiveUtils);
  }

  Widget _buildCloseScreenButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, top: responsiveUtils.isMobile(context) ? 0 : 12),
      child: IconButton(
        key: Key('mailbox_close_button'),
        onPressed: () => controller.closeMailboxScreen(),
        icon: SvgPicture.asset(imagePaths.icCloseMailbox, width: 30, height: 30, fit: BoxFit.fill)));
  }

  Widget _buildUserInformationWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, top: 8.0, right: 16),
      child: Obx(() => UserInformationWidgetBuilder(
          imagePaths,
          controller.mailboxDashBoardController.userProfile.value)
        .build()));
  }

  Widget _buildSearchFormWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: 12, left: 16, right: 16),
      child: SearchFormWidgetBuilder(context, imagePaths)
        .onNewSearchQuery((searchQuery) => {})
        .build());
  }

  Widget _buildLoadingView() {
    return Obx(() => controller.viewState.value.fold(
      (failure) => SizedBox.shrink(),
      (success) => success == UIState.loading
        ? Center(child: Padding(
            padding: EdgeInsets.only(top: 16),
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(color: AppColor.primaryColor))))
        : SizedBox.shrink()));
  }

  Widget _buildListMailbox(BuildContext context) {
    return ListView(
      key: Key('mailbox_list'),
      primary: false,
      shrinkWrap: true,
      children: [
        Obx(() => controller.viewState.value.fold(
            (failure) => SizedBox.shrink(),
            (success) => success is GetAllMailboxSuccess
              ? _buildDefaultMailbox(context, success.defaultMailboxList)
              : SizedBox.shrink())
        ),
        Padding(
          padding: EdgeInsets.only(
            left: responsiveUtils.isMobile(context) ? 40 : 32,
            top: 20),
          child: Text(
            AppLocalizations.of(context).my_folders,
            maxLines: 1,
            style: TextStyle(fontSize: 12, color: AppColor.myFolderTitleColor, fontWeight: FontWeight.w500))
        ),
        Padding(
          padding: EdgeInsets.only(
            left: responsiveUtils.isMobile(context) ? 16 : 2,
            right: 16,
            top: 10),
          child: MailboxNewFolderTileBuilder(context, responsiveUtils)
            .addIcon(imagePaths.icMailboxNewFolder)
            .addName(AppLocalizations.of(context).new_folder)
            .build()
        ),
        _buildFolderMailbox(context),
      ]
    );
  }

  Widget _buildDefaultMailbox(BuildContext context, List<PresentationMailbox> defaultMailbox) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16),
      key: Key('default_mailbox_list'),
      itemCount: defaultMailbox.length,
      shrinkWrap: true,
      primary: false,
      itemBuilder: (context, index) =>
        Obx(() => MailboxTileBuilder(
            context,
            imagePaths,
            responsiveUtils,
            defaultMailbox[index],
            controller.getSelectMode(defaultMailbox[index], controller.mailboxDashBoardController.selectedMailbox.value))
          .onOpenMailboxAction(() => controller.selectMailbox(context, defaultMailbox[index]))
          .build()));
  }

  Widget _buildFolderMailbox(BuildContext context) {
    return Obx(() => controller.folderMailboxTree.value.root.hasChildren()
        ? Transform(
            transform: Matrix4.translationValues(responsiveUtils.isMobile(context) ? 0.0 : -15.0, 0.0, 0.0),
            child: Padding(
              padding: EdgeInsets.only(left: 4, right: 16),
              child: TreeView(
                startExpanded: false,
                key: Key('folder_mailbox_list'),
                children: _buildListChildTileWidget(context, controller.folderMailboxTree.value.root.childrenItems!)))
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
              key: Key('children_tree_mailbox_child'),
              parent: Obx(() => MailBoxFolderTileBuilder(
                    context,
                    imagePaths,
                    responsiveUtils,
                    mailboxNode,
                    controller.getSelectMode(mailboxNode.item, controller.mailboxDashBoardController.selectedMailbox.value))
                .build(context)),
              children: _buildListChildTileWidget(context, mailboxNode.childrenItems!)))
        : Padding(
            padding: EdgeInsets.only(left: 16),
            child: GestureDetector(
              onTap: () => controller.selectMailbox(context, mailboxNode.item),
              child: Obx(() => MailBoxFolderTileBuilder(
                    context,
                    imagePaths,
                    responsiveUtils,
                    mailboxNode,
                    controller.getSelectMode(mailboxNode.item, controller.mailboxDashBoardController.selectedMailbox.value))
                .build(context)))))
      .toList();
  }

  Widget _buildStorageWidget(BuildContext context) => StorageWidgetBuilder(context).build();
}