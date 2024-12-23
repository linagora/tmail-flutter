import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';

class LoadingMoveMultipleEmailToMailboxAll extends UIState {}

class MoveMultipleEmailToMailboxAllSuccess extends UIState {
  final List<EmailId> movedListEmailId;
  final MailboxId currentMailboxId;
  final MailboxId destinationMailboxId;
  final MoveAction moveAction;
  final EmailActionType emailActionType;
  final String? destinationPath;

  MoveMultipleEmailToMailboxAllSuccess(
    this.movedListEmailId,
    this.currentMailboxId,
    this.destinationMailboxId,
    this.moveAction,
    this.emailActionType,
    {
      this.destinationPath,
    }
  );

  @override
  List<Object?> get props => [
    movedListEmailId,
    currentMailboxId,
    destinationMailboxId,
    moveAction,
    emailActionType,
    destinationPath,
  ];
}

class MoveMultipleEmailToMailboxAllFailure extends FeatureFailure {
  final MoveAction moveAction;
  final EmailActionType emailActionType;

  MoveMultipleEmailToMailboxAllFailure(this.moveAction, this.emailActionType);

  @override
  List<Object> get props => [moveAction, emailActionType];
}

class MoveMultipleEmailToMailboxHasSomeEmailFailure extends UIState {
  final List<EmailId> movedListEmailId;
  final MailboxId currentMailboxId;
  final MailboxId destinationMailboxId;
  final MoveAction moveAction;
  final EmailActionType emailActionType;
  final String? destinationPath;

  MoveMultipleEmailToMailboxHasSomeEmailFailure(
    this.movedListEmailId,
    this.currentMailboxId,
    this.destinationMailboxId,
    this.moveAction,
    this.emailActionType,
    {
      this.destinationPath,
    }
  );

  @override
  List<Object?> get props => [
    movedListEmailId,
    currentMailboxId,
    destinationMailboxId,
    moveAction,
    emailActionType,
    destinationPath,
  ];
}

class MoveMultipleEmailToMailboxFailure extends FeatureFailure {
  final MoveAction moveAction;
  final EmailActionType emailActionType;

  MoveMultipleEmailToMailboxFailure(this.emailActionType, this.moveAction, dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [emailActionType, moveAction, exception];
}