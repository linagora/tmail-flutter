import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Result of [OpfsJsBindings.fetchStream]: a locked reader plus the
/// declared content-length (0 when the header is absent/unparseable).
class OpfsFetchStream {
  final web.ReadableStreamDefaultReader reader;
  final int contentLength;

  const OpfsFetchStream({required this.reader, required this.contentLength});
}

/// A raw-XHR upload in flight: [response] resolves with the parsed JSON
/// body, [abort] can be called any time before that to cancel the request.
class XhrUploadHandle {
  final Future<Map<String, dynamic>> response;
  final void Function() abort;

  const XhrUploadHandle({required this.response, required this.abort});
}

/// Bundles [OpfsJsBindings.uploadFile]'s parameters to keep its argument
/// count low.
class XhrUploadFileRequest {
  final web.File file;
  final Uri uploadUri;
  final String authHeader;
  final void Function(int sent, int total) onUploadProgress;

  const XhrUploadFileRequest({
    required this.file,
    required this.uploadUri,
    required this.authHeader,
    required this.onUploadProgress,
  });
}

/// Reads the `getDirectory` property off a `StorageManager` without
/// invoking it, so feature detection never has side effects (no probe
/// file) and can stay synchronous.
extension type _StorageManagerFeatureProbe(JSObject _) implements JSObject {
  external JSAny? get getDirectory;
}

/// The only file in `workplace` touching `dart:js_interop`/`package:web`.
/// Wraps OPFS, `fetch`, and raw-XHR calls behind plain Dart methods so
/// stager/uploader code never touches JS interop directly, and so tests can
/// substitute a fake via [OpfsJsBindings.setInstance] — the same swap-the-
/// singleton seam `WorkplaceDio.setInstance` already uses in this package.
class OpfsJsBindings {
  static OpfsJsBindings _instance = OpfsJsBindings();

  static void setInstance(OpfsJsBindings bindings) => _instance = bindings;

  static OpfsJsBindings get instance => _instance;

  Future<web.FileSystemDirectoryHandle> _opfsRoot() =>
      web.window.navigator.storage.getDirectory().toDart;

  /// True when `navigator.storage.getDirectory` is present. `createWritable`
  /// ships together with it (Baseline across Chrome/Edge, Firefox, and
  /// Safari as of Safari 26.0), so a single, side-effect-free property read
  /// is enough — no probe file, no `await`, so callers can cache this once
  /// per session synchronously.
  bool isOpfsSupported() {
    final storage = web.window.navigator.storage;
    return (storage as _StorageManagerFeatureProbe).getDirectory != null;
  }

  Future<web.FileSystemFileHandle> createTempFile(String fileName) async {
    final root = await _opfsRoot();
    return root
        .getFileHandle(fileName, web.FileSystemGetFileOptions(create: true))
        .toDart;
  }

  /// Resolves an opaque staged-file handle (a `web.FileSystemFileHandle`)
  /// to the `web.File` snapshot the uploader sends. Kept here, not in the
  /// uploader, so casting the opaque [Object] is the bindings' job alone.
  Future<web.File> getFile(Object fileHandle) =>
      (fileHandle as web.FileSystemFileHandle).getFile().toDart;

  Future<web.FileSystemWritableFileStream> openWritable(
      web.FileSystemFileHandle handle) =>
      handle.createWritable().toDart;

  Future<void> writeChunk(
      web.FileSystemWritableFileStream stream, Uint8List chunk) =>
      stream.write(chunk.toJS).toDart;

  Future<void> closeWritable(web.FileSystemWritableFileStream stream) =>
      stream.close().toDart;

  Future<void> abortWritable(web.FileSystemWritableFileStream stream) =>
      stream.abort().toDart;

  Future<void> removeTempFile(String fileName) async {
    final root = await _opfsRoot();
    await root.removeEntry(fileName).toDart;
  }

  /// Streams [url]'s response body. Caller drives it via [readChunk] and
  /// must eventually call [cancelReader] or read to completion.
  ///
  /// [cancelSignal], when given, aborts the underlying `fetch` if it
  /// resolves before headers are received — without it, a request stalled
  /// pre-headers can't be cancelled since no reader exists yet.
  Future<OpfsFetchStream> fetchStream(Uri url, {Future<void>? cancelSignal}) async {
    final controller = web.AbortController();
    if (cancelSignal != null) {
      unawaited(cancelSignal.then((_) => controller.abort()));
    }
    final web.Response response;
    try {
      response = await web.window
          .fetch(url.toString().toJS, web.RequestInit(signal: controller.signal))
          .toDart;
    } catch (e) {
      if (controller.signal.aborted) {
        throw StateError('OpfsJsBindings.fetchStream: request aborted');
      }
      rethrow;
    }
    if (!response.ok) {
      throw StateError('OPFS download failed: HTTP ${response.status}');
    }
    final body = response.body;
    if (body == null) {
      throw StateError('OpfsJsBindings.fetchStream: response has no body');
    }
    final contentLength =
        int.tryParse(response.headers.get('content-length') ?? '') ?? 0;
    final reader = body.getReader() as web.ReadableStreamDefaultReader;
    return OpfsFetchStream(reader: reader, contentLength: contentLength);
  }

  /// Returns the next chunk, or null once the stream is exhausted.
  Future<Uint8List?> readChunk(web.ReadableStreamDefaultReader reader) async {
    final result = await reader.read().toDart;
    if (result.done) return null;
    final value = result.value;
    if (value == null) return Uint8List(0);
    return (value as JSUint8Array).toDart;
  }

  Future<void> cancelReader(web.ReadableStreamDefaultReader reader) =>
      reader.cancel().toDart;

  /// POSTs [file] (an OPFS-backed `File`) to [uploadUri] via a raw XHR,
  /// streaming the upload directly from the OPFS-backed file so it never
  /// materializes in the JS heap. Not refresh-and-retry safe: [authHeader]
  /// is read once, up front.
  XhrUploadHandle uploadFile(XhrUploadFileRequest request) {
    final xhr = web.XMLHttpRequest();
    xhr.open('POST', request.uploadUri.toString());
    xhr.setRequestHeader('Authorization', request.authHeader);

    final completer = Completer<Map<String, dynamic>>();

    xhr.upload.onprogress = ((web.ProgressEvent event) {
      request.onUploadProgress(event.loaded, event.total);
    }).toJS;

    xhr.onload = ((web.Event _) {
      if (completer.isCompleted) return;
      if (xhr.status >= 200 && xhr.status < 300) {
        try {
          completer.complete(
              jsonDecode(xhr.responseText) as Map<String, dynamic>);
        } catch (e) {
          completer.completeError(e);
        }
      } else {
        completer.completeError(
            StateError('OPFS upload failed: HTTP ${xhr.status}'));
      }
    }).toJS;

    xhr.onerror = ((web.Event _) {
      if (!completer.isCompleted) {
        completer.completeError(StateError('OPFS upload network error'));
      }
    }).toJS;

    xhr.onabort = ((web.Event _) {
      if (!completer.isCompleted) {
        completer.completeError(StateError('OPFS upload cancelled'));
      }
    }).toJS;

    xhr.send(request.file);

    return XhrUploadHandle(
      response: completer.future,
      abort: () => xhr.abort(),
    );
  }
}
