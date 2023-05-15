import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/offline_mode/model/attachment_hive_cache.dart';

extension AttachmentExtension on AttachmentHiveCache {
  Attachment toAttachment() {
    return Attachment(
        partId: PartId(partId!),
        blobId: Id(blobId!),
        size: UnsignedInt(size!),
        name: name,
        type: MediaType.parse(type!),
        cid: cid,
        disposition: disposition?.toContentDisposition(),
    );
  }
}