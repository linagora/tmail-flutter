import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/email_content.dart';
import 'package:model/email/presentation_email.dart';

class Composer {
  final EmailActionType emailActionType;
  final PresentationEmail? presentationEmail;
  final List<EmailContent>? emailContents;
  final EmailAddress? emailAddress;
  final List<Attachment>? attachments;
  final Role? mailboxRole;

  Composer({
    this.emailActionType = EmailActionType.compose,
    this.presentationEmail,
    this.emailContents,
    this.attachments,
    this.mailboxRole,
    this.emailAddress,
  });
}
