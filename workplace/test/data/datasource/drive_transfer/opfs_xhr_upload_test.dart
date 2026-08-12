@TestOn('chrome')
library;

import 'dart:js_interop';
// `setProperty`/`getProperty` — building and driving the scripted XHR below.
import 'dart:js_interop_unsafe';

import 'package:core/data/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;
import 'package:workplace/data/datasource/drive_transfer/opfs_xhr_upload.dart';

/// A scripted stand-in for `XMLHttpRequest`: it records what `uploadFile`
/// asked of it and lets a test fire the events the browser would, so every
/// branch of the wiring runs without a server. Only the transport is
/// substituted — the handler bodies under test are the real ones.
class _FakeXhr {
  final object = JSObject();
  final headers = <String, String>{};
  final openArgs = <String>[];
  var sendCount = 0;
  var abortCount = 0;

  /// Set to have the matching call throw the way the browser does on a
  /// malformed URL, a forbidden header or a detached file.
  bool throwOnOpen = false;
  bool throwOnSetRequestHeader = false;
  bool throwOnSend = false;

  _FakeXhr() {
    object.setProperty('upload'.toJS, JSObject());
    object.setProperty(
      'open'.toJS,
      ((String method, String url) {
        if (throwOnOpen) throw StateError('open failed');
        openArgs
          ..add(method)
          ..add(url);
      }).toJS,
    );
    object.setProperty(
      'setRequestHeader'.toJS,
      ((String name, String value) {
        if (throwOnSetRequestHeader) throw StateError('setRequestHeader failed');
        headers[name] = value;
      }).toJS,
    );
    object.setProperty(
      'send'.toJS,
      ((JSAny? body) {
        if (throwOnSend) throw StateError('send failed');
        sendCount++;
      }).toJS,
    );
    object.setProperty('abort'.toJS, (() => abortCount++).toJS);
  }

  web.XMLHttpRequest get xhr => object as web.XMLHttpRequest;

  void fireUploadProgress({
    required bool lengthComputable,
    required int loaded,
    required int total,
  }) {
    final upload = object.getProperty<JSObject>('upload'.toJS);
    _fire(
      upload.getProperty<JSFunction?>('onprogress'.toJS),
      web.ProgressEvent(
        'progress',
        web.ProgressEventInit(
          lengthComputable: lengthComputable,
          loaded: loaded,
          total: total,
        ),
      ),
    );
  }

  void fireLoad({required int status, required String responseText}) {
    object.setProperty('status'.toJS, status.toJS);
    object.setProperty('responseText'.toJS, responseText.toJS);
    _fire(object.getProperty<JSFunction?>('onload'.toJS), web.Event('load'));
  }

  void fireError() =>
      _fire(object.getProperty<JSFunction?>('onerror'.toJS), web.Event('error'));

  void fireAbort() =>
      _fire(object.getProperty<JSFunction?>('onabort'.toJS), web.Event('abort'));

  void _fire(JSFunction? handler, web.Event event) {
    expect(handler, isNotNull, reason: 'the handler was never installed');
    handler!.callAsFunction(object, event as JSAny);
  }
}

/// Overrides the XHR seam so every case here scripts the request rather than
/// reaching the network.
class _TestOpfsXhrUpload extends OpfsXhrUpload {
  _TestOpfsXhrUpload(this.fake);

  final _FakeXhr fake;

  @override
  web.XMLHttpRequest createXhr() => fake.xhr;
}

web.File _fakeFile() => web.File(<web.BlobPart>[].toJS, 'hello.txt');

XhrUploadFileRequest _request({
  String? mimeType = 'text/plain',
  void Function(int, int)? onUploadProgress,
}) =>
    XhrUploadFileRequest(
      file: _fakeFile(),
      uploadUri: Uri.parse('https://jmap.example/upload'),
      authHeader: 'Bearer token',
      mimeType: mimeType,
      onUploadProgress: onUploadProgress ?? (_, __) {},
    );

Matcher _isDioException(DioExceptionType type) =>
    isA<DioException>().having((e) => e.type, 'type', type);

/// Runs an upload with a progress collector and fires one `upload.onprogress`,
/// returning the `[loaded, total]` pairs the request saw.
List<List<int>> _progressFromEvent({
  required bool lengthComputable,
  required int loaded,
  required int total,
}) {
  final fake = _FakeXhr();
  final progress = <List<int>>[];

  _TestOpfsXhrUpload(fake)
      .uploadFile(_request(onUploadProgress: (a, b) => progress.add([a, b])));
  fake.fireUploadProgress(
    lengthComputable: lengthComputable,
    loaded: loaded,
    total: total,
  );

  return progress;
}

/// Runs an upload and fires `onload` with [status]/[responseText], returning
/// the handle's future so the caller can assert on how it settles.
Future<Map<String, dynamic>> _responseAfterLoad({
  required int status,
  required String responseText,
}) {
  final fake = _FakeXhr();

  final handle = _TestOpfsXhrUpload(fake).uploadFile(_request());
  fake.fireLoad(status: status, responseText: responseText);

  return handle.response;
}

void main() {
  group('OpfsXhrUpload.uploadFile headers', () {
    test('sends the auth, JMAP accept and content-type headers', () {
      final fake = _FakeXhr();

      _TestOpfsXhrUpload(fake).uploadFile(_request());

      expect(fake.openArgs, ['POST', 'https://jmap.example/upload']);
      expect(fake.headers['Authorization'], 'Bearer token');
      expect(fake.headers['Accept'], DioClient.jmapHeader);
      expect(fake.headers['Content-Type'], 'text/plain');
      expect(fake.sendCount, 1);
    });

    test('omits content-type when the staged file has no mime type', () {
      final fake = _FakeXhr();

      _TestOpfsXhrUpload(fake).uploadFile(_request(mimeType: null));

      expect(fake.headers.containsKey('Content-Type'), isFalse);
      expect(fake.headers['Accept'], DioClient.jmapHeader);
    });

    test('omits content-type when the mime type is empty', () {
      final fake = _FakeXhr();

      _TestOpfsXhrUpload(fake).uploadFile(_request(mimeType: ''));

      expect(fake.headers.containsKey('Content-Type'), isFalse);
    });
  });

  group('OpfsXhrUpload.uploadFile progress', () {
    test('forwards the total when the length is computable', () {
      expect(
        _progressFromEvent(lengthComputable: true, loaded: 5, total: 10),
        [
          [5, 10]
        ],
      );
    });

    // -1, not the 0 the browser reports: the download leg's unknown-total
    // sentinel, so one consumer serves both legs.
    test('reports an unknown total as -1', () {
      expect(
        _progressFromEvent(lengthComputable: false, loaded: 5, total: 0),
        [
          [5, -1]
        ],
      );
    });
  });

  group('OpfsXhrUpload.uploadFile response', () {
    test('resolves with the parsed body on a 2xx', () async {
      final response = _responseAfterLoad(
          status: 201, responseText: '{"blobId":"blob-1","size":42}');

      expect(await response, {'blobId': 'blob-1', 'size': 42});
    });

    test('fails with badResponse when a 2xx body is not JSON', () async {
      final response = _responseAfterLoad(
          status: 200, responseText: '<html>nope</html>');

      await expectLater(
        response,
        throwsA(isA<DioException>()
            .having((e) => e.type, 'type', DioExceptionType.badResponse)
            .having((e) => e.message, 'message',
                contains('could not be parsed'))),
      );
    });

    test('fails with badResponse and the status on a non-2xx', () async {
      final response = _responseAfterLoad(status: 413, responseText: '');

      await expectLater(
        response,
        throwsA(isA<DioException>()
            .having((e) => e.type, 'type', DioExceptionType.badResponse)
            .having((e) => e.response?.statusCode, 'statusCode', 413)),
      );
    });

    test('keeps the first outcome when a late event arrives', () async {
      final fake = _FakeXhr();

      final handle = _TestOpfsXhrUpload(fake).uploadFile(_request());
      fake.fireLoad(status: 200, responseText: '{"blobId":"blob-1"}');
      fake.fireError();

      expect(await handle.response, {'blobId': 'blob-1'});
    });
  });

  group('OpfsXhrUpload.uploadFile failures', () {
    test('maps onerror to a connection error', () async {
      final fake = _FakeXhr();

      final handle = _TestOpfsXhrUpload(fake).uploadFile(_request());
      fake.fireError();

      await expectLater(handle.response,
          throwsA(_isDioException(DioExceptionType.connectionError)));
    });

    test('maps onabort to a cancellation', () async {
      final fake = _FakeXhr();

      final handle = _TestOpfsXhrUpload(fake).uploadFile(_request());
      fake.fireAbort();

      await expectLater(
          handle.response, throwsA(_isDioException(DioExceptionType.cancel)));
    });

    test('abort() on the handle aborts the request', () {
      final fake = _FakeXhr();

      _TestOpfsXhrUpload(fake).uploadFile(_request()).abort();

      expect(fake.abortCount, 1);
    });

    test('surfaces a throwing open as a DioException, not a raw error',
        () async {
      final fake = _FakeXhr()..throwOnOpen = true;

      final handle = _TestOpfsXhrUpload(fake).uploadFile(_request());

      await expectLater(handle.response,
          throwsA(_isDioException(DioExceptionType.connectionError)));
      expect(fake.sendCount, 0);
    });

    test('surfaces a throwing setRequestHeader as a DioException', () async {
      final fake = _FakeXhr()..throwOnSetRequestHeader = true;

      final handle = _TestOpfsXhrUpload(fake).uploadFile(_request());

      await expectLater(handle.response,
          throwsA(_isDioException(DioExceptionType.connectionError)));
      expect(fake.sendCount, 0);
    });

    test('surfaces a throwing send as a DioException', () async {
      final fake = _FakeXhr()..throwOnSend = true;

      final handle = _TestOpfsXhrUpload(fake).uploadFile(_request());

      await expectLater(handle.response,
          throwsA(_isDioException(DioExceptionType.connectionError)));
    });
  });
}
