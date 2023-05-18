import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/offline_mode/model/attachment_hive_cache.dart';

extension AttachmentExtension on AttachmentHiveCache {
  Attachment toAttachment() {
    return Attachment(
      partId: partId != null ? PartId(partId!) : null,
      blobId: blobId != null ? Id(blobId!) : null,
      size: size != null ? UnsignedInt(size!) : null,
      name: name,
      type: type != null ? MediaType.parse(type!) : null,
      cid: cid,
      disposition: disposition?.toContentDisposition(),
    );
  }
}