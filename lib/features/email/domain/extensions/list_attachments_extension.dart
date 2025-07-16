
import 'package:collection/collection.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:model/email/attachment.dart';
import 'package:model/extensions/attachment_extension.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/attachment_extension.dart';
import 'package:tmail_ui_user/features/offline_mode/model/attachment_hive_cache.dart';

extension ListAttachmentsExtension on List<Attachment> {
  List<AttachmentHiveCache> toHiveCache() => map((attachment) => attachment.toHiveCache()).toList();

  Set<Id> get calendarEventBlobIds => subtypeICSBlobIds.isEmpty ? subtypeCalendarBlobIds : subtypeICSBlobIds;

  Set<Id> get subtypeICSBlobIds => where((attachment) => attachment.type?.subtype == Attachment.eventICSSubtype)
    .map((attachment) => attachment.blobId)
    .whereNotNull()
    .toSet();

  Set<Id> get subtypeCalendarBlobIds => where((attachment) => attachment.type?.subtype == Attachment.eventCalendarSubtype)
    .map((attachment) => attachment.blobId)
    .whereNotNull()
    .toSet();

  Set<EmailBodyPart> toEmailBodyPart({String? charset}) => map((attachment) => attachment.toEmailBodyPart(charset: charset)).toSet();
}