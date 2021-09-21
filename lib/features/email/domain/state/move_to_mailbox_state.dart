import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

class MoveToMailboxSuccess extends UIState {
  final EmailId emailId;
  final MailboxId currentMailboxId;
  final MailboxId destinationMailboxId;
  final MoveAction moveAction;
  final String? destinationPath;

  MoveToMailboxSuccess(
    this.emailId,
    this.currentMailboxId,
    this.destinationMailboxId,
    this.moveAction,
    this.destinationPath);

  @override
  List<Object?> get props => [
    emailId,
    currentMailboxId,
    destinationMailboxId,
    moveAction,
    destinationPath];
}

class MoveToMailboxFailure extends FeatureFailure {
  final exception;

  MoveToMailboxFailure(this.exception);

  @override
  List<Object> get props => [exception];
}