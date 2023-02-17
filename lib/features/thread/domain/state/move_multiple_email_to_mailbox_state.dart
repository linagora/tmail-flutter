import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';

class LoadingMoveMultipleEmailToMailboxAll extends UIState {}

class MoveMultipleEmailToMailboxAllSuccess extends UIActionState {
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
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [
    movedListEmailId,
    currentMailboxId,
    destinationMailboxId,
    moveAction,
    emailActionType,
    destinationPath
  ];
}

class MoveMultipleEmailToMailboxAllFailure extends FeatureFailure {
  final MoveAction moveAction;
  final EmailActionType emailActionType;

  MoveMultipleEmailToMailboxAllFailure(this.moveAction, this.emailActionType);

  @override
  List<Object> get props => [moveAction, emailActionType];
}

class MoveMultipleEmailToMailboxHasSomeEmailFailure extends UIActionState {
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
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [
    movedListEmailId,
    currentMailboxId,
    destinationMailboxId,
    moveAction,
    emailActionType,
    destinationPath
  ];
}

class MoveMultipleEmailToMailboxFailure extends FeatureFailure {
  final dynamic exception;
  final MoveAction moveAction;
  final EmailActionType emailActionType;

  MoveMultipleEmailToMailboxFailure(this.exception, this.emailActionType, this.moveAction);

  @override
  List<Object?> get props => [exception, emailActionType, moveAction];
}