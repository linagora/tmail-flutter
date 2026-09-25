/// Extra-map keys shared by `UploadBody`, the blob adapter and the 401 replay.
/// Kept out of `FileUploader` so a non-JMAP upload can read them too.
abstract final class UploadRequestExtra {
  static const String uploadAttachmentKey = 'upload-attachment';
  static const String openReadKey = 'openRead';
  static const String sourceUrlKey = 'sourceUrl';
}
