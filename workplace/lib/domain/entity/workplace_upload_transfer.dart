/// Progress, cancel and timeout for one upload, free of transport types.
class WorkplaceUploadTransfer {
  final void Function(int sent, int total)? onProgress;

  /// Completing it aborts the upload, including any in-flight conflict retry.
  final Future<void>? cancelSignal;

  /// Overrides the transport's short default; a multi-MB body needs minutes.
  final Duration? timeout;

  const WorkplaceUploadTransfer({this.onProgress, this.cancelSignal, this.timeout});
}
