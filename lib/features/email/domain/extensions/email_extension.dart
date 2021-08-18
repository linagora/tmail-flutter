import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/email_content.dart';

extension EmailExtension on Email {

  EmailContent toEmailContent() {
    return EmailContent(
      id,
      htmlBody: htmlBody,
      attachments: attachments,
      bodyValues: bodyValues
    );
  }
}