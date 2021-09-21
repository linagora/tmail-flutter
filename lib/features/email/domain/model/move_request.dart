
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

class MoveRequest with EquatableMixin {

  final List<EmailId> emailIds;
  final MailboxId currentMailboxId;
  final MailboxId destinationMailboxId;
  final MoveAction moveAction;
  final String? destinationPath;

  MoveRequest(
    this.emailIds,
    this.currentMailboxId,
    this.destinationMailboxId,
    this.moveAction,
    {
      this.destinationPath,
    }
  );

  @override
  List<Object?> get props => [
    emailIds,
    currentMailboxId,
    destinationMailboxId,
    moveAction,
    destinationPath,
  ];
}