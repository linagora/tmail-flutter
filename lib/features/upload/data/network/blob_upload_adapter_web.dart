import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:tmail_ui_user/features/upload/data/network/upload_request_extra.dart';
import 'package:web/web.dart' as web;

const _arrayBufferResponseType = 'arraybuffer';
const _withCredentialsExtraKey = 'withCredentials';

/// Installed on every `Dio` that can carry an attachment upload. Every other
/// request falls through to the adapter it wraps.
void installBlobUploadAdapter(Dio dio) {
  if (dio.httpClientAdapter is BlobUploadAdapter) return;
  dio.httpClientAdapter = BlobUploadAdapter(dio.httpClientAdapter);
}

/// Sends an attachment upload's body as the browser's own file handle: the
/// stock adapter buffers a request stream whole before `xhr.send`, while a
/// `Blob` handed to `xhr.send()` is streamed from disk by the browser.
class BlobUploadAdapter implements HttpClientAdapter {
  BlobUploadAdapter(this._inner);

  final HttpClientAdapter _inner;
  final _xhrs = <web.XMLHttpRequest>{};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    final blobUrl = _extractBlobUrl(options);
    if (blobUrl == null) {
      return _inner.fetch(options, requestStream, cancelFuture);
    }
    return _sendBlob(options, blobUrl, cancelFuture);
  }

  String? _extractBlobUrl(RequestOptions options) {
    final extra = options.extra[UploadRequestExtra.uploadAttachmentKey];
    if (extra is! Map) return null;
    return extra[UploadRequestExtra.sourceUrlKey] as String?;
  }

  /// `fetch` + `.blob()` returns the existing handle; no bytes are copied.
  Future<web.Blob> _resolveBlob(RequestOptions options, String blobUrl) async {
    try {
      final response = await web.window.fetch(blobUrl.toJS).toDart;
      return await response.blob().toDart;
    } catch (_) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'The attachment blob URL could not be resolved. '
            'It may have been revoked before the upload started.',
      );
    }
  }

  Future<ResponseBody> _sendBlob(
    RequestOptions options,
    String blobUrl,
    Future<void>? cancelFuture,
  ) async {
    final blob = await _resolveBlob(options, blobUrl);
    final xhr = web.XMLHttpRequest();
    _xhrs.add(xhr);
    final completer = Completer<ResponseBody>();
    Timer? connectTimeoutTimer;

    void fail(DioException error) {
      connectTimeoutTimer?.cancel();
      if (completer.isCompleted) return;
      completer.completeError(error, StackTrace.current);
    }

    xhr
      ..open(options.method, '${options.uri}')
      ..responseType = _arrayBufferResponseType
      ..withCredentials = options.extra[_withCredentialsExtraKey] == true;

    options.headers.remove(Headers.contentLengthHeader);
    options.headers.forEach((key, value) => xhr.setRequestHeader(key, '$value'));

    final xhrTimeout = _xhrTimeout(options);
    if (xhrTimeout != null) {
      xhr.timeout = xhrTimeout.inMilliseconds;
    }

    final connectTimeout = options.connectTimeout;
    if (connectTimeout != null) {
      connectTimeoutTimer = Timer(connectTimeout, () {
        fail(DioException.connectionTimeout(
          requestOptions: options,
          timeout: connectTimeout,
        ));
        xhr.abort();
      });
    }

    final sendStopwatch = Stopwatch();
    xhr.upload.onprogress = ((web.ProgressEvent event) {
      connectTimeoutTimer?.cancel();
      final sendTimeout = options.sendTimeout;
      if (sendTimeout != null) {
        if (!sendStopwatch.isRunning) sendStopwatch.start();
        if (sendStopwatch.elapsed > sendTimeout) {
          fail(DioException.sendTimeout(
            timeout: sendTimeout,
            requestOptions: options,
          ));
          xhr.abort();
          return;
        }
      }
      options.onSendProgress?.call(event.loaded, event.total);
    }).toJS;

    xhr.onprogress = ((web.ProgressEvent event) {
      connectTimeoutTimer?.cancel();
      options.onReceiveProgress?.call(event.loaded, event.total);
    }).toJS;

    xhr.onload = ((web.Event _) {
      connectTimeoutTimer?.cancel();
      if (completer.isCompleted) return;
      final response = xhr.response as JSArrayBuffer?;
      completer.complete(ResponseBody.fromBytes(
        response?.toDart.asUint8List() ?? Uint8List(0),
        xhr.status,
        headers: _parseHeaders(xhr.getAllResponseHeaders()),
        statusMessage: xhr.statusText,
      ));
    }).toJS;

    xhr.onerror = ((web.Event _) {
      fail(DioException.connectionError(
        requestOptions: options,
        reason: 'The XMLHttpRequest onError callback was called. '
            'This typically indicates an error on the network layer.',
      ));
    }).toJS;

    xhr.ontimeout = ((web.Event _) {
      fail(DioException.receiveTimeout(
        timeout: xhrTimeout ?? Duration.zero,
        requestOptions: options,
      ));
    }).toJS;

    // One path for a cancel token and a forced close alike.
    xhr.onabort = ((web.Event _) {
      fail(DioException.requestCancelled(
        requestOptions: options,
        reason: 'The XMLHttpRequest was aborted.',
      ));
    }).toJS;

    cancelFuture?.then((_) => xhr.abort());

    xhr.send(blob);

    return completer.future.whenComplete(() => _xhrs.remove(xhr));
  }

  /// Same bound as the stock adapter: the whole XHR gets connect + receive.
  Duration? _xhrTimeout(RequestOptions options) {
    final connectTimeout = options.connectTimeout;
    final receiveTimeout = options.receiveTimeout;
    if (connectTimeout == null ||
        receiveTimeout == null ||
        receiveTimeout <= Duration.zero) {
      return null;
    }
    return connectTimeout + receiveTimeout;
  }

  /// `getAllResponseHeaders` returns CRLF-separated `name: value` lines.
  Map<String, List<String>> _parseHeaders(String raw) {
    final headers = <String, List<String>>{};
    for (final line in raw.split('\r\n')) {
      final separator = line.indexOf(':');
      if (separator <= 0) continue;
      final name = line.substring(0, separator).trim().toLowerCase();
      final value = line.substring(separator + 1).trim();
      headers.putIfAbsent(name, () => <String>[]).addAll(value.split(','));
    }
    return headers;
  }

  @override
  void close({bool force = false}) {
    if (force) {
      for (final xhr in _xhrs.toList()) {
        xhr.abort();
      }
    }
    _xhrs.clear();
    _inner.close(force: force);
  }
}
