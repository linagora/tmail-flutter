
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/routes/router_arguments.dart';

class ComposerArguments extends RouterArguments {
  final EmailActionType emailActionType;
  final PresentationEmail? presentationEmail;
  final List<EmailContent>? emailContents;
  final EmailAddress? emailAddress;
  final List<Attachment>? attachments;
  final Role? mailboxRole;

  ComposerArguments({
    this.emailActionType = EmailActionType.compose,
    this.presentationEmail,
    this.emailContents,
    this.attachments,
    this.mailboxRole,
    this.emailAddress,
  });

  @override
  List<Object?> get props => [
    emailActionType,
    emailContents,
    attachments,
    mailboxRole,
    emailAddress,
  ];
}