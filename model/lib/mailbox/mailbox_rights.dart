import 'package:equatable/equatable.dart';

class MailboxRights with EquatableMixin {
  final bool mayReadItems;
  final bool mayAddItems;
  final bool mayRemoveItems;
  final bool maySetSeen;
  final bool maySetKeywords;
  final bool mayCreateChild;
  final bool mayRename;
  final bool mayDelete;
  final bool maySubmit;

  MailboxRights(
    this.mayReadItems,
    this.mayAddItems,
    this.mayRemoveItems,
    this.maySetSeen,
    this.maySetKeywords,
    this.mayCreateChild,
    this.mayRename,
    this.mayDelete,
    this.maySubmit
  );

  @override
  List<Object?> get props => [
    mayReadItems,
    mayAddItems,
    mayRemoveItems,
    maySetSeen,
    maySetKeywords,
    mayCreateChild,
    mayRename,
    mayDelete,
    maySubmit
  ];
}