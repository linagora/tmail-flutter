import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class SearchEmail extends Email {
  final String? searchSnippetSubject;
  final String? searchSnippetPreview;

  SearchEmail({
    super.id,
    super.blobId,
    super.threadId,
    super.mailboxIds,
    super.keywords,
    super.size,
    super.receivedAt,
    super.headers,
    super.messageId,
    super.inReplyTo,
    super.references,
    super.subject,
    super.sentAt,
    super.hasAttachment,
    super.preview,
    super.sender,
    super.from,
    super.to,
    super.cc,
    super.bcc,
    super.replyTo,
    super.textBody,
    super.htmlBody,
    super.attachments,
    super.bodyStructure,
    super.bodyValues,
    super.headerUserAgent,
    super.headerMdn,
    super.headerReturnPath,
    super.headerCalendarEvent,
    super.xPriorityHeader,
    super.importanceHeader,
    super.priorityHeader,
    super.sMimeStatusHeader,
    super.identityHeader,
    required this.searchSnippetSubject,
    required this.searchSnippetPreview
  });

  @override
  List<Object?> get props => [
    ...super.props,
    searchSnippetSubject,
    searchSnippetPreview,
  ];
  
  factory SearchEmail.fromEmail(
    Email email, {
    String? searchSnippetSubject,
    String? searchSnippetPreview,
  }) {
    return SearchEmail(
      id: email.id,
      blobId: email.blobId,
      threadId: email.threadId,
      mailboxIds: email.mailboxIds,
      keywords: email.keywords,
      size: email.size,
      receivedAt: email.receivedAt,
      headers: email.headers,
      messageId: email.messageId,
      inReplyTo: email.inReplyTo,
      references: email.references,
      subject: email.subject,
      sentAt: email.sentAt,
      hasAttachment: email.hasAttachment,
      preview: email.preview,
      sender: email.sender,
      from: email.from,
      to: email.to,
      cc: email.cc,
      bcc: email.bcc,
      replyTo: email.replyTo,
      textBody: email.textBody,
      htmlBody: email.htmlBody,
      attachments: email.attachments,
      bodyStructure: email.bodyStructure,
      bodyValues: email.bodyValues,
      headerUserAgent: email.headerUserAgent,
      headerMdn: email.headerMdn,
      headerReturnPath: email.headerReturnPath,
      headerCalendarEvent: email.headerCalendarEvent,
      xPriorityHeader: email.xPriorityHeader,
      importanceHeader: email.importanceHeader,
      priorityHeader: email.priorityHeader,
      sMimeStatusHeader: email.sMimeStatusHeader,
      identityHeader: email.identityHeader,
      searchSnippetSubject: searchSnippetSubject,
      searchSnippetPreview: searchSnippetPreview,
    );
  }
}