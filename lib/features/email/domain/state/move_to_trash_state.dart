import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

class MoveToTrashSuccess extends UIState {
  final EmailId emailId;
  final MailboxId currentMailboxId;
  final MailboxId trashMailboxId;
  final MoveAction moveAction;

  MoveToTrashSuccess(
    this.emailId,
    this.currentMailboxId,
    this.trashMailboxId,
    this.moveAction
  );

  @override
  List<Object?> get props => [
    emailId,
    currentMailboxId,
    trashMailboxId,
    moveAction
  ];
}

class MoveToTrashFailure extends FeatureFailure {
  final exception;

  MoveToTrashFailure(this.exception);

  @override
  List<Object> get props => [exception];
}