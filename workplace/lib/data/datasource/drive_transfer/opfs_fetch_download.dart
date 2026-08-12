import 'dart:async';
import 'dart:js_interop';

import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'package:workplace/data/datasource/drive_transfer/drive_download_source.dart';

/// The download leg: `fetch` driven one chunk at a time, so a document never
/// has to fit in the JS heap.
class OpfsFetchDownload implements DriveDownloadSource {
  /// Opens [url]'s response body for reading. Caller drives it via [readChunk]
  /// and must eventually call [cancelReader] or read to completion.
  ///
  /// [cancelSignal], when given, aborts the underlying `fetch` if it
  /// resolves before headers are received — without it, a request stalled
  /// pre-headers can't be cancelled since no reader exists yet.
  ///
  /// Failures come out as [DioException], the shape
  /// `BufferedWebDriveFileStager` produces, so callers branch on
  /// `DioExceptionType` instead of matching messages. Cancellation surfaces as
  /// `cancel` — the same type Dio gives the buffered leg for the same user
  /// action — and any other transport failure (CORS, DNS, TLS, offline, which
  /// reject with a browser `TypeError` rather than anything Dio-shaped) as
  /// `connectionError` carrying the original error.
  ///
  /// **What an abort does.** `AbortController.abort()` never throws; it rejects
  /// whatever the signal is attached to with an `AbortError` `DOMException`,
  /// and where that lands depends on when it fires. Before the headers arrive
  /// it rejects the `fetch` itself, caught below and mapped to `cancel`. After
  /// they arrive this method has already returned, so it instead errors the
  /// body stream and surfaces from [readChunk] as `connectionError` — a
  /// dropped connection is indistinguishable from an abort at that level, so
  /// only the caller's [CancelToken] can tell the two apart.
  @override
  Future<FetchDownloadHandle> openDownload(Uri url,
      {Future<void>? cancelSignal}) async {
    final requestOptions = RequestOptions(path: url.toString());
    final controller = web.AbortController();
    // Recorded here so a user cancellation can be told from any other fetch
    // rejection. Set before `abort()`, hence observable by the time the fetch
    // rejects.
    var cancelled = false;
    if (cancelSignal != null) {
      // `catchError` because nothing awaits this listener: a throwing `abort()`
      // would otherwise escape as an unhandled async error rather than through
      // any of the mapping below. Same guard as `OpfsDriveFileStager.stage`'s
      // `whenCancel` listener.
      unawaited(cancelSignal.then((_) {
        cancelled = true;
        controller.abort();
      }).catchError((error) {
        logWarning('OpfsFetchDownload: failed to abort the download fetch: $error');
      }));
    }
    final web.Response response;
    try {
      response = await web.window
          .fetch(url.toString().toJS, web.RequestInit(signal: controller.signal))
          .toDart;
    } catch (e) {
      if (cancelled) {
        throw DioException.requestCancelled(
          requestOptions: requestOptions,
          reason: 'the download was cancelled',
        );
      }
      // Spelled out rather than via `DioException.connectionError`, which
      // hardcodes `error: null` and would drop the browser's own failure.
      throw DioException(
        type: DioExceptionType.connectionError,
        requestOptions: requestOptions,
        error: e,
        message: 'The connection errored: the download request failed',
      );
    }
    return handleFromResponse(response, requestOptions);
  }

  /// Validates the headers [openDownload] received and locks the body for
  /// reading. A response that arrived is not yet a usable download: the status
  /// can be an error, and a body can be absent entirely.
  ///
  /// Visible for tests: a null body (204/304) and an absent `content-length`
  /// (a chunked response) are shapes no fixture the test server can serve
  /// produces, so they are driven through a constructed `web.Response`.
  @visibleForTesting
  FetchDownloadHandle handleFromResponse(
      web.Response response, RequestOptions requestOptions) {
    if (!response.ok) {
      throw DioException.badResponse(
        statusCode: response.status,
        requestOptions: requestOptions,
        response: Response<void>(
          requestOptions: requestOptions,
          statusCode: response.status,
        ),
      );
    }
    final body = response.body;
    if (body == null) {
      throw DioException.connectionError(
        requestOptions: requestOptions,
        reason: 'the download response has no body',
      );
    }
    final contentLength =
        int.tryParse(response.headers.get('content-length') ?? '') ?? -1;
    final reader = body.getReader() as web.ReadableStreamDefaultReader;
    return FetchDownloadHandle(reader: reader, contentLength: contentLength);
  }

  /// Returns the next chunk, or null once the stream is exhausted.
  ///
  /// A read can still fail after the headers [openDownload] mapped: the abort
  /// controller stays live for the body, and the connection can drop
  /// mid-stream. Both reject with a browser error, so they are re-shaped here
  /// to keep this mixin's every-failure-is-a-[DioException] contract. Only the
  /// caller holds the [CancelToken], so telling a cancellation from a
  /// transport failure is its job.
  @override
  Future<Uint8List?> readChunk(web.ReadableStreamDefaultReader reader) async {
    final web.ReadableStreamReadResult result;
    try {
      result = await reader.read().toDart;
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        type: DioExceptionType.connectionError,
        requestOptions: RequestOptions(path: ''),
        error: e,
        message: 'The connection errored: reading the download body failed',
      );
    }
    if (result.done) return null;
    final value = result.value;
    if (value == null) return Uint8List(0);
    return (value as JSUint8Array).toDart;
  }

  @override
  Future<void> cancelReader(web.ReadableStreamDefaultReader reader) =>
      reader.cancel().toDart;

  /// Best-effort: the lock a `getReader()` took stays held until this is
  /// called, and it is a no-op on a reader that no longer holds one.
  @override
  void releaseReaderLock(web.ReadableStreamDefaultReader reader) =>
      reader.releaseLock();
}
