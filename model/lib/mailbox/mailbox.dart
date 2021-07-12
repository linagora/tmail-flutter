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
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart' as JMapMailbox;
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_rights.dart' as JMapMailboxRights;
import 'package:model/mailbox/mailbox_role.dart';
import 'package:model/mailbox/select_mode.dart';

class Mailbox with EquatableMixin {

  final JMapMailbox.MailboxId id;
  final JMapMailbox.MailboxName? name;
  final JMapMailbox.MailboxId? parentId;
  final MailboxRole role;
  final JMapMailbox.SortOrder? sortOrder;
  final JMapMailbox.TotalEmails? totalEmails;
  final JMapMailbox.UnreadEmails? unreadEmails;
  final JMapMailbox.TotalThreads? totalThreads;
  final JMapMailbox.UnreadThreads? unreadThreads;
  final JMapMailboxRights.MailboxRights? myRights;
  final JMapMailbox.IsSubscribed? isSubscribed;
  final SelectMode selectMode;

  Mailbox(
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

  bool isMailboxRole() => role != MailboxRole.none;

  String getNameMailbox() => name == null ? '' : name!.name;

  bool isValidCountMailbox() {
    if (role == MailboxRole.createdFolder
        || role == MailboxRole.inbox
        || role == MailboxRole.allMail) {
      return true;
    }
    return false;
  }

  String getCountUnReadEmails() {
    if (unreadEmails == null || !isValidCountMailbox()) {
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