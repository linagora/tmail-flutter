import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';

class MoveToMailboxSuccess extends UIActionState {
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
    {
      this.destinationPath,
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentEmailState, currentMailboxState);

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
  final dynamic exception;

  MoveToMailboxFailure(this.emailActionType, this.exception);

  @override
  List<Object> get props => [emailActionType, exception];
}