
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';

class MoveMailboxRequest with EquatableMixin {

  final MailboxId? destinationMailboxId;
  final String? destinationMailboxDisplayName;
  final MailboxId? parentId;
  final MailboxId mailboxId;
  final MoveAction moveAction;

  MoveMailboxRequest(
    this.mailboxId,
    this.moveAction,
    {
      this.parentId,
      this.destinationMailboxId,
      this.destinationMailboxDisplayName
    }
  );

  @override
  List<Object?> get props => [
    mailboxId,
    moveAction,
    parentId,
    destinationMailboxId,
    destinationMailboxDisplayName
  ];
}