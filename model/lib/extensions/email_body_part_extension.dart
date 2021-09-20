import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:model/model.dart';

extension EmailBodyPartExtension on EmailBodyPart {
  Attachment toAttachment() => Attachment(
    partId: partId,
    blobId: blobId,
    size: size,
    name: name,
    type: type,
    cid: cid,
    disposition: disposition);
}
