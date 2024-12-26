
import 'package:collection/collection.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/email/attachment.dart';
import 'package:model/extensions/attachment_extension.dart';

extension ListAttachmentExtension on List<Attachment> {

  num get totalSize {
    if (isNotEmpty) {
      final currentListSize = map((attachment) => attachment.size?.value ?? 0).toList();
      final totalSize = currentListSize.reduce((sum, size) => sum + size);
      return totalSize;
    }
    return 0;
  }

  List<Attachment> getListAttachmentsDisplayedOutside(List<Attachment> htmlBodyAttachments) {
    return where((attachment) => attachment.isOutsideAttachment(htmlBodyAttachments)).toList();
  }

  bool include(Attachment newAttachment) {
    final matchedAttachment = firstWhereOrNull((attachment) => attachment.blobId == newAttachment.blobId);
    return matchedAttachment != null;
  }

  List<Attachment> get listAttachmentsDisplayedInContent =>
    where((attachment) => attachment.hasCid() && (attachment.isDispositionInlined() || attachment.isDispositionUndefined()))
    .toList();

  Map<String, String> toMapCidImageDownloadUrl({
    required AccountId accountId,
    required String downloadUrl
  }) {
    final mapUrlDownloadCID = {
      for (var attachment in this)
        attachment.cid! : attachment.getDownloadUrl(downloadUrl, accountId)
    };
    return mapUrlDownloadCID;
  }
}