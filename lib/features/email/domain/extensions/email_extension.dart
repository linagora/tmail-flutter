
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';

extension EmailExtension on Email {
  DetailedEmail toDetailedEmail({String? htmlEmailContent}) {
    return DetailedEmail(
      emailId: id!,
      attachments: allAttachments,
      headers: header,
      htmlEmailContent: htmlEmailContent
    );
  }
}