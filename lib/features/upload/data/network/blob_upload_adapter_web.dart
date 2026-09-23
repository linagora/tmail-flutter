// This adapter extends BrowserHttpClientAdapter, which is itself built on
// dart:html's HttpRequest — the same type has to be used here too, rather
// than mixing in package:web's separate JS-interop layer for one class.
// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:tmail_ui_user/features/upload/data/network/upload_request_extra.dart';

@JS('fetch')
external JSPromise<JSObject> _fetchJs(JSString url);

/// Interop view of the JS `Response` object `fetch` resolves to.
extension type _FetchResponse(JSObject _) implements JSObject {
  external JSPromise<JSObject> blob();
}

/// Installed on every `Dio` that can carry an attachment upload. Every other
/// request falls through to the stock adapter unchanged.
void installBlobUploadAdapter(Dio dio) {
  dio.httpClientAdapter = BlobUploadAdapter();
}

/// Sends an attachment upload's body as the browser's own file handle
/// instead of reading it into memory first: the stock adapter accumulates a
/// request body stream into one buffer before `xhr.send`, which makes an
/// upload on web hold several times the file's size in the Dart heap. A
/// `Blob` handed to `xhr.send()` is streamed from disk by the browser
/// instead, with nothing resident here.
class BlobUploadAdapter extends BrowserHttpClientAdapter {
  /// Aborted on a forced close, mirroring the stock adapter's own set. Kept
  /// private rather than reusing the parent's `xhrs`, which is
  /// `@visibleForTesting` and not meant to be touched from here.
  final _blobXhrs = <HttpRequest>{};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    final blobUrl = _extractBlobUrl(options);
    if (blobUrl == null) {
      return super.fetch(options, requestStream, cancelFuture);
    }
    return _sendBlob(options, blobUrl, cancelFuture);
  }

  String? _extractBlobUrl(RequestOptions options) {
    final extra = options.extra[UploadRequestExtra.uploadAttachmentKey];
    if (extra is! Map) return null;
    return extra[UploadRequestExtra.sourceUrlKey] as String?;
  }

  /// `fetch` + `.blob()` returns the existing handle on Blink; an XHR read
  /// copies the whole file instead.
  Future<Blob> _resolveBlob(String blobUrl) async {
    final response = await _fetchJs(blobUrl.toJS).toDart;
    final jsBlob = await _FetchResponse(response).blob().toDart;
    return jsBlob as Blob;
  }

  /// Falls back to a buffering read rather than lose the attachment.
  Future<Blob> _resolveBlobViaXhr(RequestOptions options, String blobUrl) async {
    final fallback = await HttpRequest.request(blobUrl, responseType: 'blob');
    final response = fallback.response;
    if (response is! Blob) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'The attachment blob URL could not be resolved. '
            'It may have been revoked before the upload started.',
      );
    }
    return response;
  }

  /// Resolves the handle via [_resolveBlob]; bytes only leave via `xhr.send`.
  Future<ResponseBody> _sendBlob(
    RequestOptions options,
    String blobUrl,
    Future<void>? cancelFuture,
  ) async {
    Blob blob;
    try {
      blob = await _resolveBlob(blobUrl);
    } catch (_) {
      blob = await _resolveBlobViaXhr(options, blobUrl);
    }

    final xhr = HttpRequest();
    _blobXhrs.add(xhr);
    xhr
      ..open(options.method, '${options.uri}')
      ..responseType = 'arraybuffer';

    final withCredentialsOption = options.extra['withCredentials'];
    xhr.withCredentials = withCredentialsOption == true || withCredentials;

    options.headers.remove(Headers.contentLengthHeader);
    options.headers.forEach((key, v) => xhr.setRequestHeader(key, '$v'));

    final connectTimeout = options.connectTimeout;
    final receiveTimeout = options.receiveTimeout;
    var xhrTimeout = 0;
    if (connectTimeout != null &&
        receiveTimeout != null &&
        receiveTimeout > Duration.zero) {
      xhrTimeout = (connectTimeout + receiveTimeout).inMilliseconds;
      xhr.timeout = xhrTimeout;
    }

    final completer = Completer<ResponseBody>();

    xhr.onLoad.first.then((_) {
      final body = (xhr.response as ByteBuffer).asUint8List();
      completer.complete(ResponseBody.fromBytes(
        body,
        xhr.status!,
        headers: xhr.responseHeaders.map((k, v) => MapEntry(k, v.split(','))),
        statusMessage: xhr.statusText,
        isRedirect: xhr.status == 302 || xhr.status == 301,
      ));
    });

    Timer? connectTimeoutTimer;
    if (connectTimeout != null) {
      connectTimeoutTimer = Timer(connectTimeout, () {
        if (completer.isCompleted) return;
        xhr.abort();
        completer.completeError(
          DioException.connectionTimeout(
            requestOptions: options,
            timeout: connectTimeout,
          ),
          StackTrace.current,
        );
      });
    }

    final sendStopwatch = Stopwatch();
    xhr.upload.onProgress.listen((event) {
      connectTimeoutTimer?.cancel();
      connectTimeoutTimer = null;

      final sendTimeout = options.sendTimeout;
      if (sendTimeout != null) {
        if (!sendStopwatch.isRunning) {
          sendStopwatch.start();
        }
        if (sendStopwatch.elapsed > sendTimeout) {
          sendStopwatch.stop();
          completer.completeError(
            DioException.sendTimeout(timeout: sendTimeout, requestOptions: options),
            StackTrace.current,
          );
          xhr.abort();
        }
      }
      if (options.onSendProgress != null &&
          event.loaded != null &&
          event.total != null) {
        options.onSendProgress!(event.loaded!, event.total!);
      }
    });

    xhr.onError.first.then((_) {
      connectTimeoutTimer?.cancel();
      completer.completeError(
        DioException.connectionError(
          requestOptions: options,
          reason: 'The XMLHttpRequest onError callback was called. '
              'This typically indicates an error on the network layer.',
        ),
        StackTrace.current,
      );
    });

    xhr.onTimeout.first.then((_) {
      connectTimeoutTimer?.cancel();
      if (!completer.isCompleted) {
        completer.completeError(
          DioException.receiveTimeout(
            timeout: Duration(milliseconds: xhrTimeout),
            requestOptions: options,
          ),
          StackTrace.current,
        );
      }
    });

    cancelFuture?.then((_) {
      if (xhr.readyState < 4 && xhr.readyState > 0) {
        connectTimeoutTimer?.cancel();
        try {
          xhr.abort();
        } catch (_) {}
        // xhr.onError does not fire on an aborted request, so the cancel
        // has to be surfaced here or the future would hang.
        if (!completer.isCompleted) {
          completer.completeError(
            DioException.requestCancelled(
              requestOptions: options,
              reason: 'The XMLHttpRequest was aborted.',
            ),
          );
        }
      }
    });

    // The one difference from the stock adapter: a blob body, not bytes.
    xhr.send(blob);

    return completer.future.whenComplete(() => _blobXhrs.remove(xhr));
  }

  @override
  void close({bool force = false}) {
    if (force) {
      for (final xhr in _blobXhrs) {
        xhr.abort();
      }
    }
    _blobXhrs.clear();
    super.close(force: force);
  }
}
