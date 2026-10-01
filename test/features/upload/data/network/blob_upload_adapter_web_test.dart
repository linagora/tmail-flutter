@TestOn('chrome')
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/upload/data/network/blob_upload_adapter_web.dart';
import 'package:tmail_ui_user/features/upload/data/network/upload_request_extra.dart';
import 'package:web/web.dart' as web;

/// A real HTTP server in the test VM, so every case goes through a real
/// `XMLHttpRequest` and the byte counts come from what actually arrived.
const _serverSource = r'''
import 'dart:convert';
import 'dart:io';

/// Upload state per `?id=`, so a test can tell whether the browser really
/// stopped sending: `reading`, then `done` or `aborted`.
final uploadStates = <String, String>{};

Future<void> hybridMain(dynamic channel) async {
  final server = await HttpServer.bind('localhost', 0);
  // A client that aborts mid-upload makes reading or replying throw; that
  // must not take the server down for the tests that follow.
  server.listen((request) => handle(request).catchError((_) {}));
  channel.sink.add(server.port);
}

Future<void> handle(HttpRequest request) async {
  final response = request.response;
  response.headers
    ..set('Access-Control-Allow-Origin', '*')
    ..set('Access-Control-Allow-Methods', 'POST, OPTIONS')
    ..set('Access-Control-Allow-Headers',
        request.headers.value('access-control-request-headers') ?? '*');
  final path = request.uri.path;
  if (request.method == 'OPTIONS') {
    if (path == '/stalled-preflight') {
      await Future<void>.delayed(const Duration(seconds: 5));
    }
    await response.close();
    return;
  }
  if (path == '/upload-state') {
    response.write(uploadStates[request.uri.queryParameters['id']]);
    await response.close();
    return;
  }

  final uploadId = request.uri.queryParameters['id'];
  if (uploadId != null) uploadStates[uploadId] = 'reading';
  var received = 0;
  try {
    await for (final chunk in request) {
      received += chunk.length;
      if (path == '/slow-read') {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    }
  } catch (_) {
    if (uploadId != null) uploadStates[uploadId] = 'aborted';
    rethrow;
  }
  if (uploadId != null) uploadStates[uploadId] = 'done';
  if (path == '/delay') {
    await Future<void>.delayed(const Duration(seconds: 2));
  }
  if (path == '/hang') {
    await Future<void>.delayed(const Duration(seconds: 10));
  }

  response.statusCode = switch (path) {
    '/status/401' => 401,
    '/status/413' => 413,
    _ => 200,
  };
  response.headers.contentType = ContentType.json;
  response.write(jsonEncode({
    'size': received,
    'contentType': request.headers.value('content-type'),
    'contentLength': request.headers.contentLength,
    'authorization': request.headers.value('authorization'),
  }));
  await response.close();
}
''';

/// Records which requests reach the wrapped adapter, so a test can tell the
/// blob path from the fall-through path.
class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this._inner);

  final HttpClientAdapter _inner;
  final fetchedPaths = <String>[];
  bool? closedWithForce;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    fetchedPaths.add(options.uri.path);
    return _inner.fetch(options, requestStream, cancelFuture);
  }

  @override
  void close({bool force = false}) {
    closedWithForce = force;
    _inner.close(force: force);
  }
}

TypeMatcher<DioException> _dioError(DioExceptionType type) =>
    isA<DioException>().having((e) => e.type, 'type', type);

void main() {
  const oneMegabyte = 1024 * 1024;
  const pdfMimeType = 'application/pdf';

  late String serverUrl;
  late Dio dio;
  late _RecordingAdapter inner;
  final createdUrls = <String>[];

  setUpAll(() async {
    final channel = spawnHybridCode(_serverSource);
    serverUrl = 'http://localhost:${await channel.stream.first}';
  });

  setUp(() {
    dio = Dio();
    inner = _RecordingAdapter(dio.httpClientAdapter);
    dio.httpClientAdapter = inner;
    installBlobUploadAdapter(dio);
  });

  tearDown(() {
    for (final url in createdUrls) {
      web.URL.revokeObjectURL(url);
    }
    createdUrls.clear();
  });

  /// Builds a browser-owned blob from one repeated 1 MB chunk, so a large
  /// upload never holds its full size in Dart.
  String createBlobUrl(int size) {
    final chunk = Uint8List(size < oneMegabyte ? size : oneMegabyte).toJS;
    final parts = List<JSAny>.filled(
      size < oneMegabyte ? 1 : size ~/ oneMegabyte,
      chunk,
    );
    final blob = web.Blob(parts.toJS, web.BlobPropertyBag(type: pdfMimeType));
    final url = web.URL.createObjectURL(blob);
    createdUrls.add(url);
    return url;
  }

  /// Waits until the server reports [expected] for the upload with [id]:
  /// `reading` once its body started arriving, `aborted` once cut off mid-body.
  Future<void> waitForUploadState(String id, String expected) async {
    final stateDio = Dio();
    String? state;
    for (var attempt = 0; attempt < 30; attempt++) {
      final response = await stateDio.get<String>(
        '$serverUrl/upload-state',
        queryParameters: {'id': id},
      );
      state = response.data;
      if (state == expected) return;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    fail('Upload $id never reached $expected, last state: $state');
  }

  Options blobUploadOptions(String blobUrl, {Map<String, dynamic>? headers}) =>
      Options(
        headers: {'Content-Type': pdfMimeType, ...?headers},
        extra: {
          UploadRequestExtra.uploadAttachmentKey: {
            UploadRequestExtra.sourceUrlKey: blobUrl,
          },
        },
      );

  group('BlobUploadAdapter::fetch', () {
    test(
      'Given a 5 MB blob URL in upload extra, '
      'When the upload is posted, '
      'Should send every byte with its Content-Type and report send progress up to 5 MB',
      () async {
        const size = 5 * oneMegabyte;
        final sentProgress = <(int, int)>[];

        final response = await dio.post(
          '$serverUrl/echo',
          options: blobUploadOptions(createBlobUrl(size)),
          onSendProgress: (sent, total) => sentProgress.add((sent, total)),
        );

        expect(response.statusCode, 200);
        expect(response.data['size'], size);
        expect(response.data['contentType'], pdfMimeType);
        expect(sentProgress, isNotEmpty);
        expect(sentProgress.last, (size, size));
        expect(inner.fetchedPaths, isEmpty);
      },
    );

    test('Given a request without sourceUrl in extra, '
        'When it is posted, '
        'Should go through the wrapped adapter unchanged', () async {
      final response = await dio.post(
        '$serverUrl/echo',
        data: {'key': 'value'},
      );

      expect(response.statusCode, 200);
      expect(response.data['size'], greaterThan(0));
      expect(inner.fetchedPaths, ['/echo']);
    });

    test('Given request headers with Authorization and a wrong Content-Length, '
        'When the upload is posted, '
        'Should forward Authorization and send the real blob length', () async {
      const size = 2048;

      final response = await dio.post(
        '$serverUrl/echo',
        options: blobUploadOptions(
          createBlobUrl(size),
          headers: {
            'Authorization': 'Bearer test-token',
            Headers.contentLengthHeader: 1,
          },
        ),
      );

      expect(response.data['authorization'], 'Bearer test-token');
      expect(response.data['contentLength'], size);
      expect(response.data['size'], size);
    });

    test('Given onReceiveProgress is set and a streamed response, '
        'When the server replies to a blob upload, '
        'Should report receive progress up to the reply size', () async {
      // A streamed response skips Dio's transformer, which reports receive
      // progress on its own, so only the adapter can produce these events.
      final receivedProgress = <int>[];

      final response = await dio.post<ResponseBody>(
        '$serverUrl/echo',
        options: blobUploadOptions(createBlobUrl(1024))
          ..responseType = ResponseType.stream,
        onReceiveProgress: (received, _) => receivedProgress.add(received),
      );
      final replySize = await response.data!.stream.fold<int>(
        0,
        (size, chunk) => size + chunk.length,
      );

      expect(receivedProgress, isNotEmpty);
      expect(receivedProgress.last, replySize);
    });

    test(
      'Given the same blob URL, '
      'When the upload is sent twice, '
      'Should resolve the blob again and send the full size both times',
      () async {
        final options = blobUploadOptions(createBlobUrl(4096));

        final first = await dio.post('$serverUrl/echo', options: options);
        final second = await dio.post('$serverUrl/echo', options: options);

        expect(first.data['size'], 4096);
        expect(second.data['size'], 4096);
      },
    );
  });

  group('BlobUploadAdapter::fetch errors', () {
    test('Given a revoked blob URL, '
        'When the upload is posted, '
        'Should throw connectionError that keeps the original cause', () async {
      final blobUrl = createBlobUrl(16);
      web.URL.revokeObjectURL(blobUrl);

      await expectLater(
        dio.post('$serverUrl/echo', options: blobUploadOptions(blobUrl)),
        throwsA(
          _dioError(
            DioExceptionType.connectionError,
          ).having((e) => e.error, 'error', isNotNull),
        ),
      );
    });

    test(
      'Given the server answers 401, '
      'When the upload is posted, '
      'Should throw badResponse with status 401 so the auth interceptor can replay',
      () async {
        await expectLater(
          dio.post(
            '$serverUrl/status/401',
            options: blobUploadOptions(createBlobUrl(16)),
          ),
          throwsA(
            _dioError(
              DioExceptionType.badResponse,
            ).having((e) => e.response?.statusCode, 'statusCode', 401),
          ),
        );
      },
    );

    test('Given the server rejects the size with 413, '
        'When the upload is posted, '
        'Should throw badResponse with status 413', () async {
      await expectLater(
        dio.post(
          '$serverUrl/status/413',
          options: blobUploadOptions(createBlobUrl(16)),
        ),
        throwsA(
          _dioError(
            DioExceptionType.badResponse,
          ).having((e) => e.response?.statusCode, 'statusCode', 413),
        ),
      );
    });

    test('Given an unreachable server, '
        'When the upload is posted, '
        'Should throw connectionError', () async {
      await expectLater(
        dio.post(
          'http://localhost:1/echo',
          options: blobUploadOptions(createBlobUrl(16)),
        ),
        throwsA(_dioError(DioExceptionType.connectionError)),
      );
    });
  });

  group('BlobUploadAdapter::fetch timeouts', () {
    test('Given connect and receive timeouts shorter than the server reply, '
        'When the upload is posted, '
        'Should abort and throw receiveTimeout', () async {
      dio.options
        ..connectTimeout = const Duration(milliseconds: 300)
        ..receiveTimeout = const Duration(milliseconds: 300);

      await expectLater(
        dio.post(
          '$serverUrl/delay',
          options: blobUploadOptions(createBlobUrl(oneMegabyte)),
        ),
        throwsA(_dioError(DioExceptionType.receiveTimeout)),
      );
    });

    test(
      'Given a connectTimeout and a server that never answers the preflight, '
      'When the upload is posted, '
      'Should throw connectionTimeout before any byte is sent',
      () async {
        dio.options
          ..connectTimeout = const Duration(milliseconds: 300)
          ..receiveTimeout = const Duration(seconds: 10);

        await expectLater(
          dio.post(
            '$serverUrl/stalled-preflight',
            options: blobUploadOptions(createBlobUrl(16)),
          ),
          throwsA(_dioError(DioExceptionType.connectionTimeout)),
        );
      },
    );

    test('Given a sendTimeout shorter than a slowly read upload, '
        'When progress events pass it, '
        'Should abort and throw sendTimeout', () async {
      dio.options.sendTimeout = const Duration(milliseconds: 100);

      await expectLater(
        dio.post(
          '$serverUrl/slow-read',
          options: blobUploadOptions(createBlobUrl(64 * oneMegabyte)),
        ),
        throwsA(_dioError(DioExceptionType.sendTimeout)),
      );
    });
  });

  group('BlobUploadAdapter cancel and close', () {
    test('Given a large upload in progress, '
        'When its CancelToken is cancelled, '
        'Should throw cancel and stop sending the body on the wire', () async {
      final cancelToken = CancelToken();
      final upload = dio.post(
        '$serverUrl/slow-read',
        queryParameters: {'id': 'cancel-token'},
        options: blobUploadOptions(createBlobUrl(64 * oneMegabyte)),
        cancelToken: cancelToken,
      );
      await waitForUploadState('cancel-token', 'reading');
      cancelToken.cancel();

      await expectLater(upload, throwsA(_dioError(DioExceptionType.cancel)));
      await waitForUploadState('cancel-token', 'aborted');
    });

    test('Given a CancelToken cancelled before the blob resolves, '
        'When the upload is posted, '
        'Should throw cancel', () async {
      final cancelToken = CancelToken()..cancel();

      await expectLater(
        dio.post(
          '$serverUrl/hang',
          options: blobUploadOptions(createBlobUrl(16)),
          cancelToken: cancelToken,
        ),
        throwsA(_dioError(DioExceptionType.cancel)),
      );
    });

    test(
      'Given a large upload in progress, '
      'When the adapter is closed with force, '
      'Should throw cancel, stop sending the body and force-close the wrapped adapter',
      () async {
        final upload = dio.post(
          '$serverUrl/slow-read',
          queryParameters: {'id': 'force-close'},
          options: blobUploadOptions(createBlobUrl(64 * oneMegabyte)),
        );
        await waitForUploadState('force-close', 'reading');

        dio.httpClientAdapter.close(force: true);

        await expectLater(upload, throwsA(_dioError(DioExceptionType.cancel)));
        await waitForUploadState('force-close', 'aborted');
        expect(inner.closedWithForce, isTrue);
      },
    );

    test('Given the blob is still resolving, '
        'When the adapter is closed with force, '
        'Should throw cancel instead of starting the upload', () async {
      final upload = dio.post(
        '$serverUrl/echo',
        options: blobUploadOptions(createBlobUrl(1024)),
      );

      dio.httpClientAdapter.close(force: true);

      await expectLater(upload, throwsA(_dioError(DioExceptionType.cancel)));
    });
  });

  group('installBlobUploadAdapter', () {
    test('Given the adapter is already installed, '
        'When installBlobUploadAdapter is called again, '
        'Should keep the same adapter instead of wrapping twice', () {
      final installed = dio.httpClientAdapter;

      installBlobUploadAdapter(dio);

      expect(installed, isA<BlobUploadAdapter>());
      expect(identical(dio.httpClientAdapter, installed), isTrue);
    });
  });
}
