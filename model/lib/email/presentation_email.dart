
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_value.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_header.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
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
  final Map<IndividualHeaderIdentifier, String?>? headerCalendarEvent;
  final Map<IndividualHeaderIdentifier, String?>? xPriorityHeader;
  final Map<IndividualHeaderIdentifier, String?>? importanceHeader;
  final Map<IndividualHeaderIdentifier, String?>? priorityHeader;
  final Map<IndividualHeaderIdentifier, String?>? listPostHeader;
  final Map<IndividualHeaderIdentifier, String?>? listUnsubscribeHeader;
  final EmailInThreadStatus? emailInThreadStatus;

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

  bool get isAnsweredAndForwarded => isAnswered && isForwarded;

  bool get withAttachments => hasAttachment == true;

  bool get isSelected => selectMode == SelectMode.ACTIVE;

  String get routeWebAsString => routeWeb.toString();

  bool get pushNotificationActivated => !isDraft && !hasRead;

  bool get hasCalendarEvent => headerCalendarEvent?[IndividualHeaderIdentifier.headerCalendarEvent]?.isNotEmpty == true;

  String? get listPost => emailHeader?.toSet().listPost?.trim()
    ?? listPostHeader?[IndividualHeaderIdentifier.listPostHeader]?.trim();

  String? get listUnsubscribe => emailHeader?.toSet().listUnsubscribe?.trim()
    ?? listUnsubscribeHeader?[IndividualHeaderIdentifier.listUnsubscribeHeader]?.trim();

  bool get isMarkAsImportant {
    final xPriority = xPriorityHeader?[IndividualHeaderIdentifier.xPriorityHeader]
      ?.trim()
      .toLowerCase();
    final importance = importanceHeader?[IndividualHeaderIdentifier.importanceHeader]
      ?.trim()
      .toLowerCase();
    final priority = priorityHeader?[IndividualHeaderIdentifier.priorityHeader]
      ?.trim()
      .toLowerCase();

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
    Map<IndividualHeaderIdentifier, String?>? headerCalendarEvent,
    Map<IndividualHeaderIdentifier, String?>? xPriorityHeader,
    Map<IndividualHeaderIdentifier, String?>? importanceHeader,
    Map<IndividualHeaderIdentifier, String?>? priorityHeader,
    Map<IndividualHeaderIdentifier, String?>? listPostHeader,
    Map<IndividualHeaderIdentifier, String?>? listUnsubscribeHeader,
    EmailInThreadStatus? emailInThreadStatus,
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
    );
  }
}