
class AttachmentSizeLimitPolicy {
  const AttachmentSizeLimitPolicy._();

  static bool isExceededMaxSizeAttachmentsPerEmail({
    required int allAttachmentBytes,
    required int? hardLimitBytes,
  }) {
    if (hardLimitBytes == null) return false;
    return allAttachmentBytes > hardLimitBytes;
  }

  static bool isExceededWarningAttachmentFileSizeInComposer({
    required int regularAttachmentBytes,
    required int warningLimitBytes,
  }) {
    return regularAttachmentBytes > warningLimitBytes;
  }
}
