
import 'package:equatable/equatable.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

class NewMailboxArguments with EquatableMixin{
  final String nameMailbox;
  final PresentationMailbox mailboxLocation;

  NewMailboxArguments(this.nameMailbox, this.mailboxLocation);

  @override
  List<Object?> get props => [nameMailbox, mailboxLocation];
}