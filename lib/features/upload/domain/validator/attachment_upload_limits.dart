
final class AttachmentUploadLimits {
  final int warningLimitBytes;
  final int? hardLimitBytes;

  const AttachmentUploadLimits({
    required this.warningLimitBytes,
    this.hardLimitBytes,
  });
}
