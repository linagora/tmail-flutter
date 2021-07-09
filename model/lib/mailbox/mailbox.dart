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
import 'package:quiver/check.dart';

class UnsignedInt {
  static final defaultValue = UnsignedInt(0);

  final num value;

  // UnsignedInt in range [0...2^53-1].
  UnsignedInt(this.value) {
    checkArgument(value >= 0);
    checkArgument(value < 9007199254740992);
  }
}

class Id with EquatableMixin {
  final RegExp _idCharacterConstraint = RegExp(r'^[a-zA-Z0-9]+[a-zA-Z0-9-_]*$');
  final String value;

  Id(this.value) {
    checkArgument(value.isNotEmpty, message: 'invalid length');
    checkArgument(value.length < 255, message: 'invalid length');
    checkArgument(_idCharacterConstraint.hasMatch(value));
  }

  @override
  List<Object?> get props => [value];
}

class MailboxId with EquatableMixin {
  final Id id;

  MailboxId(this.id);

  @override
  List<Object?> get props => [id];
}

class MailboxName with EquatableMixin {
  final String name;

  MailboxName(this.name);

  @override
  List<Object?> get props => [name];
}

class Role with EquatableMixin {
  final String value;

  Role(this.value);

  @override
  List<Object?> get props => [value];
}

class SortOrder with EquatableMixin {
  late final UnsignedInt value;

  SortOrder({int sortValue = 0}) {
    this.value = UnsignedInt(sortValue);
  }

  @override
  List<Object?> get props => [value];
}

class TotalEmails with EquatableMixin {
  final UnsignedInt value;

  TotalEmails(this.value);

  @override
  List<Object?> get props => [value];
}

class UnreadEmails with EquatableMixin {
  final UnsignedInt value;

  UnreadEmails(this.value);

  @override
  List<Object?> get props => [value];
}

class TotalThreads with EquatableMixin {
  final UnsignedInt value;

  TotalThreads(this.value);

  @override
  List<Object?> get props => [value];
}

class UnreadThreads with EquatableMixin {
  final UnsignedInt value;

  UnreadThreads(this.value);

  @override
  List<Object?> get props => [value];
}

class MailboxRights with EquatableMixin {
  final MayReadItems mayReadItems;
  final MayAddItems mayAddItems;
  final MayRemoveItems mayRemoveItems;
  final MaySetSeen maySetSeen;
  final MaySetKeywords maySetKeywords;
  final MayCreateChild mayCreateChild;
  final MayRename mayRename;
  final MayDelete mayDelete;
  final MaySubmit maySubmit;

  MailboxRights(
      this.mayReadItems,
      this.mayAddItems,
      this.mayRemoveItems,
      this.maySetSeen,
      this.maySetKeywords,
      this.mayCreateChild,
      this.mayRename,
      this.mayDelete,
      this.maySubmit);

  @override
  List<Object?> get props => [mayReadItems, mayAddItems, mayRemoveItems, maySetSeen,
    maySetKeywords, mayCreateChild, mayRename, mayDelete, maySubmit];
}

class MayReadItems with EquatableMixin {
  final bool value;

  MayReadItems(this.value);

  @override
  List<Object?> get props => [value];
}

class MayAddItems with EquatableMixin{
  final bool value;

  MayAddItems(this.value);

  @override
  List<Object?> get props => [value];
}

class MayRemoveItems with EquatableMixin {
  final bool value;

  MayRemoveItems(this.value);

  @override
  List<Object?> get props => [value];
}

class MaySetSeen with EquatableMixin {
  final bool value;

  MaySetSeen(this.value);

  @override
  List<Object?> get props => [value];
}

class MaySetKeywords with EquatableMixin {
  final bool value;

  MaySetKeywords(this.value);

  @override
  List<Object?> get props => [value];
}

class MayCreateChild with EquatableMixin {
  final bool value;

  MayCreateChild(this.value);

  @override
  List<Object?> get props => [value];
}

class MayRename with EquatableMixin {
  final bool value;

  MayRename(this.value);

  @override
  List<Object?> get props => [value];
}

class MayDelete with EquatableMixin {
  final bool value;

  MayDelete(this.value);

  @override
  List<Object?> get props => [value];
}

class MaySubmit with EquatableMixin {
  final bool value;

  MaySubmit(this.value);

  @override
  List<Object?> get props => [value];
}

class IsSubscribed with EquatableMixin {
  final bool value;

  IsSubscribed(this.value);

  @override
  List<Object?> get props => [value];
}