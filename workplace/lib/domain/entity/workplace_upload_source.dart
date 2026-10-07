/// What an upload sends; the app's `UploadBody` implements it.
abstract interface class WorkplaceUploadSource {
  /// Read once per attempt, so a stream body is fresh on every retry.
  Object? get requestData;

  /// The `Options.extra` the web blob adapter keys on.
  Map<String, dynamic> get dioExtra;
}
