import 'package:dio/dio.dart';

/// Streamed-upload concerns a bearer-token request can report.
class WorkplaceRequestTransfer {
  final ProgressCallback? onSendProgress;
  final CancelToken? cancelToken;

  /// Overrides `WorkplaceDio`'s short default; a multi-MB body needs minutes,
  /// and on web the blob adapter caps the whole XHR at connect + receive.
  final Duration? timeout;

  const WorkplaceRequestTransfer({this.onSendProgress, this.cancelToken, this.timeout});
}
