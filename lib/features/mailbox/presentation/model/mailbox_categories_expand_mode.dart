
import 'package:equatable/equatable.dart';
import 'package:model/mailbox/expand_mode.dart';

class MailboxCategoriesExpandMode with EquatableMixin {
   ExpandMode defaultMailbox;
   ExpandMode personalFolders;
   ExpandMode teamMailboxes;

  MailboxCategoriesExpandMode({
    required this.defaultMailbox, 
    required this.personalFolders,
    required this.teamMailboxes});

  factory MailboxCategoriesExpandMode.initial() {
    return MailboxCategoriesExpandMode(
      defaultMailbox: ExpandMode.EXPAND,
      personalFolders: ExpandMode.EXPAND,
      teamMailboxes: ExpandMode.EXPAND);
  }

  @override
  List<Object?> get props => [defaultMailbox, personalFolders, teamMailboxes];
}