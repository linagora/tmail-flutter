import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:tmail_ui_user/features/email/presentation/model/attachment_file.dart';

extension EmailBodyPartExtension on EmailBodyPart {
  AttachmentFile toAttachmentFile() => AttachmentFile(partId, blobId, size, name, type, cid);
}
