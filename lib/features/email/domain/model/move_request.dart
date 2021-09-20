
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

class MoveRequest with EquatableMixin {

  final EmailId emailId;
  final MailboxId currentMailboxId;
  final MailboxName currentMailboxName;
  final MailboxId destinationMailboxId;
  final MailboxName destinationMailboxName;
  final MoveAction moveAction;

  MoveRequest(
    this.emailId,
    this.currentMailboxId,
    this.currentMailboxName,
    this.destinationMailboxId,
    this.destinationMailboxName,
    this.moveAction,
  );

  @override
  List<Object?> get props => [
    emailId,
    currentMailboxId,
    currentMailboxName,
    destinationMailboxId,
    destinationMailboxName,
    moveAction
  ];
}