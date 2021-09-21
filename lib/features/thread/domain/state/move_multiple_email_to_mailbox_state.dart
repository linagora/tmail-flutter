import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

class MoveMultipleEmailToMailboxAllSuccess extends UIState {
  final List<EmailId> movedListEmailId;
  final MailboxId currentMailboxId;
  final MailboxId destinationMailboxId;
  final MoveAction moveAction;
  final String? destinationPath;

  MoveMultipleEmailToMailboxAllSuccess(
    this.movedListEmailId,
    this.currentMailboxId,
    this.destinationMailboxId,
    this.moveAction,
    this.destinationPath);

  @override
  List<Object?> get props => [
    movedListEmailId,
    currentMailboxId,
    destinationMailboxId,
    moveAction,
    destinationPath];
}

class MoveMultipleEmailToMailboxAllFailure extends FeatureFailure {
  final MoveAction moveAction;

  MoveMultipleEmailToMailboxAllFailure(this.moveAction);

  @override
  List<Object> get props => [moveAction];
}

class MoveMultipleEmailToMailboxHasSomeEmailFailure extends UIState {
  final List<EmailId> movedListEmailId;
  final MailboxId currentMailboxId;
  final MailboxId destinationMailboxId;
  final MoveAction moveAction;
  final String? destinationPath;

  MoveMultipleEmailToMailboxHasSomeEmailFailure(
    this.movedListEmailId,
    this.currentMailboxId,
    this.destinationMailboxId,
    this.moveAction,
    this.destinationPath);

  @override
  List<Object?> get props => [
    movedListEmailId,
    currentMailboxId,
    destinationMailboxId,
    moveAction,
    destinationPath];
}

class MoveMultipleEmailToMailboxFailure extends FeatureFailure {
  final exception;
  final MoveAction moveAction;

  MoveMultipleEmailToMailboxFailure(this.exception, this.moveAction);

  @override
  List<Object> get props => [exception, moveAction];
}