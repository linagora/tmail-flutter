
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_action_type.dart';

class EmailRequest with EquatableMixin {

  final Email email;
  final MailboxId? sentMailboxId;
  final EmailId? emailIdDestroyed;
  final EmailId? emailIdAnsweredOrForwarded;
  final IdentityId? identityId;
  final EmailActionType emailActionType;
  final String? storedSendingId;
  final EmailId? previousEmailId;

  EmailRequest({
    required this.email,
    required this.emailActionType,
    this.sentMailboxId,
    this.identityId,
    this.emailIdDestroyed,
    this.emailIdAnsweredOrForwarded,
    this.storedSendingId,
    this.previousEmailId,
  });

  @override
  List<Object?> get props => [
    email,
    sentMailboxId,
    identityId,
    emailIdDestroyed,
    emailIdAnsweredOrForwarded,
    emailActionType,
    storedSendingId,
    previousEmailId,
  ];

  bool get isEmailAnswered => emailIdAnsweredOrForwarded != null &&
    (emailActionType == EmailActionType.reply
      || emailActionType == EmailActionType.replyToList
      || emailActionType == EmailActionType.replyAll);

  bool get isEmailForwarded => emailIdAnsweredOrForwarded != null && emailActionType == EmailActionType.forward;
}