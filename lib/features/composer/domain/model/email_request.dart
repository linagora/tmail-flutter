
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
  final Identity? identity;
  final EmailActionType? emailActionType;

  EmailRequest(
    this.email, {
    this.sentMailboxId,
    this.identity,
    this.emailIdDestroyed,
    this.emailIdAnsweredOrForwarded,
    this.emailActionType
  });

  @override
  List<Object?> get props => [
    email,
    sentMailboxId,
    identity,
    emailIdDestroyed,
    emailIdAnsweredOrForwarded,
    emailActionType
  ];

  bool get isEmailAnswered => emailIdAnsweredOrForwarded != null &&
    (emailActionType == EmailActionType.reply || emailActionType == EmailActionType.replyAll);

  bool get isEmailForwarded => emailIdAnsweredOrForwarded != null && emailActionType == EmailActionType.forward;
}