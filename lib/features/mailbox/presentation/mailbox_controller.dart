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
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart' as JMapMailbox;
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/mailboxes_extension.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/mailbox_folder_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/state/mailbox_state.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

class MailboxController extends GetxController {

  final GetAllMailboxInteractor _getAllMailboxInteractor;

  var mailboxState = MailboxState.IDLE.obs;

  var mailboxList = <Mailbox>[].obs;
  var mailboxHasRoleList = <Mailbox>[].obs;
  var mailboxMyFolderList = <MailboxFolder>[].obs;

  MailboxController(this._getAllMailboxInteractor);

  @override
  void onReady() {
    super.onReady();
    getAllMailboxAction();
  }
  
  void getAllMailboxAction() async {
    mailboxState.value = MailboxState.LOADING;
    await _getAllMailboxInteractor.execute()
      .then((response) => response.fold(
        (failure) => mailboxState.value = MailboxState.FAILURE,
        (success) {
          mailboxState.value = MailboxState.SUCCESS;
          mailboxList.value = success is GetAllMailboxViewState ? success.mailboxList : [];
          _setListMailboxHasRole(mailboxList);
          _setListMailboxMyFolder(mailboxList);
        }));
  }

  void _setListMailboxHasRole(List<Mailbox> mailboxesList) {
    mailboxHasRoleList.value = mailboxesList
      .where((mailbox) => mailbox.role != MailboxRole.none)
      .toList();
  }

  void _setListMailboxMyFolder(List<Mailbox> mailboxesList) {
    final mapsMyFolder = HashMap<JMapMailbox.MailboxId, List<MailboxFolder>>();
    final listMailboxFolder = mailboxesList
      .where((mailbox) => mailbox.role == MailboxRole.none)
      .toList();

    JMapMailbox.MailboxId? parentID;
    var listChildMailbox = <MailboxFolder>[];

    for (int i = 0; i < listMailboxFolder.length; i++) {
      final mailbox = listMailboxFolder[i];

      if (mailbox.isRootFolder()) {
        parentID = mailbox.parentId;
        listChildMailbox = <MailboxFolder>[];
      } else {
        listChildMailbox.add(mailbox.toMailboxFolder([]));
      }

      mapsMyFolder.addIf(() => parentID != null, parentID!, listChildMailbox);
    }

    final listFolderRoot = listMailboxFolder.where((folder) => folder.isRootFolder()).toList();

    mailboxMyFolderList.value = listFolderRoot
      .map((mailbox) => mailbox.toMailboxFolder(mailbox.isRootFolder()
        ? mapsMyFolder[mailbox.parentId!] ?? []
        : []))
      .toList();
  }

  void closeMailboxScreen() {
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  void selectMailbox(Mailbox mailbox) {
    mailboxHasRoleList.value = mailboxHasRoleList.map((mailbox) => mailbox.id == mailbox.id
        ? mailbox.toMailboxSelected(SelectMode.ACTIVE)
        : mailbox.toMailboxSelected(SelectMode.INACTIVE))
      .toList();
  }

  void expandMyFolder(MailboxFolder mailboxFolder) {
    final newListFolder = mailboxMyFolderList.map((folder) => folder.id == mailboxFolder.id
        ? folder.expandMailboxFolder(expandMode: mailboxFolder.isExpand() ? ExpandMode.COLLAPSE : ExpandMode.EXPAND)
        : folder)
      .toList();
    mailboxMyFolderList.value = newListFolder;
  }
}