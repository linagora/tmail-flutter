import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';

class MoveMailboxLoading extends UIState {

  MoveMailboxLoading();

  @override
  List<Object?> get props => [];
}

class MoveMailboxSuccess extends UIState {

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
      this.destinationMailboxName
    }
  );

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