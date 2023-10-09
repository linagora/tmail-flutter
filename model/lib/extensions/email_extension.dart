
import 'dart:convert';

import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

extension EmailExtension on Email {

  String asString() => jsonEncode(toJson());

  bool get hasRead => keywords?.containsKey(KeyWordIdentifier.emailSeen) == true;

  bool get hasStarred => keywords?.containsKey(KeyWordIdentifier.emailFlagged) == true;

  bool get hasMdnSent => keywords?.containsKey(KeyWordIdentifier.mdnSent) == true;

  bool get isDraft => keywords?.containsKey(KeyWordIdentifier.emailDraft) == true;

  bool get withAttachments => hasAttachment == true;

  bool hasReadReceipt(Map<MailboxId, PresentationMailbox> mapMailbox) {
    final mailboxCurrent = findMailboxContain(mapMailbox);
    return !hasMdnSent &&
        headers.readReceiptHasBeenRequested &&
        mailboxCurrent?.isSent == false;
  }

  Set<String> getRecipientEmailAddressList() {
    final listEmailAddress = <String>{};
    final listToAddress = to.getListAddress() ?? [];
    final listCcAddress = cc.getListAddress() ?? [];
    final listBccAddress = bcc.getListAddress() ?? [];
    listEmailAddress.addAll(listToAddress + listCcAddress + listBccAddress);
    return listEmailAddress;
  }

  Email updatedEmail({Map<KeyWordIdentifier, bool>? newKeywords, Map<MailboxId, bool>? newMailboxIds}) {
    return Email(
      id: id,
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
      replyTo: replyTo,
      mailboxIds: newMailboxIds ?? mailboxIds,
      htmlBody: htmlBody,
      bodyValues: bodyValues,
      headerUserAgent: headerUserAgent,
      attachments: attachments,
      headerCalendarEvent: headerCalendarEvent
    );
  }

  PresentationEmail toPresentationEmail({SelectMode selectMode = SelectMode.INACTIVE}) {
    return PresentationEmail(
      id: id,
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
      emailHeader: headers?.toList(),
      headerCalendarEvent: headerCalendarEvent
    );
  }

  Email combineEmail(Email newEmail, Properties updatedProperties) {
    return Email(
      id: newEmail.id,
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
      headerCalendarEvent: updatedProperties.contain(IndividualHeaderIdentifier.headerCalendarEvent.value) ? newEmail.headerCalendarEvent : headerCalendarEvent,
    );
  }

  List<EmailContent> get emailContentList {
    final newHtmlBody = htmlBody
      ?.where((emailBody) => emailBody.partId != null && emailBody.type != null)
      .toList() ?? <EmailBodyPart>[];

    final mapHtmlBody = { for (var emailBody in newHtmlBody) emailBody.partId! : emailBody.type! };

    final emailContents = bodyValues?.entries
      .map((entries) => EmailContent(mapHtmlBody[entries.key].toEmailContentType(), entries.value.value))
      .toList();

    return emailContents ?? [];
  }

  List<Attachment> get allAttachments => attachments?.map((item) => item.toAttachment()).toList() ?? [];

  List<Attachment> get attachmentsWithCid => allAttachments.where((attachment) => attachment.hasCid()).toList();

  PresentationMailbox? findMailboxContain(Map<MailboxId, PresentationMailbox> mapMailbox) {
    final newMailboxIds = mailboxIds;
    newMailboxIds?.removeWhere((key, value) => !value);

    if (newMailboxIds?.isNotEmpty == true) {
      final firstMailboxId = newMailboxIds!.keys.first;
      if (mapMailbox.containsKey(firstMailboxId)) {
        return mapMailbox[firstMailboxId];
      }
    }
    return null;
  }

  PresentationEmail sendingEmailToPresentationEmail(
    {
      SelectMode selectMode = SelectMode.INACTIVE,
      EmailId? emailId,
    }
  ) {
    return PresentationEmail(
      id: emailId ?? id,
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
      emailHeader: headers?.toList(),
      bodyValues: bodyValues,
      htmlBody: htmlBody,
      headerCalendarEvent: headerCalendarEvent
    );
  }
}