@TestOn('chrome')
library;

import 'dart:js_interop';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;
import 'package:workplace/data/datasource/drive_transfer/opfs_fetch_download.dart';

/// A real `blob:` URL, so the 200 cases go through the browser's own `fetch`
/// rather than a stubbed response.
Uri _blobUrl(String content) {
  final blob = web.Blob(<web.BlobPart>[content.toJS].toJS);
  final url = web.URL.createObjectURL(blob);
  addTearDown(() => web.URL.revokeObjectURL(url));
  return Uri.parse(url);
}

/// The header-side shapes no fixture the test server can serve produces: a
/// response with no body at all, and one that declares no length.
web.Response _response(String? body, {int status = 200, JSObject? headers}) =>
    web.Response(
      body?.toJS,
      web.ResponseInit(
        status: status,
        headers: headers ?? JSObject(),
      ),
    );

void main() {
  test('reads content-length off the response headers', () async {
    const content = 'hello opfs';
    final download = OpfsFetchDownload();

    final handle = await download.openDownload(_blobUrl(content));
    addTearDown(() => download.cancelReader(handle.reader));

    expect(handle.contentLength, content.length);
  });

  test('maps a non-2xx download response to a badResponse carrying the status',
      () async {
    // Resolved against the test server's own origin: nothing serves this path,
    // so the server answers 404.
    await expectLater(
      OpfsFetchDownload().openDownload(Uri.parse('no-such-drive-fixture.bin')),
      throwsA(isA<DioException>()
          .having((e) => e.type, 'type', DioExceptionType.badResponse)
          .having((e) => e.response?.statusCode, 'statusCode', 404)),
    );
  });

  test('maps a response with no body to a connection error', () async {
    // 204 is the shape a body is absent for; `getReader()` on it would throw a
    // bare browser error rather than anything a caller can branch on.
    expect(
      () => OpfsFetchDownload().handleFromResponse(
        _response(null, status: 204),
        RequestOptions(path: 'https://drive.example/empty'),
      ),
      throwsA(isA<DioException>()
          .having((e) => e.type, 'type', DioExceptionType.connectionError)),
    );
  });

  test('reports an absent or unparseable content-length as -1', () async {
    // -1 is the "unknown total" progress reports carry; a chunked response
    // declares no length, and a value that isn't a number is no better.
    final download = OpfsFetchDownload();
    final requestOptions = RequestOptions(path: 'https://drive.example/chunked');

    final absent = download.handleFromResponse(_response('abc'), requestOptions);
    addTearDown(() => download.cancelReader(absent.reader));
    expect(absent.contentLength, -1);

    final unparseable = download.handleFromResponse(
      _response('abc',
          headers: {'content-length': 'not-a-number'}.jsify() as JSObject),
      requestOptions,
    );
    addTearDown(() => download.cancelReader(unparseable.reader));
    expect(unparseable.contentLength, -1);
  });

  test('maps a cancel landing before the headers to a cancellation', () async {
    // An already-resolved signal aborts in a microtask, ahead of any fetch
    // resolution — so the abort lands while the request is still pre-headers,
    // where it rejects the fetch itself and is indistinguishable from a
    // transport failure but for the flag `openDownload` keeps.
    await expectLater(
      OpfsFetchDownload().openDownload(
        _blobUrl('hello opfs'),
        cancelSignal: Future<void>.value(),
      ),
      throwsA(isA<DioException>()
          .having((e) => e.type, 'type', DioExceptionType.cancel)),
    );
  });
}
