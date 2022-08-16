import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class MoveMailboxLoading extends UIState {

  MoveMailboxLoading();

  @override
  List<Object?> get props => [];
}

class MoveMailboxSuccess extends UIActionState {

  final MailboxId mailboxIdSelected;
  final MoveAction moveAction;
  final MailboxId? parentId;
  final MailboxId? destinationMailboxId;
  final MailboxName? destinationMailboxName;

  MoveMailboxSuccess(
    this.mailboxIdSelected,
    this.moveAction,
    {
      this.parentId,
      this.destinationMailboxId,
      this.destinationMailboxName,
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [
    mailboxIdSelected,
    parentId,
    destinationMailboxId];
}

class MoveMailboxFailure extends FeatureFailure {
  final dynamic exception;

  MoveMailboxFailure(this.exception);

  @override
  List<Object> get props => [exception];
}