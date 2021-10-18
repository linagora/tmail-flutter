import 'package:model/model.dart';

extension ListAttachmentExtension on List<Attachment> {

  num totalSize() {
    num totalSize = 0;
    forEach((attachment) {
      if (attachment.size != null) {
        totalSize += attachment.size!.value;
      }
    });
    return totalSize;
  }

  List<Attachment> get attachmentsWithDispositionAttachment {
    return where((attachment) => attachment.disposition == ContentDisposition.attachment).toList();
  }

  List<Attachment> get attachmentWithDispositionInlines {
    return where((attachment) => attachment.disposition == ContentDisposition.inline && attachment.cidNotEmpty())
      .toList();
  }
}