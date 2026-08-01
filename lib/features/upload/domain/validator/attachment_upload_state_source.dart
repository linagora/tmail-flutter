
/// Supplies the already-attached byte totals and the size limits the
/// attachment upload validator needs, without exposing any controller type.
abstract interface class AttachmentUploadStateSource {
  /// Bytes of every attachment already picked, inline images included.
  int get currentAllAttachmentBytes;

  /// Bytes of the already picked attachments that are not inline images.
  int get currentRegularAttachmentBytes;

  /// Threshold above which the user is warned before uploading.
  int get warningLimitBytes;

  /// Server side hard cap, `null` when the server does not advertise one.
  int? get hardLimitBytes;
}
