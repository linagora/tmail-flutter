
import 'package:equatable/equatable.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

class MailboxCreatorArguments with EquatableMixin{
  final List<PresentationMailbox> allMailboxes;

  MailboxCreatorArguments(this.allMailboxes);

  @override
  List<Object?> get props => [allMailboxes];
}