
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

class ComposerArguments with EquatableMixin {
  final EmailActionType emailActionType;
  final PresentationEmail? presentationEmail;
  final List<EmailContent>? emailContents;
  final EmailAddress? emailAddress;
  final List<Attachment>? attachments;
  final Session session;
  final UserProfile userProfile;
  final Map<Role, MailboxId> mapMailboxId;
  final Role? mailboxRole;

  ComposerArguments({
    this.emailActionType = EmailActionType.compose,
    this.presentationEmail,
    this.emailContents,
    this.attachments,
    this.mailboxRole,
    this.emailAddress,
    required this.session,
    required this.userProfile,
    required this.mapMailboxId,
  });

  @override
  List<Object?> get props => [
    emailActionType,
    emailContents,
    attachments,
    mailboxRole,
    emailAddress,
    session,
    userProfile,
    mapMailboxId,
  ];
}