class StoragePermissionException implements Exception {
  final dynamic error;

  StoragePermissionException(this.error);
}
