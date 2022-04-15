
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';

class MoveToMailboxRequest with EquatableMixin {

  final List<EmailId> emailIds;
  final MailboxId currentMailboxId;
  final MailboxId destinationMailboxId;
  final MoveAction moveAction;
  final EmailActionType emailActionType;
  final String? destinationPath;

  MoveToMailboxRequest(
    this.emailIds,
    this.currentMailboxId,
    this.destinationMailboxId,
    this.moveAction,
    this.emailActionType,
    {this.destinationPath}
  );

  @override
  List<Object?> get props => [
    emailIds,
    currentMailboxId,
    destinationMailboxId,
    moveAction,
    emailActionType,
    destinationPath,
  ];
}