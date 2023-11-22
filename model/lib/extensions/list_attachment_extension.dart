
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/email/attachment.dart';

extension ListAttachmentExtension on List<Attachment> {

  num totalSize() {
    if (isNotEmpty) {
      final currentListSize = map((attachment) => attachment.size?.value ?? 0).toList();
      final totalSize = currentListSize.reduce((sum, size) => sum + size);
      return totalSize;
    }
    return 0;
  }

  List<Attachment> get listAttachmentsDisplayedOutSide => where((attachment) => attachment.noCid() || !attachment.isInlined()).toList();

  List<Attachment> get listAttachmentsDisplayedInContent => where((attachment) => attachment.hasCid()).toList();

  Map<String, String> toMapCidImageDownloadUrl({
    required AccountId accountId,
    required String downloadUrl
  }) {
    final mapUrlDownloadCID = {
      for (var attachment in listAttachmentsDisplayedInContent)
        attachment.cid! : attachment.getDownloadUrl(downloadUrl, accountId)
    };
    return mapUrlDownloadCID;
  }
}