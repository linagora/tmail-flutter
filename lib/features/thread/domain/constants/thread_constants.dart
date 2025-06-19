import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
import 'package:model/email/email_property.dart';

class ThreadConstants {
  static const maxCountEmails = 20;
  static final defaultLimit = UnsignedInt(maxCountEmails);
  static final propertiesDefault = Properties({
    EmailProperty.id,
    EmailProperty.blobId,
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
    EmailProperty.threadId,
    IndividualHeaderIdentifier.xPriorityHeader.value,
    IndividualHeaderIdentifier.importanceHeader.value,
    IndividualHeaderIdentifier.priorityHeader.value,
  });
  static final propertiesUpdatedDefault = Properties({
    EmailProperty.keywords,
    EmailProperty.mailboxIds,
    EmailProperty.threadId,
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
    IndividualHeaderIdentifier.sMimeStatusHeader.value,
  });

  static final propertiesGetDetailedEmail = Properties({
    EmailProperty.id,
    EmailProperty.blobId,
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
    EmailProperty.threadId,
    EmailProperty.bodyValues,
    EmailProperty.htmlBody,
    EmailProperty.attachments,
    EmailProperty.headers,
    IndividualHeaderIdentifier.sMimeStatusHeader.value,
    IndividualHeaderIdentifier.identityHeader.value,
  });

  static final propertiesCalendarEvent = Properties({
    ...propertiesDefault.value,
    IndividualHeaderIdentifier.headerCalendarEvent.value,
  });

  static const int defaultMaxHeightEmailItemOnBrowser = 40;
  static const int defaultMaxHeightBrowser = 1200;

  static final propertiesParseEmailByBlobId = Properties({
    EmailProperty.id,
    EmailProperty.blobId,
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
    EmailProperty.headers,
    EmailProperty.messageId,
    EmailProperty.references,
  });
}