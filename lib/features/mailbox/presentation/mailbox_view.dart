// LinShare is an open source filesharing software, part of the LinPKI software
// suite, developed by Linagora.
//
// Copyright (C) 2020 LINAGORA
//
// This program is free software: you can redistribute it and/or modify it under the
// terms of the GNU Affero General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later version,
// provided you comply with the Additional Terms applicable for LinShare software by
// Linagora pursuant to Section 7 of the GNU Affero General Public License,
// subsections (b), (c), and (e), pursuant to which you must notably (i) retain the
// display in the interface of the “LinShare™” trademark/logo, the "Libre & Free" mention,
// the words “You are using the Free and Open Source version of LinShare™, powered by
// Linagora © 2009–2020. Contribute to Linshare R&D by subscribing to an Enterprise
// offer!”. You must also retain the latter notice in all asynchronous messages such as
// e-mails sent with the Program, (ii) retain all hypertext links between LinShare and
// http://www.linshare.org, between linagora.com and Linagora, and (iii) refrain from
// infringing Linagora intellectual property rights over its trademarks and commercial
// brands. Other Additional Terms apply, see
// <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf>
// for more details.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
// more details.
// You should have received a copy of the GNU Affero General Public License and its
// applicable Additional Terms for LinShare along with this program. If not, see
// <http://www.gnu.org/licenses/> for the GNU Affero General Public License version
//  3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf> for
//  the Additional Terms applicable to LinShare software.

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
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_folder_tile_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_new_folder_tile_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_tile_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/search_form_widget_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/storage_widget_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/user_information_widget_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MailBoxView extends GetWidget<MailBoxController> {

  final mailBoxController = Get.find<MailBoxController>();
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
              onRefresh: () async => mailBoxController.getAllMailBoxAction(),
              child: Obx(() => mailBoxController.mailBoxList.length > 0
                ? _buildListMailBox(context, mailBoxController.mailBoxList)
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
        onPressed: () => mailBoxController.closeMailBoxScreen(),
        icon: SvgPicture.asset(imagePaths.icCloseMailBox, width: 30, height: 30, fit: BoxFit.fill)));
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
    return Obx(() => mailBoxController.mailBoxState.value == MailBoxState.LOADING
      ? Center(child: Padding(
          padding: EdgeInsets.only(top: 16),
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(color: AppColor.primaryColor))))
      : SizedBox.shrink());
  }

  Widget _buildListMailBox(BuildContext context, List<MailBoxes> mailBoxList) {
    return ListView(
      key: Key('mailbox_list'),
      primary: true,
      children: [
        Obx(() => mailBoxController.mailBoxHasRoleList.length > 0
          ? _buildListMailBoxHasRole(mailBoxController.mailBoxHasRoleList)
          : SizedBox.shrink()),
        _buildTitleMailBoxMyFolder(context),
        _buildTileNewFolder(context),
        Obx(() => mailBoxController.mailBoxMyFolderList.length > 0
          ? _buildListMailBoxMyFolder(mailBoxController.mailBoxMyFolderList)
          : SizedBox.shrink()),
      ]
    );
  }

  Widget _buildListMailBoxHasRole(List<MailBoxes> mailBoxHasRoleList) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16),
      key: Key('mailbox_has_role_list'),
      itemCount: mailBoxHasRoleList.length,
      shrinkWrap: true,
      primary: false,
      itemBuilder: (context, index) =>
        MailBoxTileBuilder(mailBoxHasRoleList[index])
          .onOpenMailBoxAction(() => mailBoxController.selectMailBoxes(mailBoxHasRoleList[index]))
          .build());
  }

  Widget _buildTitleMailBoxMyFolder(BuildContext context) {
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
      child: MailBoxNewFolderTileBuilder()
        .addIcon(imagePaths.icMailBoxNewFolder)
        .addName(AppLocalizations.of(context).new_folder)
        .onOpenMailBoxFolderAction(() => {})
        .build());
  }

  Widget _buildListMailBoxMyFolder(List<MailBoxFolder> mailBoxMyFolderList) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16),
      child: TreeView(
        key: Key('list_mailbox_folder'),
        children: _buildListTileMyFolder(mailBoxMyFolderList)
      )
    );
  }

  List<Widget> _buildListTileMyFolder(List<MailBoxFolder> mailBoxMyFolderList) {
    return mailBoxMyFolderList.map((mailBoxFolder) =>
      mailBoxFolder.isRootFolder()
        ? TreeViewChild(
            key: Key('mailbox_folder_child'),
            startExpanded: mailBoxFolder.isExpand(),
            parent: _buildTileFolderWidget(mailBoxFolder: mailBoxFolder),
            children: _buildListTileMyFolder(mailBoxFolder.childList))
        : Padding(
            padding: EdgeInsets.only(left: 16),
            child: _buildTileFolderWidget(mailBoxFolder: mailBoxFolder))
    ).toList();
  }

  Widget _buildTileFolderWidget({required MailBoxFolder mailBoxFolder}) {
    return MailBoxFolderTileBuilder(mailBoxFolder)
      .onOpenMailBoxFolderAction((folder) => mailBoxController.expandMyFolder(folder))
      .build();
  }

  Widget _buildStorageWidget(BuildContext context) => StorageWidgetBuilder(context).build();
}