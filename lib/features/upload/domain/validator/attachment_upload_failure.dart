
sealed class AttachmentUploadFailure {
  const AttachmentUploadFailure();
}

final class MaxEmailAttachmentSizeExceeded extends AttachmentUploadFailure {
  final int maximumBytes;

  const MaxEmailAttachmentSizeExceeded(this.maximumBytes);
}
