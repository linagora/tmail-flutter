
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:model/model.dart';

extension AttachmentExtension on Attachment {
  EmailBodyPart toEmailBodyPart(String disposition) => EmailBodyPart(
    blobId: blobId,
    size: size,
    name: name,
    type: type,
    disposition: disposition);
}