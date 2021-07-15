import 'package:equatable/equatable.dart';
import 'package:model/core/id.dart';
import 'package:model/core/unsigned_int.dart';

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

class IsSubscribed with EquatableMixin {
  final bool value;

  IsSubscribed(this.value);

  @override
  List<Object?> get props => [value];
}