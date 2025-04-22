import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_header.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/email/attachment.dart';

class DetailedEmail with EquatableMixin {
  final EmailId emailId;
  final List<Attachment>? attachments;
  final Set<EmailHeader>? headers;
  final Map<KeyWordIdentifier, bool>? keywords;
  final String? htmlEmailContent;
  final String? emailContentPath;
  final DateTime createdTime;
  final MessageIdsHeaderValue? messageId;
  final MessageIdsHeaderValue? references;
  final List<Attachment>? inlineImages;
  final Map<IndividualHeaderIdentifier, String?>? sMimeStatusHeader;
  final Map<IndividualHeaderIdentifier, String?>? identityHeader;

  DetailedEmail({
    required this.emailId,
    required this.createdTime,
    this.attachments,
    this.headers,
    this.keywords,
    this.htmlEmailContent,
    this.emailContentPath,
    this.messageId,
    this.references,
    this.inlineImages,
    this.sMimeStatusHeader,
    this.identityHeader,
  });

  @override
  List<Object?> get props => [
    emailId,
    createdTime,
    attachments,
    headers,
    keywords,
    htmlEmailContent,
    emailContentPath,
    messageId,
    references,
    inlineImages,
    sMimeStatusHeader,
    identityHeader,
  ];
}