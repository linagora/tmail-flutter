
import 'dart:convert';

import 'package:core/domain/extensions/datetime_extension.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_value.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_header.dart';
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

  String get listPost => headers.listPost.trim();

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
    return copyWith(
      keywords: newKeywords,
      mailboxIds: newMailboxIds,
    );
  }

  PresentationEmail toPresentationEmail({
    SelectMode selectMode = SelectMode.INACTIVE,
    String? searchSnippetSubject,
    String? searchSnippetPreview,
    EmailId? emailId,
  }) {
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
    return toPresentationEmail(selectMode: selectMode, emailId: emailId);
  }

  Email updateEmailHeaderMdn(
    Map<IndividualHeaderIdentifier, String?> value,
  ) {
    return copyWith(headerMdn: value);
  }

  Email copyWith({
    EmailId? id,
    Id? blobId,
    ThreadId? threadId,
    Map<MailboxId, bool>? mailboxIds,
    Map<KeyWordIdentifier, bool>? keywords,
    UnsignedInt? size,
    UTCDate? receivedAt,
    Set<EmailHeader>? headers,
    MessageIdsHeaderValue? messageId,
    MessageIdsHeaderValue? inReplyTo,
    MessageIdsHeaderValue? references,
    String? subject,
    UTCDate? sentAt,
    bool? hasAttachment,
    String? preview,
    Set<EmailAddress>? sender,
    Set<EmailAddress>? from,
    Set<EmailAddress>? to,
    Set<EmailAddress>? cc,
    Set<EmailAddress>? bcc,
    Set<EmailAddress>? replyTo,
    Set<EmailBodyPart>? textBody,
    Set<EmailBodyPart>? htmlBody,
    Set<EmailBodyPart>? attachments,
    EmailBodyPart? bodyStructure,
    Map<PartId, EmailBodyValue>? bodyValues,
    Map<IndividualHeaderIdentifier, String?>? headerUserAgent,
    Map<IndividualHeaderIdentifier, String?>? headerMdn,
    Map<IndividualHeaderIdentifier, String?>? headerCalendarEvent,
    Map<IndividualHeaderIdentifier, String?>? sMimeStatusHeader,
    Map<IndividualHeaderIdentifier, String?>? identityHeader,
    Map<IndividualHeaderIdentifier, String?>? xPriorityHeader,
    Map<IndividualHeaderIdentifier, String?>? importanceHeader,
    Map<IndividualHeaderIdentifier, String?>? priorityHeader,
  }) {
    return Email(
      id: id ?? this.id,
      blobId: blobId ?? this.blobId,
      threadId: threadId ?? this.threadId,
      mailboxIds: mailboxIds ?? this.mailboxIds,
      keywords: keywords ?? this.keywords,
      size: size ?? this.size,
      receivedAt: receivedAt ?? this.receivedAt,
      headers: headers ?? this.headers,
      messageId: messageId ?? this.messageId,
      inReplyTo: inReplyTo ?? this.inReplyTo,
      references: references ?? this.references,
      subject: subject ?? this.subject,
      sentAt: sentAt ?? this.sentAt,
      hasAttachment: hasAttachment ?? this.hasAttachment,
      preview: preview ?? this.preview,
      sender: sender ?? this.sender,
      from: from ?? this.from,
      to: to ?? this.to,
      cc: cc ?? this.cc,
      bcc: bcc ?? this.bcc,
      replyTo: replyTo ?? this.replyTo,
      textBody: textBody ?? this.textBody,
      htmlBody: htmlBody ?? this.htmlBody,
      attachments: attachments ?? this.attachments,
      bodyStructure: bodyStructure ?? this.bodyStructure,
      bodyValues: bodyValues ?? this.bodyValues,
      headerUserAgent: headerUserAgent ?? this.headerUserAgent,
      headerMdn: headerMdn ?? this.headerMdn,
      headerCalendarEvent: headerCalendarEvent ?? this.headerCalendarEvent,
      sMimeStatusHeader: sMimeStatusHeader ?? this.sMimeStatusHeader,
      identityHeader: identityHeader ?? this.identityHeader,
      xPriorityHeader: xPriorityHeader ?? this.xPriorityHeader,
      importanceHeader: importanceHeader ?? this.importanceHeader,
      priorityHeader: priorityHeader ?? this.priorityHeader,
    );
  }
}