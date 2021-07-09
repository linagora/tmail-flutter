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

import 'dart:collection';

import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/mailboxes_extension.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/mailbox_folder_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/state/mailbox_state.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

class MailBoxController extends GetxController {

  final GetAllMailBoxInteractor _getAllMailBoxInteractor;

  var mailBoxState = MailBoxState.IDLE.obs;

  var mailBoxList = <MailBoxes>[].obs;
  var mailBoxHasRoleList = <MailBoxes>[].obs;
  var mailBoxMyFolderList = <MailBoxFolder>[].obs;

  MailBoxController(this._getAllMailBoxInteractor);

  @override
  void onReady() {
    super.onReady();
    getAllMailBoxAction();
  }
  
  void getAllMailBoxAction() async {
    mailBoxState.value = MailBoxState.LOADING;
    await _getAllMailBoxInteractor.execute()
      .then((response) => response.fold(
        (failure) => mailBoxState.value = MailBoxState.FAILURE,
        (success) {
          mailBoxState.value = MailBoxState.SUCCESS;
          mailBoxList.value = success is GetAllMailBoxesViewState ? success.mailBoxesList : [];
          _setListMailBoxHasRole(mailBoxList);
          _setListMailBoxMyFolder(mailBoxList);
        }));
  }

  void _setListMailBoxHasRole(List<MailBoxes> mailboxesList) {
    mailBoxHasRoleList.value = mailboxesList
      .where((mailbox) => mailbox.role != MailBoxRole.none)
      .toList();
  }

  void _setListMailBoxMyFolder(List<MailBoxes> mailboxesList) {
    final mapsMyFolder = HashMap<MailboxId, List<MailBoxFolder>>();
    final listMailBoxFolder = mailboxesList
      .where((mailbox) => mailbox.role == MailBoxRole.none)
      .toList();

    MailboxId? parentID;
    var listChildMailBox = <MailBoxFolder>[];

    for (int i = 0; i < listMailBoxFolder.length; i++) {
      final mailbox = listMailBoxFolder[i];

      if (mailbox.isRootFolder()) {
        parentID = mailbox.parentId;
        listChildMailBox = <MailBoxFolder>[];
      } else {
        listChildMailBox.add(mailbox.toMailBoxFolder([]));
      }

      mapsMyFolder.addIf(() => parentID != null, parentID!, listChildMailBox);
    }

    final listFolderRoot = listMailBoxFolder.where((folder) => folder.isRootFolder()).toList();

    mailBoxMyFolderList.value = listFolderRoot
      .map((mailbox) => mailbox.toMailBoxFolder(mailbox.isRootFolder()
        ? mapsMyFolder[mailbox.parentId!] ?? []
        : []))
      .toList();
  }

  void closeMailBoxScreen() {
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  void selectMailBoxes(MailBoxes mailBoxes) {
    mailBoxHasRoleList.value = mailBoxHasRoleList.map((mailBox) => mailBox.id == mailBoxes.id
        ? mailBox.toMailBoxesSelected(SelectMode.ACTIVE)
        : mailBox.toMailBoxesSelected(SelectMode.INACTIVE))
      .toList();
  }

  void expandMyFolder(MailBoxFolder mailBoxFolder) {
    final newListFolder = mailBoxMyFolderList.map((folder) => folder.id == mailBoxFolder.id
        ? folder.expandMailBoxFolder(expandMode: mailBoxFolder.isExpand() ? ExpandMode.COLLAPSE : ExpandMode.EXPAND)
        : folder)
      .toList();
    mailBoxMyFolderList.value = newListFolder;
  }
}