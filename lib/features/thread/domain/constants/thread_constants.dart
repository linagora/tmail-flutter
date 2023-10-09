import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
import 'package:model/email/email_property.dart';

class ThreadConstants {
  static final defaultLimit = UnsignedInt(20);
  static final propertiesDefault = Properties({
    EmailProperty.id,
    EmailProperty.subject,
    EmailProperty.from,
    EmailProperty.to,
    EmailProperty.cc,
    EmailProperty.bcc,
    EmailProperty.keywords,
    EmailProperty.size,
    EmailProperty.receivedAt,
    EmailProperty.sentAt,
    EmailProperty.preview,
    EmailProperty.hasAttachment,
    EmailProperty.replyTo,
    EmailProperty.mailboxIds,
  });
  static final propertiesUpdatedDefault = Properties({
    EmailProperty.keywords,
    EmailProperty.mailboxIds,
  });

  static final propertiesQuickSearch = Properties({
    EmailProperty.id,
    EmailProperty.subject,
    EmailProperty.from,
    EmailProperty.to,
    EmailProperty.keywords,
    EmailProperty.receivedAt,
    EmailProperty.sentAt,
    EmailProperty.preview,
    EmailProperty.hasAttachment,
    EmailProperty.mailboxIds,
  });

  static final propertiesGetEmailContent = Properties({
    EmailProperty.bodyValues,
    EmailProperty.htmlBody,
    EmailProperty.attachments,
    EmailProperty.headers,
    EmailProperty.keywords,
    EmailProperty.mailboxIds,
    EmailProperty.messageId,
    EmailProperty.references,
  });

  static final propertiesGetDetailedEmail = Properties({
    EmailProperty.id,
    EmailProperty.subject,
    EmailProperty.from,
    EmailProperty.to,
    EmailProperty.cc,
    EmailProperty.bcc,
    EmailProperty.keywords,
    EmailProperty.size,
    EmailProperty.receivedAt,
    EmailProperty.sentAt,
    EmailProperty.preview,
    EmailProperty.hasAttachment,
    EmailProperty.replyTo,
    EmailProperty.mailboxIds,
    EmailProperty.bodyValues,
    EmailProperty.htmlBody,
    EmailProperty.attachments,
    EmailProperty.headers
  });

  static final propertiesCalendarEvent = Properties({
    EmailProperty.id,
    EmailProperty.subject,
    EmailProperty.from,
    EmailProperty.to,
    EmailProperty.cc,
    EmailProperty.bcc,
    EmailProperty.keywords,
    EmailProperty.size,
    EmailProperty.receivedAt,
    EmailProperty.sentAt,
    EmailProperty.preview,
    EmailProperty.hasAttachment,
    EmailProperty.replyTo,
    EmailProperty.mailboxIds,
    IndividualHeaderIdentifier.headerCalendarEvent.value,
  });
}