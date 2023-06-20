import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_header.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/email/attachment.dart';

class DetailedEmail with EquatableMixin {
  final EmailId emailId;
  final List<Attachment>? attachments;
  final Set<EmailHeader>? headers;
  final Map<KeyWordIdentifier, bool>? keywords;
  final String? htmlEmailContent;
  final String? emailContentPath;

  DetailedEmail({
    required this.emailId,
    this.attachments,
    this.headers,
    this.keywords,
    this.htmlEmailContent,
    this.emailContentPath
  });

  @override
  List<Object?> get props => [
    emailId,
    attachments,
    headers,
    keywords,
    htmlEmailContent,
    emailContentPath
  ];
}