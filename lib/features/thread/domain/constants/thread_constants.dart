import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
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
}