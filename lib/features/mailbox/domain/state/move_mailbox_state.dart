import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';

class LoadingMoveMailbox extends UIState {}

class MoveMailboxSuccess extends UIState {

  final MailboxId mailboxIdSelected;
  final MoveAction moveAction;
  final MailboxId? parentId;
  final MailboxId? destinationMailboxId;
  final String? destinationMailboxDisplayName;

  MoveMailboxSuccess(
    this.mailboxIdSelected,
    this.moveAction,
    {
      this.parentId,
      this.destinationMailboxId,
      this.destinationMailboxDisplayName,
    }
  );

  @override
  List<Object?> get props => [
    mailboxIdSelected,
    moveAction,
    parentId,
    destinationMailboxId,
    destinationMailboxDisplayName,
  ];
}

class MoveMailboxFailure extends FeatureFailure {

  MoveMailboxFailure(dynamic exception) : super(exception: exception);
}