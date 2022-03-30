
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

class MoveToTrashRequest with EquatableMixin {

  final List<EmailId> emailIds;
  final MailboxId currentMailboxId;
  final MailboxId trashMailboxId;
  final MoveAction moveAction;

  MoveToTrashRequest(
    this.emailIds,
    this.currentMailboxId,
    this.trashMailboxId,
    this.moveAction,
  );

  @override
  List<Object?> get props => [
    emailIds,
    currentMailboxId,
    trashMailboxId,
    moveAction,
  ];
}