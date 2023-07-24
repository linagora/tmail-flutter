
import 'package:collection/collection.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/attachment_extension.dart';
import 'package:tmail_ui_user/features/offline_mode/model/attachment_hive_cache.dart';

extension ListAttachmentsExtension on List<Attachment> {
  List<AttachmentHiveCache> toHiveCache() => map((attachment) => attachment.toHiveCache()).toList();

  Set<Attachment> get calendarAttachments => where((attachment) => attachment.isCalendarEvent).toSet();

  Set<Id> get calendarEventBlobIds => calendarAttachments
    .map((attachment) => attachment.blobId)
    .whereNotNull()
    .toSet();
}