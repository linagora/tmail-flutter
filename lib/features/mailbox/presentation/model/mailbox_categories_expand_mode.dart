
import 'package:equatable/equatable.dart';
import 'package:model/mailbox/expand_mode.dart';

class MailboxCategoriesExpandMode with EquatableMixin {
   ExpandMode defaultMailbox;
   ExpandMode folderMailbox;

  MailboxCategoriesExpandMode({required this.defaultMailbox, required this.folderMailbox});

  factory MailboxCategoriesExpandMode.initial() {
    return MailboxCategoriesExpandMode(defaultMailbox: ExpandMode.EXPAND, folderMailbox: ExpandMode.EXPAND);
  }

  @override
  List<Object?> get props => [defaultMailbox, folderMailbox];
}