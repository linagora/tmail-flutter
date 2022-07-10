

import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/http/converter/email/email_body_value_converter.dart';
import 'package:jmap_dart_client/http/converter/email/email_mailbox_ids_converter.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_value.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_content.dart';
import 'package:model/extensions/media_type_extension.dart';

class EmailDraft with EquatableMixin {

  final EmailId id;
  final Map<MailboxId, bool>? mailboxIds;
  final String? subject;
  final Set<EmailAddress>? from;
  final Set<EmailAddress>? to;
  final Set<EmailAddress>? cc;
  final Set<EmailAddress>? bcc;
  final Set<EmailAddress>? replyTo;
  final Set<EmailBodyPart>? textBody;
  final Set<EmailBodyPart>? htmlBody;
  final Map<PartId, EmailBodyValue>? bodyValues;

  EmailDraft(
      this.id,
      {
        this.mailboxIds,
        this.subject,
        this.from,
        this.to,
        this.cc,
        this.bcc,
        this.replyTo,
        this.textBody,
        this.htmlBody,
        this.bodyValues,
      });

  factory EmailDraft.fromJson(Map<String, dynamic> json) {
    return EmailDraft(
      EmailId(Id(json['id'])),
      mailboxIds: (json['mailboxIds'] as Map<String, dynamic>?)?.map((key, value) => EmailMailboxIdsConverter().parseEntry(key, value)),
      subject: json['subject'] as String?,
      from: (json['from'] as List<dynamic>?)?.map((json) => EmailAddress.fromJson(json)).toSet(),
      to: (json['to'] as List<dynamic>?)?.map((json) => EmailAddress.fromJson(json)).toSet(),
      cc: (json['cc'] as List<dynamic>?)?.map((json) => EmailAddress.fromJson(json)).toSet(),
      bcc: (json['bcc'] as List<dynamic>?)?.map((json) => EmailAddress.fromJson(json)).toSet(),
      bodyValues: (json['bodyValues'] as Map<String, dynamic>?)?.map((key, value) => EmailBodyValueConverter().parseEntry(key, value)),
      replyTo: (json['replyTo'] as List<dynamic>?)?.map((json) => EmailAddress.fromJson(json)).toSet(),
      textBody: (json['textBody'] as List<dynamic>?)?.map((json) => EmailBodyPart.fromJson(json)).toSet(),
      htmlBody: (json['htmlBody'] as List<dynamic>?)?.map((json) => EmailBodyPart.fromJson(json)).toSet(),

    );
  }

  @override
  List<Object?> get props => [
    id,
    subject,
    from,
    to,
    cc,
    bcc,
    replyTo,

  ];

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
}