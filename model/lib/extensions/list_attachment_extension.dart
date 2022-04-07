import 'package:model/model.dart';

extension ListAttachmentExtension on List<Attachment> {

  num totalSize() {
    if (isNotEmpty) {
      final currentListSize = map((attachment) => attachment.size?.value ?? 0).toList();
      final totalSize = currentListSize.reduce((sum, size) => sum + size);
      return totalSize;
    }
    return 0;
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