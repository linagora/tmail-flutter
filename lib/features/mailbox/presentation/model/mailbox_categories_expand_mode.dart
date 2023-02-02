
import 'package:equatable/equatable.dart';
import 'package:model/mailbox/expand_mode.dart';

class MailboxCategoriesExpandMode with EquatableMixin {
   ExpandMode defaultMailbox;
   ExpandMode personalMailboxes;
   ExpandMode teamMailboxes;

  MailboxCategoriesExpandMode({
    required this.defaultMailbox, 
    required this.personalMailboxes,
    required this.teamMailboxes});

  factory MailboxCategoriesExpandMode.initial() {
    return MailboxCategoriesExpandMode(
      defaultMailbox: ExpandMode.EXPAND, 
      personalMailboxes: ExpandMode.EXPAND,
      teamMailboxes: ExpandMode.EXPAND);
  }

  @override
  List<Object?> get props => [defaultMailbox, personalMailboxes, teamMailboxes];
}