import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';

class MoveFolderContentRequest with EquatableMixin {
  final MailboxId mailboxId;
  final MoveAction moveAction;
  final MailboxId destinationMailboxId;
  final String destinationMailboxDisplayName;
  final int totalEmails;
  final bool markAsRead;

  MoveFolderContentRequest({
    required this.mailboxId,
    required this.moveAction,
    required this.destinationMailboxId,
    required this.destinationMailboxDisplayName,
    this.totalEmails = 0,
    this.markAsRead = false,
  });

  @override
  List<Object?> get props => [
        mailboxId,
        moveAction,
        destinationMailboxId,
        destinationMailboxDisplayName,
        totalEmails,
        markAsRead,
      ];
}
