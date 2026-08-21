/// Thrown when the upload-from-url response reports a different account than the one requested.
class UploadFromUrlAccountMismatchException implements Exception {
  @override
  String toString() => 'UploadFromUrlAccountMismatchException: response accountId does not match the requested accountId';
}
