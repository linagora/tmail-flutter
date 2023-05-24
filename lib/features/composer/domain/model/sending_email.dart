import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_action_type.dart';

class SendingEmail with EquatableMixin {
  final String sendingId;
  final Email email;
  final MailboxId? sentMailboxId;
  final EmailId? emailIdDestroyed;
  final EmailId? emailIdAnsweredOrForwarded;
  final IdentityId? identityId;
  final EmailActionType emailActionType;
  final MailboxName? mailboxNameRequest;
  final Id? creationIdRequest;

  SendingEmail({
    required this.sendingId,
    required this.email,
    required this.emailActionType,
    this.sentMailboxId,
    this.emailIdDestroyed,
    this.emailIdAnsweredOrForwarded,
    this.identityId,
    this.mailboxNameRequest,
    this.creationIdRequest
  });

  @override
  List<Object?> get props => [
    sendingId,
    email,
    emailActionType,
    sentMailboxId,
    emailIdDestroyed,
    emailIdAnsweredOrForwarded,
    identityId,
    mailboxNameRequest,
    creationIdRequest
  ];
}