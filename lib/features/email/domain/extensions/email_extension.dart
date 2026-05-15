
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/email_attachment_classifier_extension.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';

extension EmailExtension on Email {
  DetailedEmail toDetailedEmail({String? htmlEmailContent}) {
    final classified = toPresentationAttachments();
    return DetailedEmail(
      emailId: id!,
      createdTime: receivedAt?.value ?? DateTime.now(),
      attachments: classified.attachments,
      headers: headers,
      keywords: keywords,
      htmlEmailContent: htmlEmailContent,
      messageId: messageId,
      references: references,
      inlineImages: classified.inlineImages,
      sMimeStatusHeader: sMimeStatusHeader,
      identityHeader: identityHeader,
    );
  }
}