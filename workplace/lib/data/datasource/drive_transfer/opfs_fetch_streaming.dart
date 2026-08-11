import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:web/web.dart' as web;
import 'package:workplace/data/datasource/drive_transfer/drive_file_stager.dart';

/// Result of [OpfsFetchStreaming.fetchStream]: a locked reader plus the
/// declared content-length (-1 when the header is absent/unparseable, the
/// same unknown-total sentinel Dio's `onReceiveProgress` uses).
class OpfsFetchStream {
  final web.ReadableStreamDefaultReader reader;
  final int contentLength;

  const OpfsFetchStream({required this.reader, required this.contentLength});
}

/// The download leg: `fetch` driven one chunk at a time, so a document never
/// has to fit in the JS heap.
mixin OpfsFetchStreaming {
  /// Streams [url]'s response body. Caller drives it via [readChunk] and
  /// must eventually call [cancelReader] or read to completion.
  ///
  /// [cancelSignal], when given, aborts the underlying `fetch` if it
  /// resolves before headers are received — without it, a request stalled
  /// pre-headers can't be cancelled since no reader exists yet.
  ///
  /// A stalled server is bounded by [driveTransferReceiveTimeout]: the abort
  /// controller fires if headers don't arrive in time.
  ///
  /// Failures come out as [DioException], the shape
  /// `BufferedWebDriveFileStager` produces, so callers branch on
  /// `DioExceptionType` instead of matching messages. Cancellation surfaces as
  /// `cancel` — the same type Dio gives the buffered leg for the same user
  /// action — a headers stall as `receiveTimeout`, and any other transport
  /// failure (CORS, DNS, TLS, offline, which reject with a browser `TypeError`
  /// rather than anything Dio-shaped) as `connectionError` carrying the
  /// original error.
  Future<OpfsFetchStream> fetchStream(Uri url, {Future<void>? cancelSignal}) async {
    final requestOptions = RequestOptions(path: url.toString());
    final controller = web.AbortController();
    // Both aborts go through the one controller, so the reason has to be
    // recorded here to tell a user cancellation from a stalled server. Set
    // before `abort()`, hence observable by the time the fetch rejects.
    var cancelled = false;
    var timedOut = false;
    if (cancelSignal != null) {
      unawaited(cancelSignal.then((_) {
        cancelled = true;
        controller.abort();
      }));
    }
    final headersDeadline = Timer(driveTransferReceiveTimeout, () {
      timedOut = true;
      controller.abort();
    });
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
      if (timedOut) {
        throw DioException.receiveTimeout(
          timeout: driveTransferReceiveTimeout,
          requestOptions: requestOptions,
          error: e,
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
    } finally {
      headersDeadline.cancel();
    }
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
    return OpfsFetchStream(reader: reader, contentLength: contentLength);
  }

  /// Returns the next chunk, or null once the stream is exhausted.
  ///
  /// A read can still fail after the headers [fetchStream] mapped: the abort
  /// controller stays live for the body, and the connection can drop
  /// mid-stream. Both reject with a browser error, so they are re-shaped here
  /// to keep this mixin's every-failure-is-a-[DioException] contract. Only the
  /// caller holds the [CancelToken], so telling a cancellation from a
  /// transport failure is its job.
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

  Future<void> cancelReader(web.ReadableStreamDefaultReader reader) =>
      reader.cancel().toDart;

  /// Best-effort: the lock a `getReader()` took stays held until this is
  /// called, and it is a no-op on a reader that no longer holds one.
  void releaseReaderLock(web.ReadableStreamDefaultReader reader) =>
      reader.releaseLock();
}
