
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/model.dart';

extension EmailExtension on Email {

  bool get hasRead => keywords?.containsKey(KeyWordIdentifier.emailSeen) == true;

  bool get hasStarred => keywords?.containsKey(KeyWordIdentifier.emailFlagged) == true;

  bool get withAttachments => hasAttachment == true;

  Set<String> getRecipientEmailAddressList() {
    final listEmailAddress = Set<String>();
    final listToAddress = to.getListAddress() ?? [];
    final listCcAddress = cc.getListAddress() ?? [];
    final listBccAddress = bcc.getListAddress() ?? [];
    listEmailAddress.addAll(listToAddress + listCcAddress + listBccAddress);
    return listEmailAddress;
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
      mailboxIds: mailboxIds,
      selectMode: selectMode,
    );
  }

  Email combineEmail(Email newEmail, Properties updatedProperties) {
    return Email(
      newEmail.id,
      keywords: updatedProperties.contain(EmailProperty.keywords) ? newEmail.keywords : keywords,
      size: updatedProperties.contain(EmailProperty.size) ? newEmail.size : size,
      receivedAt: updatedProperties.contain(EmailProperty.receivedAt) ? newEmail.receivedAt : receivedAt,
      hasAttachment: updatedProperties.contain(EmailProperty.hasAttachment) ? newEmail.hasAttachment : hasAttachment,
      preview: updatedProperties.contain(EmailProperty.preview) ? newEmail.preview : preview,
      subject: updatedProperties.contain(EmailProperty.subject) ? newEmail.subject : subject,
      sentAt: updatedProperties.contain(EmailProperty.sentAt) ? newEmail.sentAt : sentAt,
      from: updatedProperties.contain(EmailProperty.from) ? newEmail.from : from,
      to: updatedProperties.contain(EmailProperty.to) ? newEmail.to : to,
      cc: updatedProperties.contain(EmailProperty.cc) ? newEmail.cc : cc,
      bcc: updatedProperties.contain(EmailProperty.bcc) ? newEmail.bcc : bcc,
      replyTo: updatedProperties.contain(EmailProperty.replyTo) ? newEmail.replyTo : replyTo,
      mailboxIds: updatedProperties.contain(EmailProperty.mailboxIds) ? newEmail.mailboxIds : mailboxIds,
    );
  }

  List<EmailContent> get emailContentList {
    final newHtmlBody = htmlBody
      ?.where((emailBody) => emailBody.partId != null && emailBody.type != null)
      .toList() ?? <EmailBodyPart>[];

    final mapHtmlBody = Map<PartId, MediaType>.fromIterable(
      newHtmlBody,
      key: (emailBody) => emailBody.partId!,
      value: (emailBody) => emailBody.type!,
    );

    final emailContents = bodyValues?.entries
      .map((entries) => EmailContent(mapHtmlBody[entries.key].toEmailContentType(), entries.value.value))
      .toList();

    return emailContents ?? [];
  }

  List<Attachment> get allAttachments {
    if (attachments != null) {
      return attachments!
        .where((element) => element.disposition != null)
        .map((item) => item.toAttachment())
        .toList();
    }
    return [];
  }
}