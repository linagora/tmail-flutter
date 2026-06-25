// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:core/presentation/extensions/string_extension.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_value.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_header.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_header_value.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_content.dart';
import 'package:model/email/email_in_thread_status.dart';
import 'package:model/email/mail_priority_header.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/extensions/keyword_identifier_extension.dart';
import 'package:model/extensions/list_email_header_extension.dart';
import 'package:model/extensions/media_type_nullable_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:model/mixin/search_snippet_mixin.dart';

class PresentationEmail with EquatableMixin, SearchSnippetMixin {

  final EmailId? id;
  final Id? blobId;
  final Map<KeyWordIdentifier, bool>? keywords;
  final UnsignedInt? size;
  final UTCDate? receivedAt;
  final bool? hasAttachment;
  final String? preview;
  final String? subject;
  final UTCDate? sentAt;
  final Set<EmailAddress>? from;
  final Set<EmailAddress>? to;
  final Set<EmailAddress>? cc;
  final Set<EmailAddress>? bcc;
  final Set<EmailAddress>? replyTo;
  final Map<MailboxId, bool>? mailboxIds;
  final ThreadId? threadId;
  final SelectMode selectMode;
  final Uri? routeWeb;
  final PresentationMailbox? mailboxContain;
  final List<EmailHeader>? emailHeader;
  final Set<EmailBodyPart>? htmlBody;
  final Map<PartId, EmailBodyValue>? bodyValues;
  final TextHeaderValue? headerCalendarEvent;
  final TextHeaderValue? xPriorityHeader;
  final TextHeaderValue? importanceHeader;
  final TextHeaderValue? priorityHeader;
  final TextHeaderValue? listPostHeader;
  final TextHeaderValue? listUnsubscribeHeader;
  final EmailInThreadStatus? emailInThreadStatus;
  final MessageIdsHeaderValue? messageId;
  final MessageIdsHeaderValue? references;

  PresentationEmail({
    this.id,
    this.blobId,
    this.keywords,
    this.size,
    this.receivedAt,
    this.hasAttachment,
    this.preview,
    this.subject,
    this.sentAt,
    this.from,
    this.to,
    this.cc,
    this.bcc,
    this.replyTo,
    this.mailboxIds,
    this.threadId,
    this.selectMode = SelectMode.INACTIVE,
    this.routeWeb,
    this.mailboxContain,
    this.emailHeader,
    this.htmlBody,
    this.bodyValues,
    this.headerCalendarEvent,
    this.xPriorityHeader,
    this.importanceHeader,
    this.priorityHeader,
    this.listPostHeader,
    this.listUnsubscribeHeader,
    this.emailInThreadStatus,
    this.messageId,
    this.references,
  });

  String getSenderName() {
    if (from?.isNotEmpty == true) {
      return from?.first.asString() ?? '';
    } else {
      return '';
    }
  }

  String get firstEmailAddressInFrom {
    if (from?.isNotEmpty == true) {
      return from!.first.emailAddress;
    } else {
      return '';
    }
  }

  EmailAddress? get firstFromAddress {
    if (from?.isNotEmpty == true) {
      return from!.first;
    } else {
      return null;
    }
  }

  String getAvatarText() {
    if (getSenderName().isNotEmpty) {
      return getSenderName().firstCharacterToUpperCase;
    }
    return '';
  }

  String getEmailTitle() => subject?.trim() ?? '';

  String getPartialContent() => preview?.trim() ?? '';

  bool get hasRead => keywords?.containsKey(KeyWordIdentifier.emailSeen) == true;

  bool get hasStarred => keywords?.containsKey(KeyWordIdentifier.emailFlagged) == true;

  bool get isDraft => keywords?.containsKey(KeyWordIdentifier.emailDraft) == true;

  bool get isAnswered => keywords?.containsKey(KeyWordIdentifier.emailAnswered) == true;

  bool get isForwarded => keywords?.containsKey(KeyWordIdentifier.emailForwarded) == true;

  bool get isSubscribed => keywords?.containsKey(KeyWordIdentifierExtension.unsubscribeMail) == true;

  bool get hasNeedAction =>
      keywords?.containsKey(KeyWordIdentifierExtension.needsActionMail) == true;

  bool get isAnsweredAndForwarded => isAnswered && isForwarded;

  bool get withAttachments => hasAttachment == true;

  bool get isSelected => selectMode == SelectMode.ACTIVE;

  String get routeWebAsString => routeWeb.toString();

  bool get pushNotificationActivated => !isDraft && !hasRead;

  bool get hasCalendarEvent => headerCalendarEvent?.value?.isNotEmpty == true;

  String? get listPost => emailHeader?.toSet().listPost?.trim()
    ?? listPostHeader?.value?.trim();

  String? get listUnsubscribe => emailHeader?.toSet().listUnsubscribe?.trim()
    ?? listUnsubscribeHeader?.value?.trim();

  bool get isMarkAsImportant {
    final xPriority = xPriorityHeader?.value?.trim().toLowerCase();
    final importance = importanceHeader?.value?.trim().toLowerCase();
    final priority = priorityHeader?.value?.trim().toLowerCase();

    return xPriority?.startsWith(MailPriorityHeader.firstXPriority) == true ||
      importance == MailPriorityHeader.highImportance ||
      priority == MailPriorityHeader.urgentPriority;
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

  @override
  List<Object?> get props => [
    id,
    blobId,
    keywords,
    size,
    receivedAt,
    hasAttachment,
    preview,
    subject,
    sentAt,
    from,
    to,
    cc,
    bcc,
    replyTo,
    mailboxIds,
    threadId,
    selectMode,
    routeWeb,
    mailboxContain,
    emailHeader,
    htmlBody,
    bodyValues,
    headerCalendarEvent,
    searchSnippetSubject,
    searchSnippetPreview,
    xPriorityHeader,
    importanceHeader,
    priorityHeader,
    listPostHeader,
    listUnsubscribeHeader,
    emailInThreadStatus,
    messageId,
    references,
  ];

  PresentationEmail copyWith({
    EmailId? id,
    Id? blobId,
    Map<KeyWordIdentifier, bool>? keywords,
    UnsignedInt? size,
    UTCDate? receivedAt,
    bool? hasAttachment,
    String? preview,
    String? subject,
    UTCDate? sentAt,
    Set<EmailAddress>? from,
    Set<EmailAddress>? to,
    Set<EmailAddress>? cc,
    Set<EmailAddress>? bcc,
    Set<EmailAddress>? replyTo,
    Map<MailboxId, bool>? mailboxIds,
    ThreadId? threadId,
    SelectMode? selectMode,
    Uri? routeWeb,
    PresentationMailbox? mailboxContain,
    List<EmailHeader>? emailHeader,
    Set<EmailBodyPart>? htmlBody,
    Map<PartId, EmailBodyValue>? bodyValues,
    TextHeaderValue? headerCalendarEvent,
    TextHeaderValue? xPriorityHeader,
    TextHeaderValue? importanceHeader,
    TextHeaderValue? priorityHeader,
    TextHeaderValue? listPostHeader,
    TextHeaderValue? listUnsubscribeHeader,
    EmailInThreadStatus? emailInThreadStatus,
    MessageIdsHeaderValue? messageId,
    MessageIdsHeaderValue? references,
  }) {
    return PresentationEmail(
      id: id ?? this.id,
      blobId: blobId ?? this.blobId,
      keywords: keywords ?? this.keywords,
      size: size ?? this.size,
      receivedAt: receivedAt ?? this.receivedAt,
      hasAttachment: hasAttachment ?? this.hasAttachment,
      preview: preview ?? this.preview,
      subject: subject ?? this.subject,
      sentAt: sentAt ?? this.sentAt,
      from: from ?? this.from,
      to: to ?? this.to,
      cc: cc ?? this.cc,
      bcc: bcc ?? this.bcc,
      replyTo: replyTo ?? this.replyTo,
      mailboxIds: mailboxIds ?? this.mailboxIds,
      threadId: threadId ?? this.threadId,
      selectMode: selectMode ?? this.selectMode,
      routeWeb: routeWeb ?? this.routeWeb,
      mailboxContain: mailboxContain ?? this.mailboxContain,
      emailHeader: emailHeader ?? this.emailHeader,
      htmlBody: htmlBody ?? this.htmlBody,
      bodyValues: bodyValues ?? this.bodyValues,
      headerCalendarEvent: headerCalendarEvent ?? this.headerCalendarEvent,
      xPriorityHeader: xPriorityHeader ?? this.xPriorityHeader,
      importanceHeader: importanceHeader ?? this.importanceHeader,
      priorityHeader: priorityHeader ?? this.priorityHeader,
      listPostHeader: listPostHeader ?? this.listPostHeader,
      listUnsubscribeHeader: listUnsubscribeHeader ?? this.listUnsubscribeHeader,
      emailInThreadStatus: emailInThreadStatus ?? this.emailInThreadStatus,
      messageId: messageId ?? this.messageId,
      references: references ?? this.references,
    );
  }

  PresentationEmail nullableCopyWith({
    Option<EmailId?>? id,
    Option<Id?>? blobId,
    Option<Map<KeyWordIdentifier, bool>?>? keywords,
    Option<UnsignedInt?>? size,
    Option<UTCDate?>? receivedAt,
    Option<bool?>? hasAttachment,
    Option<String?>? preview,
    Option<String?>? subject,
    Option<UTCDate?>? sentAt,
    Option<Set<EmailAddress>?>? from,
    Option<Set<EmailAddress>?>? to,
    Option<Set<EmailAddress>?>? cc,
    Option<Set<EmailAddress>?>? bcc,
    Option<Set<EmailAddress>?>? replyTo,
    Option<Map<MailboxId, bool>?>? mailboxIds,
    Option<ThreadId?>? threadId,
    Option<SelectMode?>? selectMode,
    Option<Uri?>? routeWeb,
    Option<PresentationMailbox?>? mailboxContain,
    Option<List<EmailHeader>?>? emailHeader,
    Option<Set<EmailBodyPart>?>? htmlBody,
    Option<Map<PartId, EmailBodyValue>?>? bodyValues,
    Option<TextHeaderValue?>? headerCalendarEvent,
    Option<TextHeaderValue?>? xPriorityHeader,
    Option<TextHeaderValue?>? importanceHeader,
    Option<TextHeaderValue?>? priorityHeader,
    Option<TextHeaderValue?>? listPostHeader,
    Option<TextHeaderValue?>? listUnsubscribeHeader,
    Option<EmailInThreadStatus?>? emailInThreadStatus,
    Option<MessageIdsHeaderValue?>? messageId,
    Option<MessageIdsHeaderValue?>? references,
  }) {
    return PresentationEmail(
      id: id != null ? id.fold(() => this.id, (value) => value) : this.id,
      blobId: blobId != null ? blobId.fold(() => this.blobId, (value) => value) : this.blobId,
      keywords: keywords != null ? keywords.fold(() => this.keywords, (value) => value) : this.keywords,
      size: size != null ? size.fold(() => this.size, (value) => value) : this.size,
      receivedAt: receivedAt != null ? receivedAt.fold(() => this.receivedAt, (value) => value) : this.receivedAt,
      hasAttachment: hasAttachment != null ? hasAttachment.fold(() => this.hasAttachment, (value) => value) : this.hasAttachment,
      preview: preview != null ? preview.fold(() => this.preview, (value) => value) : this.preview,
      subject: subject != null ? subject.fold(() => this.subject, (value) => value) : this.subject,
      sentAt: sentAt != null ? sentAt.fold(() => this.sentAt, (value) => value) : this.sentAt,
      from: from != null ? from.fold(() => this.from, (value) => value) : this.from,
      to: to != null ? to.fold(() => this.to, (value) => value) : this.to,
      cc: cc != null ? cc.fold(() => this.cc, (value) => value) : this.cc,
      bcc: bcc != null ? bcc.fold(() => this.bcc, (value) => value) : this.bcc,
      replyTo: replyTo != null ? replyTo.fold(() => this.replyTo, (value) => value) : this.replyTo,
      mailboxIds: mailboxIds != null ? mailboxIds.fold(() => this.mailboxIds, (value) => value) : this.mailboxIds,
      threadId: threadId != null ? threadId.fold(() => this.threadId, (value) => value) : this.threadId,
      selectMode: selectMode != null ? (selectMode.fold(() => this.selectMode, (value) => value) ?? this.selectMode) : this.selectMode,
      routeWeb: routeWeb != null ? routeWeb.fold(() => this.routeWeb, (value) => value) : this.routeWeb,
      mailboxContain: mailboxContain != null ? mailboxContain.fold(() => this.mailboxContain, (value) => value) : this.mailboxContain,
      emailHeader: emailHeader != null ? emailHeader.fold(() => this.emailHeader, (value) => value) : this.emailHeader,
      htmlBody: htmlBody != null ? htmlBody.fold(() => this.htmlBody, (value) => value) : this.htmlBody,
      bodyValues: bodyValues != null ? bodyValues.fold(() => this.bodyValues, (value) => value) : this.bodyValues,
      headerCalendarEvent: headerCalendarEvent != null ? headerCalendarEvent.fold(() => this.headerCalendarEvent, (value) => value) : this.headerCalendarEvent,
      xPriorityHeader: xPriorityHeader != null ? xPriorityHeader.fold(() => this.xPriorityHeader, (value) => value) : this.xPriorityHeader,
      importanceHeader: importanceHeader != null ? importanceHeader.fold(() => this.importanceHeader, (value) => value) : this.importanceHeader,
      priorityHeader: priorityHeader != null ? priorityHeader.fold(() => this.priorityHeader, (value) => value) : this.priorityHeader,
      listPostHeader: listPostHeader != null ? listPostHeader.fold(() => this.listPostHeader, (value) => value) : this.listPostHeader,
      listUnsubscribeHeader: listUnsubscribeHeader != null ? listUnsubscribeHeader.fold(() => this.listUnsubscribeHeader, (value) => value) : this.listUnsubscribeHeader,
      emailInThreadStatus: emailInThreadStatus != null ? emailInThreadStatus.fold(() => this.emailInThreadStatus, (value) => value) : this.emailInThreadStatus,
      messageId: messageId != null ? messageId.fold(() => this.messageId, (value) => value) : this.messageId,
      references: references != null ? references.fold(() => this.references, (value) => value) : this.references,
    );
  }
}