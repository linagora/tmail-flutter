import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';

class MoveToMailboxSuccess extends UIState {
  final EmailId emailId;
  final MailboxId currentMailboxId;
  final MailboxId destinationMailboxId;
  final MoveAction moveAction;
  final EmailActionType emailActionType;
  final String? destinationPath;

  MoveToMailboxSuccess(
    this.emailId,
    this.currentMailboxId,
    this.destinationMailboxId,
    this.moveAction,
    this.emailActionType,
    {this.destinationPath}
  );

  @override
  List<Object?> get props => [
    emailId,
    currentMailboxId,
    destinationMailboxId,
    moveAction,
    emailActionType,
    destinationPath
  ];
}

class MoveToMailboxFailure extends FeatureFailure {
  final EmailActionType emailActionType;
  final exception;

  MoveToMailboxFailure(this.emailActionType, this.exception);

  @override
  List<Object> get props => [emailActionType, exception];
}