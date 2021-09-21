
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/model.dart';

extension EmailExtension on Email {

  bool isUnReadEmail() => !(keywords?.containsKey(KeyWordIdentifier.emailSeen) == true);

  bool isReadEmail() => keywords?.containsKey(KeyWordIdentifier.emailSeen) == true;

  bool isFlaggedEmail() => keywords?.containsKey(KeyWordIdentifier.emailFlagged) == true;

  Set<String> getRecipientEmailAddressList() {
    final listEmailAddress = Set<String>();
    final listToAddress = to.getListAddress() ?? [];
    final listCcAddress = cc.getListAddress() ?? [];
    final listBccAddress = bcc.getListAddress() ?? [];
    listEmailAddress.addAll(listToAddress + listCcAddress + listBccAddress);
    return listEmailAddress;
  }

  EmailContent toEmailContent() {
    return EmailContent(
      id,
      htmlBody: htmlBody,
      attachments: attachments,
      bodyValues: bodyValues
    );
  }

  Email updatedEmail({Map<KeyWordIdentifier, bool>? newKeywords}) {
    return Email(
        id,
        keywords: newKeywords ?? keywords,
        size: size,
        receivedAt: receivedAt,
        hasAttachment: hasAttachment,
        preview: preview,
        subject: subject,
        sentAt: sentAt,
        from: from,
        to: to,
        cc: cc,
        bcc: bcc,
        replyTo: replyTo
    );
  }

  PresentationEmail toPresentationEmail({SelectMode selectMode = SelectMode.INACTIVE}) {
    return PresentationEmail(
      id,
      keywords: keywords,
      size: size,
      receivedAt: receivedAt,
      hasAttachment: hasAttachment,
      preview: preview,
      subject: subject,
      sentAt: sentAt,
      from: from,
      to: to,
      cc: cc,
      bcc: bcc,
      replyTo: replyTo,
      selectMode: selectMode
    );
  }
}