
import 'package:model/email/attachment.dart';

class EMLAttachment extends Attachment {

  EMLAttachment({
    super.partId,
    super.blobId,
    super.size,
    super.name,
    super.type,
    super.cid,
    super.disposition,
  });
}