
final class AttachmentUploadSizeSnapshot {
  final int currentAllAttachmentBytes;
  final int proposedAllAttachmentBytes;
  final int currentRegularAttachmentBytes;
  final int proposedRegularAttachmentBytes;

  const AttachmentUploadSizeSnapshot({
    required this.currentAllAttachmentBytes,
    required this.proposedAllAttachmentBytes,
    required this.currentRegularAttachmentBytes,
    required this.proposedRegularAttachmentBytes,
  });

  int get allAttachmentBytes => currentAllAttachmentBytes + proposedAllAttachmentBytes;

  int get regularAttachmentBytes => currentRegularAttachmentBytes + proposedRegularAttachmentBytes;
}
