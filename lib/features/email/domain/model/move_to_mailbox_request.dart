
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';

class MoveToMailboxRequest with EquatableMixin {

  final Map<MailboxId,List<EmailId>> currentMailboxes;
  final MailboxId destinationMailboxId;
  final MoveAction moveAction;
  final EmailActionType emailActionType;
  final String? destinationPath;
  final Session session;

  MoveToMailboxRequest(
    this.currentMailboxes,
    this.destinationMailboxId,
    this.moveAction,
    this.session,
    this.emailActionType,{
    this.destinationPath,
  });

  @override
  List<Object?> get props => [
    currentMailboxes,
    destinationMailboxId,
    moveAction,
    emailActionType,
    destinationPath,
  ];
}