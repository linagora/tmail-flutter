import 'package:core/core.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/state/mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_new_folder_tile_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_tile_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/search_form_widget_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/storage_widget_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/user_information_widget_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MailboxView extends GetWidget<MailboxController> {

  final mailboxController = Get.find<MailboxController>();
  final imagePaths = Get.find<ImagePaths>();
  final responsiveUtils = Get.find<ResponsiveUtils>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.primaryLightColor,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCloseScreenButton(),
            _buildUserInformationWidget(context),
            _buildSearchFormWidget(context),
            _buildLoadingView(),
            Expanded(child: RefreshIndicator(
              color: AppColor.primaryColor,
              onRefresh: () async => mailboxController.getAllMailboxAction(),
              child: Obx(() => mailboxController.mailboxList.length > 0
                ? _buildListMailbox(context, mailboxController.mailboxList)
                : SizedBox.shrink())))
          ])),
      bottomNavigationBar: _buildStorageWidget(context),
    );
  }

  Widget _buildCloseScreenButton() {
    return Padding(
      padding: EdgeInsets.only(left: 24, top: 12, right: 16),
      child: IconButton(
        key: Key('mailbox_close_button'),
        onPressed: () => mailboxController.closeMailboxScreen(),
        icon: SvgPicture.asset(imagePaths.icCloseMailbox, width: 30, height: 30, fit: BoxFit.fill)));
  }

  Widget _buildUserInformationWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, top: 8.0, right: 16),
      child: UserInformationWidgetBuilder()
        .onOpenUserInformationAction(() => {})
        .build());
  }

  Widget _buildSearchFormWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: 12, left: 16, right: 16),
      child: SearchFormWidgetBuilder(context)
        .onNewSearchQuery((searchQuery) => {})
        .build());
  }

  Widget _buildLoadingView() {
    return Obx(() => mailboxController.mailboxState.value.viewState.fold(
      (failure) => SizedBox.shrink(),
      (success) => success is MailboxStateLoadingAction
        ? Center(child: Padding(
            padding: EdgeInsets.only(top: 16),
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(color: AppColor.primaryColor))))
        : SizedBox.shrink()));
  }

  Widget _buildListMailbox(BuildContext context, List<Mailbox> mailboxList) {
    return ListView(
      key: Key('mailbox_list'),
      primary: true,
      children: [
        Obx(() => mailboxController.mailboxHasRoleList.length > 0
          ? _buildListMailboxHasRole(mailboxController.mailboxHasRoleList)
          : SizedBox.shrink()),
        _buildTitleMailboxMyFolder(context),
        _buildTileNewFolder(context),
        Obx(() => mailboxController.mailboxMyFolderList.length > 0
          ? _buildListMailboxMyFolder(mailboxController.mailboxMyFolderList)
          : SizedBox.shrink()),
      ]
    );
  }

  Widget _buildListMailboxHasRole(List<Mailbox> mailboxHasRoleList) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16),
      key: Key('mailbox_has_role_list'),
      itemCount: mailboxHasRoleList.length,
      shrinkWrap: true,
      primary: false,
      itemBuilder: (context, index) =>
        MailboxTileBuilder(mailboxHasRoleList[index])
          .onOpenMailboxAction(() => mailboxController.selectMailbox(mailboxHasRoleList[index]))
          .build());
  }

  Widget _buildTitleMailboxMyFolder(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 40, top: 20),
      child: Text(
        AppLocalizations.of(context).my_folders,
        maxLines: 1,
        style: TextStyle(fontSize: 12, color: AppColor.myFolderTitleColor, fontWeight: FontWeight.w500)));
  }

  Widget _buildTileNewFolder(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 10),
      child: MailboxNewFolderTileBuilder()
        .addIcon(imagePaths.icMailboxNewFolder)
        .addName(AppLocalizations.of(context).new_folder)
        .onOpenMailboxFolderAction(() => {})
        .build());
  }

  Widget _buildListMailboxMyFolder(List<Mailbox> mailboxMyFolderList) {
    return ListView.builder(
      padding: EdgeInsets.only(left: 21, right: 16),
      key: Key('list_mailbox_my_folder'),
      itemCount: mailboxMyFolderList.length,
      shrinkWrap: true,
      primary: false,
      itemBuilder: (context, index) =>
        MailboxTileBuilder(mailboxMyFolderList[index])
          .onOpenMailboxAction(() => {})
          .build());
  }

  Widget _buildStorageWidget(BuildContext context) => StorageWidgetBuilder(context).build();
}