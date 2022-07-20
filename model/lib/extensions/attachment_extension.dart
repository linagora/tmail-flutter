
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:model/model.dart';

extension AttachmentExtension on Attachment {
  EmailBodyPart toEmailBodyPart({String? disposition, String? charset}) => EmailBodyPart(
    partId: partId,
    blobId: blobId,
    size: size,
    name: name,
    type: type,
    cid: cid,
    charset: charset,
    disposition: disposition ?? this.disposition?.value);

  Attachment toAttachmentWithDisposition({
    ContentDisposition? disposition,
    String? cid
  }) {
    return Attachment(
        partId: partId,
        blobId: blobId,
        size: size,
        name: name,
        type: type,
        cid: cid ?? this.cid,
        disposition: disposition ?? this.disposition
    );
  }
}