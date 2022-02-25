
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class RenameMailboxRequest with EquatableMixin {

  final MailboxName newName;
  final MailboxId mailboxId;

  RenameMailboxRequest(this.mailboxId, this.newName);

  @override
  List<Object?> get props => [mailboxId, newName];
}