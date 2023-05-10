
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/attachment_extension.dart';
import 'package:tmail_ui_user/features/offline_mode/model/attachment_hive_cache.dart';

extension ListAttachmentsExtension on List<Attachment> {
  List<AttachmentHiveCache> toHiveCache() => map((attachment) => attachment.toHiveCache()).toList();
}