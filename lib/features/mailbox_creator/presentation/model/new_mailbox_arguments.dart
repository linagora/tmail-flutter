
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

class NewMailboxArguments with EquatableMixin {
  final MailboxName newName;
  final PresentationMailbox? mailboxLocation;

  NewMailboxArguments(this.newName, {this.mailboxLocation});

  @override
  List<Object?> get props => [newName, mailboxLocation];
}