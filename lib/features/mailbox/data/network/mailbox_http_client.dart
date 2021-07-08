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

import 'dart:async';

import 'package:core/core.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_role.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailboxes.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/select_mode.dart';

class MailBoxHttpClient {

  final DioClient dioClient;

  MailBoxHttpClient(this.dioClient);

  Future<List<MailBoxes>> getAllMailBox() async {
    return [
      MailBoxes(
        MailboxId(Id('1')),
        MailboxName('Inbox'),
        null,
        MailBoxRole.inbox,
        SortOrder(),
        TotalEmails(UnsignedInt.defaultValue),
        UnreadEmails(UnsignedInt(100)),
        TotalThreads(UnsignedInt.defaultValue),
        UnreadThreads(UnsignedInt.defaultValue),
        null,
        IsSubscribed(false),
        selectMode: SelectMode.ACTIVE),
      MailBoxes(
        MailboxId(Id('2')),
        MailboxName('Drafts'),
        null,
        MailBoxRole.draft,
        SortOrder(),
        TotalEmails(UnsignedInt.defaultValue),
        UnreadEmails(UnsignedInt.defaultValue),
        TotalThreads(UnsignedInt.defaultValue),
        UnreadThreads(UnsignedInt.defaultValue),
        null,
        IsSubscribed(false),
      ),
      MailBoxes(
        MailboxId(Id('3')),
        MailboxName('Sent'),
        null,
        MailBoxRole.sent,
        SortOrder(),
        TotalEmails(UnsignedInt.defaultValue),
        UnreadEmails(UnsignedInt.defaultValue),
        TotalThreads(UnsignedInt.defaultValue),
        UnreadThreads(UnsignedInt.defaultValue),
        null,
        IsSubscribed(false),
      ),
      MailBoxes(
        MailboxId(Id('4')),
        MailboxName('All mail'),
        null,
        MailBoxRole.allMail,
        SortOrder(),
        TotalEmails(UnsignedInt.defaultValue),
        UnreadEmails(UnsignedInt(1200)),
        TotalThreads(UnsignedInt.defaultValue),
        UnreadThreads(UnsignedInt.defaultValue),
        null,
        IsSubscribed(false),
      ),
      MailBoxes(
        MailboxId(Id('5')),
        MailboxName('Trash'),
        null,
        MailBoxRole.trash,
        SortOrder(),
        TotalEmails(UnsignedInt.defaultValue),
        UnreadEmails(UnsignedInt.defaultValue),
        TotalThreads(UnsignedInt.defaultValue),
        UnreadThreads(UnsignedInt.defaultValue),
        null,
        IsSubscribed(false),
      ),
      MailBoxes(
        MailboxId(Id('6')),
        MailboxName('Spam'),
        null,
        MailBoxRole.spam,
        SortOrder(),
        TotalEmails(UnsignedInt.defaultValue),
        UnreadEmails(UnsignedInt.defaultValue),
        TotalThreads(UnsignedInt.defaultValue),
        UnreadThreads(UnsignedInt.defaultValue),
        null,
        IsSubscribed(false),
      ),
      MailBoxes(
        MailboxId(Id('7')),
        MailboxName('Templates'),
        null,
        MailBoxRole.templates,
        SortOrder(),
        TotalEmails(UnsignedInt.defaultValue),
        UnreadEmails(UnsignedInt.defaultValue),
        TotalThreads(UnsignedInt.defaultValue),
        UnreadThreads(UnsignedInt.defaultValue),
        null,
        IsSubscribed(false),
      ),
      MailBoxes(
        MailboxId(Id('8')),
        MailboxName('Folder 1'),
        MailboxId(Id('1')),
        MailBoxRole.none,
        SortOrder(),
        TotalEmails(UnsignedInt.defaultValue),
        UnreadEmails(UnsignedInt.defaultValue),
        TotalThreads(UnsignedInt.defaultValue),
        UnreadThreads(UnsignedInt.defaultValue),
        null,
        IsSubscribed(false),
      ),
      MailBoxes(
        MailboxId(Id('81')),
        MailboxName('Sub Folder 1'),
        null,
        MailBoxRole.none,
        SortOrder(),
        TotalEmails(UnsignedInt.defaultValue),
        UnreadEmails(UnsignedInt.defaultValue),
        TotalThreads(UnsignedInt.defaultValue),
        UnreadThreads(UnsignedInt.defaultValue),
        null,
        IsSubscribed(false),
      ),
      MailBoxes(
        MailboxId(Id('82')),
        MailboxName('Sub Folder 2'),
        null,
        MailBoxRole.none,
        SortOrder(),
        TotalEmails(UnsignedInt.defaultValue),
        UnreadEmails(UnsignedInt.defaultValue),
        TotalThreads(UnsignedInt.defaultValue),
        UnreadThreads(UnsignedInt.defaultValue),
        null,
        IsSubscribed(false),
      ),
      MailBoxes(
        MailboxId(Id('9')),
        MailboxName('Folder 2'),
        MailboxId(Id('2')),
        MailBoxRole.none,
        SortOrder(),
        TotalEmails(UnsignedInt.defaultValue),
        UnreadEmails(UnsignedInt.defaultValue),
        TotalThreads(UnsignedInt.defaultValue),
        UnreadThreads(UnsignedInt.defaultValue),
        null,
        IsSubscribed(false),
      ),
    ];
  }
}