import 'package:equatable/equatable.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

class MailboxCreatorArguments with EquatableMixin {
  final List<PresentationMailbox> listMailboxes;
  final PresentationMailbox? selectedMailbox;

  MailboxCreatorArguments(this.listMailboxes, this.selectedMailbox);

  @override
  List<Object?> get props => [listMailboxes, selectedMailbox];
}
