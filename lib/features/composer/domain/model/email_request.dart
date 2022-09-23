
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class EmailRequest with EquatableMixin {

  final Email email;
  final Id submissionCreateId;
  final MailboxId? sentMailboxId;
  final EmailId? emailIdDestroyed;
  final Identity? identity;

  EmailRequest(this.email, this.submissionCreateId, {
    this.sentMailboxId,
    this.identity,
    this.emailIdDestroyed
  });

  @override
  List<Object?> get props => [
    email,
    submissionCreateId,
    sentMailboxId,
    identity,
    emailIdDestroyed
  ];
}

extension EmailRequestExtension on EmailRequest {

  EmailRequest toEmailRequest({Email? newEmail}) {
    return EmailRequest(
      newEmail ?? email,
      submissionCreateId,
      sentMailboxId: sentMailboxId,
      identity: identity,
      emailIdDestroyed: emailIdDestroyed
    );
  }
}