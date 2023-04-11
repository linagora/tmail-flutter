
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_action_type.dart';

class EmailRequest with EquatableMixin {

  final Email email;
  final Id submissionCreateId;
  final MailboxId? sentMailboxId;
  final EmailId? emailIdDestroyed;
  final Identity? identity;
  final EmailActionType? emailActionType;

  EmailRequest(this.email, this.submissionCreateId, {
    this.sentMailboxId,
    this.identity,
    this.emailIdDestroyed,
    this.emailActionType
  });

  @override
  List<Object?> get props => [
    email,
    submissionCreateId,
    sentMailboxId,
    identity,
    emailIdDestroyed,
    emailActionType
  ];

  bool get isEmailAnswered => emailActionType == EmailActionType.reply;

  bool get isEmailForwarded => emailActionType == EmailActionType.forward;
}