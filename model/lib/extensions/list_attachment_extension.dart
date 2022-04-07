import 'package:model/model.dart';

extension ListAttachmentExtension on List<Attachment> {

  num totalSize() {
    final currentListSize = map((attachment) => attachment.size?.value ?? 0).toList();
    final totalSize = currentListSize.reduce((sum, size) => sum + size);
    return totalSize;
  }

  List<Attachment> get listAttachmentsDisplayedOutSide {
    return where((attachment) => attachment.disposition == ContentDisposition.attachment || attachment.noCid())
        .toList();
  }

  List<Attachment> get listAttachmentsDisplayedInContent {
    return where((attachment) => attachment.hasCid())
      .toList();
  }
}