
enum UploadFileStatus {
  waiting,
  uploading,
  uploadFailed,
  succeed
}

extension UploadFileStatusExtension on UploadFileStatus {
  bool get completed =>
      this == UploadFileStatus.uploadFailed || this == UploadFileStatus.succeed;
}