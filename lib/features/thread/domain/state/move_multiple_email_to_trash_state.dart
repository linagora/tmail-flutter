import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

class MoveMultipleEmailToTrashAllSuccess extends UIState {
  final List<EmailId> movedListEmailId;
  final MailboxId currentMailboxId;
  final MailboxId trashMailboxId;
  final MoveAction moveAction;

  MoveMultipleEmailToTrashAllSuccess(
    this.movedListEmailId,
    this.currentMailboxId,
    this.trashMailboxId,
    this.moveAction,
  );

  @override
  List<Object?> get props => [
    movedListEmailId,
    currentMailboxId,
    trashMailboxId,
    moveAction,
  ];
}

class MoveMultipleEmailToTrashAllFailure extends FeatureFailure {
  final MoveAction moveAction;

  MoveMultipleEmailToTrashAllFailure(this.moveAction);

  @override
  List<Object> get props => [moveAction];
}

class MoveMultipleEmailToTrashHasSomeEmailFailure extends UIState {
  final List<EmailId> movedListEmailId;
  final MailboxId currentMailboxId;
  final MailboxId trashMailboxId;
  final MoveAction moveAction;

  MoveMultipleEmailToTrashHasSomeEmailFailure(
    this.movedListEmailId,
    this.currentMailboxId,
    this.trashMailboxId,
    this.moveAction,
  );

  @override
  List<Object?> get props => [
    movedListEmailId,
    currentMailboxId,
    trashMailboxId,
    moveAction,
  ];
}

class MoveMultipleEmailToTrashFailure extends FeatureFailure {
  final exception;
  final MoveAction moveAction;

  MoveMultipleEmailToTrashFailure(this.exception, this.moveAction);

  @override
  List<Object> get props => [exception, moveAction];
}