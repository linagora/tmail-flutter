
import 'dart:convert';

import 'package:core/domain/extensions/datetime_extension.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
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

  bool get isUnsubscribed => keywords?.containsKey(KeyWordIdentifierExtension.unsubscribeMail) == true;

  bool get withAttachments => hasAttachment == true;

  String get listUnsubscribe => headers.listUnsubscribe;

  bool get hasRequestReadReceipt => headers.readReceiptHasBeenRequested;

  bool get hasListUnsubscribe => listUnsubscribe.isNotEmpty;

  String get sMimeStatusHeaderParsed => sMimeStatusHeader?[IndividualHeaderIdentifier.sMimeStatusHeader]?.trim() ?? '';

  String get listPost => headers.listPost;

  bool get hasListPost => listPost.isNotEmpty;

  IdentityId? get identityIdFromHeader {
    final rawIdentityId = identityHeader?[IndividualHeaderIdentifier.identityHeader];
    if (rawIdentityId == null) return null;

    return IdentityId(Id(rawIdentityId));
  }

  bool hasReadReceipt(Map<MailboxId, PresentationMailbox> mapMailbox) {
    final mailboxCurrent = findMailboxContain(mapMailbox);
    return !hasMdnSent &&
        headers.readReceiptHasBeenRequested &&
        mailboxCurrent?.isSent == false;
  }

  String getReceivedAt({required String newLocale, String? pattern}) {
    if (receivedAt != null) {
      return receivedAt!.formatDateToLocal(
        pattern: pattern ?? receivedAt!.value.toLocal().toPattern(),
        locale: newLocale
      );
    }
    return '';
  }

  String getSentAt({required String newLocale, String? pattern}) {
    if (sentAt != null) {
      return sentAt!.formatDateToLocal(
        pattern: pattern ?? sentAt!.value.toLocal().toPattern(),
        locale: newLocale
      );
    }
    return '';
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
      blobId: blobId,
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
      headerCalendarEvent: headerCalendarEvent,
      xPriorityHeader: xPriorityHeader,
      importanceHeader: importanceHeader,
      priorityHeader: priorityHeader,
    );
  }

  PresentationEmail toPresentationEmail({
    SelectMode selectMode = SelectMode.INACTIVE,
    String? searchSnippetSubject,
    String? searchSnippetPreview,
  }) {
    return PresentationEmail(
      id: id,
      blobId: blobId,
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
      headerCalendarEvent: headerCalendarEvent,
      xPriorityHeader: xPriorityHeader,
      importanceHeader: importanceHeader,
      priorityHeader: priorityHeader,
    )
      ..searchSnippetSubject = searchSnippetSubject
      ..searchSnippetPreview = searchSnippetPreview;
  }

  Email combineEmail(Email newEmail, Properties updatedProperties) {
    return Email(
      id: newEmail.id,
      blobId: updatedProperties.contain(EmailProperty.blobId) ? newEmail.blobId : blobId,
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
      xPriorityHeader: updatedProperties.contain(IndividualHeaderIdentifier.xPriorityHeader.value)
        ? newEmail.xPriorityHeader
        : xPriorityHeader,
      importanceHeader: updatedProperties.contain(IndividualHeaderIdentifier.importanceHeader.value)
        ? newEmail.importanceHeader
        : importanceHeader,
      priorityHeader: updatedProperties.contain(IndividualHeaderIdentifier.priorityHeader.value)
        ? newEmail.priorityHeader
        : priorityHeader,
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

  List<Attachment> get htmlBodyAttachments => htmlBody?.map((item) => item.toAttachment()).toList() ?? [];

  List<Attachment> get allAttachments => attachments?.map((item) => item.toAttachment()).toList() ?? [];

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
      blobId: blobId,
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
      headerCalendarEvent: headerCalendarEvent,
      xPriorityHeader: xPriorityHeader,
      importanceHeader: importanceHeader,
      priorityHeader: priorityHeader,
    );
  }

  Email updateEmailHeaderMdn(
    Map<IndividualHeaderIdentifier, String?> value,
  ) {
    return Email(
      id: id,
      blobId: blobId,
      threadId: threadId,
      mailboxIds: mailboxIds,
      keywords: keywords,
      size: size,
      receivedAt: receivedAt,
      headers: headers,
      messageId: messageId,
      inReplyTo: inReplyTo,
      references: references,
      subject: subject,
      sentAt: sentAt,
      hasAttachment: hasAttachment,
      preview: preview,
      sender: sender,
      from: from,
      to: to,
      cc: cc,
      bcc: bcc,
      replyTo: replyTo,
      textBody: textBody,
      htmlBody: htmlBody,
      attachments: attachments,
      bodyStructure: bodyStructure,
      bodyValues: bodyValues,
      headerUserAgent: headerUserAgent,
      headerMdn: value,
      headerCalendarEvent: headerCalendarEvent,
      xPriorityHeader: xPriorityHeader,
      importanceHeader: importanceHeader,
      priorityHeader: priorityHeader,
    );
  }
}