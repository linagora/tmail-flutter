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

import 'package:equatable/equatable.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_role.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/select_mode.dart';

class MailBoxes with EquatableMixin {

  final MailboxId id;
  final MailboxName? name;
  final MailboxId? parentId;
  final MailBoxRole role;
  final SortOrder? sortOrder;
  final TotalEmails? totalEmails;
  final UnreadEmails? unreadEmails;
  final TotalThreads? totalThreads;
  final UnreadThreads? unreadThreads;
  final MailboxRights? myRights;
  final IsSubscribed? isSubscribed;
  final SelectMode selectMode;

  MailBoxes(
    this.id,
    this.name,
    this.parentId,
    this.role,
    this.sortOrder,
    this.totalEmails,
    this.unreadEmails,
    this.totalThreads,
    this.unreadThreads,
    this.myRights,
    this.isSubscribed,
    {
      this.selectMode = SelectMode.INACTIVE
    }
  );

  bool isRootFolder() => parentId != null && parentId!.id.value.isNotEmpty;

  String getNameMailBox() => name == null ? '' : name!.name;

  bool isValidCountMailBox() {
    if (role == MailBoxRole.createdFolder
        || role == MailBoxRole.inbox
        || role == MailBoxRole.allMail) {
      return true;
    }
    return false;
  }

  String getCountUnReadEmails() {
    if (unreadEmails == null || !isValidCountMailBox()) {
      return '';
    } else {
      return unreadEmails!.value.value <= 999 ? '${unreadEmails!.value.value}' : '999+';
    }
  }

  @override
  List<Object?> get props => [
    id,
    name,
    parentId,
    role
  ];
}