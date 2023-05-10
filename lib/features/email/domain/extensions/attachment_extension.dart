
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/offline_mode/model/attachment_hive_cache.dart';

extension AttachmentExtension on Attachment {
  AttachmentHiveCache toHiveCache() {
    return AttachmentHiveCache(
      partId: partId?.value,
      blobId: blobId?.value,
      size: size?.value.toInt(),
      name: name,
      type: type?.mimeType,
      cid: cid,
      disposition: disposition?.name
    );
  }
}