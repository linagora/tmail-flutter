import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:model/model.dart';

extension EmailBodyPartExtension on EmailBodyPart {
  Attachment toAttachment() => Attachment(partId, blobId, size, name, type, cid);
}
