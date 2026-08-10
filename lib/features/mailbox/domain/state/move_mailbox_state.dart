import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';

class LoadingMoveMailbox extends UIState {}

class MoveMailboxSuccess extends UIState {

  final MailboxId mailboxIdSelected;
  final MoveAction moveAction;
  /// The account the move ran against, carried so the undo routes back to the
  /// same account. JMAP ids collide across accounts, so it cannot be recovered
  /// from the mailbox id alone.
  final AccountId accountId;
  final MailboxId? parentId;
  final MailboxId? destinationMailboxId;
  final String? destinationMailboxDisplayName;

  MoveMailboxSuccess(
    this.mailboxIdSelected,
    this.moveAction,
    this.accountId,
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
    accountId,
    parentId,
    destinationMailboxId,
    destinationMailboxDisplayName,
  ];
}

class MoveMailboxFailure extends FeatureFailure {

  MoveMailboxFailure(dynamic exception) : super(exception: exception);
}