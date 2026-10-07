import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/datasource_impl/workplace_drive_datasource_impl.dart';
import 'package:workplace/data/datasource_impl/workplace_request_executor.dart';
import 'package:workplace/data/model/workplace_file_response.dart';
import 'package:workplace/data/workplace_dio.dart';
import 'package:workplace/domain/entity/workplace_access_mode.dart';
import 'package:workplace/domain/entity/workplace_upload_file_spec.dart';
import 'package:workplace/domain/entity/workplace_upload_source.dart';
import 'package:workplace/domain/entity/workplace_upload_transfer.dart';

/// Queue item for a failure that carries no HTTP response.
const _connectionError = Object();

/// Queue item for a response body sent as-is under [contentType].
class _RawResponse {
  final String body;
  final String contentType;

  const _RawResponse(this.body, this.contentType);
}

/// Opens a fresh body per read, like the app's `UploadBody`.
class _FakeUploadSource implements WorkplaceUploadSource {
  final Object? Function() _open;
  int reads = 0;

  @override
  final Map<String, dynamic> dioExtra;

  _FakeUploadSource({Object? Function()? open, this.dioExtra = const {}})
      : _open = open ?? (() => 'bytes');

  @override
  Object? get requestData {
    reads++;
    return _open();
  }
}

/// Captures the last request, returns a queued response per call.
class _QueueAdapter implements HttpClientAdapter {
  final List<dynamic> queue;
  final List<RequestOptions> capturedOptions = [];

  _QueueAdapter(this.queue);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future? cancelFuture,
  ) async {
    capturedOptions.add(options);
    final item = queue[capturedOptions.length - 1];
    if (identical(item, _connectionError)) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'unreachable',
      );
    }
    if (item is int) {
      throw DioException(
        requestOptions: options,
        response: Response(statusCode: item, requestOptions: options),
        type: DioExceptionType.badResponse,
      );
    }
    if (item is _RawResponse) {
      return ResponseBody.fromString(
        item.body,
        200,
        headers: {
          Headers.contentTypeHeader: [item.contentType],
        },
      );
    }
    return ResponseBody.fromString(
      jsonEncode(item),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json; charset=utf-8'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Records every route it is asked to send and answers with an uploaded file.
class _RecordingExecutor implements WorkplaceRequestExecutor {
  final List<WorkplaceRequestRoute> routes = [];
  final List<WorkplaceRequestTransfer> transfers = [];

  @override
  Future<dynamic> send({
    required WorkplaceRequestContext context,
    required WorkplaceRequestRoute route,
    WorkplaceRequestBody body = const WorkplaceRequestBody(),
    WorkplaceRequestTransfer transfer = const WorkplaceRequestTransfer(),
  }) async {
    routes.add(route);
    transfers.add(transfer);
    return {
      'data': {'id': 'file-1'},
    };
  }
}

/// Uploads [fileName] against a 409 then a success; returns the retried name.
Future<String?> _retriedName(
  WorkplaceDriveDataSourceImpl datasource,
  WorkplaceRequestContext context,
  String fileName,
) async {
  final adapter = _QueueAdapter([
    409,
    {
      'data': {'id': 'file-1'},
    },
  ]);
  WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);
  await datasource.uploadFile(
    context: context,
    spec: WorkplaceUploadFileSpec(
      fileName: fileName,
      mimeType: 'application/octet-stream',
      fileSize: 1,
      source: _FakeUploadSource(),
    ),
  );
  return adapter.capturedOptions[1].uri.queryParameters['Name'];
}

void main() {
  late WorkplaceDriveDataSourceImpl datasource;
  late Dio originalDio;
  final context = WorkplaceRequestContext(
    platformUrl: Uri.parse('https://platform.example.com'),
    accessMode: const BearerTokenAccessMode('test-token'),
  );
  final spec = WorkplaceUploadFileSpec(
    fileName: 'report.pdf',
    mimeType: 'application/pdf',
    fileSize: 1234,
    source: _FakeUploadSource(),
  );

  final fileResponse = {
    'data': {
      'id': 'file-1',
      'attributes': {'name': 'report.pdf'},
    },
  };

  setUp(() {
    datasource = WorkplaceDriveDataSourceImpl();
    originalDio = WorkplaceDio.instance;
  });

  tearDown(() => WorkplaceDio.setInstance(originalDio));

  group('WorkplaceDriveDataSourceImpl::uploadFile::', () {
    test('sends Type/Name query params, the magic-folder dir-id in the path, and the mimeType/size headers', () async {
      final adapter = _QueueAdapter([fileResponse]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      final result = await datasource.uploadFile(context: context, spec: spec);

      final options = adapter.capturedOptions.single;
      expect(options.uri.queryParameters['Type'], equals('file'));
      expect(options.uri.queryParameters['Name'], equals('report.pdf'));
      expect(options.uri.queryParameters.containsKey('MagicFolder'), isFalse);
      expect(options.uri.path, equals('/files/io.cozy.apps%2Fmail'));
      expect(options.headers['Content-Type'], equals('application/pdf'));
      // Content-Length isn't asserted here: Dio recomputes it from the
      // serialized body for a String payload, overriding our explicit header
      // (which only matters in production for a Stream body Dio can't size).
      expect(result.fileId, equals('file-1'));
      expect(result.name, equals('report.pdf'));
    });

    test('sends the spec size as Content-Length for a streamed body Dio cannot size', () async {
      final adapter = _QueueAdapter([fileResponse]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);
      final streamSpec = WorkplaceUploadFileSpec(
        fileName: 'report.pdf',
        mimeType: 'application/pdf',
        fileSize: 1234,
        source: _FakeUploadSource(
          open: () => Stream<List<int>>.fromIterable([
            [1, 2, 3],
          ]),
        ),
      );

      await datasource.uploadFile(context: context, spec: streamSpec);

      expect(
        adapter.capturedOptions.single.headers[Headers.contentLengthHeader],
        equals('1234'),
      );
    });

    test('sends force_session_id=true so cozy-stack accepts the bearer-only request', () async {
      final adapter = _QueueAdapter([fileResponse]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      await datasource.uploadFile(context: context, spec: spec);

      expect(
        adapter.capturedOptions.single.uri.queryParameters['force_session_id'],
        equals('true'),
      );
    });

    test('retries with a suffixed name on a 409 name conflict', () async {
      final adapter = _QueueAdapter([409, fileResponse]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      await datasource.uploadFile(context: context, spec: spec);

      expect(adapter.capturedOptions, hasLength(2));
      expect(adapter.capturedOptions[0].uri.queryParameters['Name'], equals('report.pdf'));
      expect(adapter.capturedOptions[1].uri.queryParameters['Name'], equals('report (1).pdf'));
    });

    test('keeps incrementing the suffix while the name is taken', () async {
      final adapter = _QueueAdapter([409, 409, fileResponse]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      await datasource.uploadFile(context: context, spec: spec);

      expect(
        adapter.capturedOptions.map((o) => o.uri.queryParameters['Name']),
        ['report.pdf', 'report (1).pdf', 'report (2).pdf'],
      );
    });

    test('rethrows the 409 once every name attempt is taken', () async {
      final adapter = _QueueAdapter(List.filled(10, 409));
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      await expectLater(
        datasource.uploadFile(context: context, spec: spec),
        throwsA(isA<DioException>()),
      );
      expect(adapter.capturedOptions, hasLength(10));
      expect(adapter.capturedOptions.last.uri.queryParameters['Name'], equals('report (9).pdf'));
    });

    test('reads a fresh body for the 409 retry', () async {
      final adapter = _QueueAdapter([409, fileResponse]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);
      final source = _FakeUploadSource(
        open: () => Stream<List<int>>.fromIterable([
          [1, 2, 3],
        ]),
      );

      await datasource.uploadFile(
        context: context,
        spec: WorkplaceUploadFileSpec(
          fileName: 'report.pdf',
          mimeType: 'application/pdf',
          fileSize: 3,
          source: source,
        ),
      );

      expect(source.reads, equals(2));
    });

    test('suffixes an extension-less name by appending (1)', () async {
      final adapter = _QueueAdapter([409, fileResponse]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);
      final noExtSpec = WorkplaceUploadFileSpec(
        fileName: 'report',
        mimeType: 'application/pdf',
        fileSize: 1234,
        source: _FakeUploadSource(),
      );

      await datasource.uploadFile(context: context, spec: noExtSpec);

      expect(adapter.capturedOptions[1].uri.queryParameters['Name'], equals('report (1)'));
    });

    test('suffixes a dot-leading name like an extension-less one', () async {
      expect(await _retriedName(datasource, context, '.env'), equals('.env (1)'));
    });

    test('suffixes a multi-dot name before its last extension only', () async {
      expect(
        await _retriedName(datasource, context, 'archive.tar.gz'),
        equals('archive.tar (1).gz'),
      );
    });

    test('rethrows a non-409 failure without retrying', () async {
      final adapter = _QueueAdapter([500]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      await expectLater(
        datasource.uploadFile(context: context, spec: spec),
        throwsA(isA<DioException>()),
      );
      expect(adapter.capturedOptions, hasLength(1));
    });

    test('rethrows a failure without a response without retrying', () async {
      final adapter = _QueueAdapter([_connectionError]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      await expectLater(
        datasource.uploadFile(context: context, spec: spec),
        throwsA(isA<DioException>().having(
          (exception) => exception.type,
          'type',
          DioExceptionType.connectionError,
        )),
      );
      expect(adapter.capturedOptions, hasLength(1));
    });

    test('throws StateError when the response carries no file id', () async {
      final adapter = _QueueAdapter([
        {
          'data': {'id': '', 'attributes': {'name': 'x'}},
        },
      ]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      await expectLater(
        datasource.uploadFile(context: context, spec: spec),
        throwsA(isA<StateError>()),
      );
    });

    test('returns an empty name when the response carries no attributes', () async {
      final adapter = _QueueAdapter([
        {
          'data': {'id': 'file-1'},
        },
      ]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      final result = await datasource.uploadFile(context: context, spec: spec);

      expect(result.fileId, equals('file-1'));
      expect(result.name, isEmpty);
    });

    test('parses a JSON object the stack returns as a plain-text string', () async {
      final adapter = _QueueAdapter([
        _RawResponse(jsonEncode(fileResponse), 'text/plain'),
      ]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      final result = await datasource.uploadFile(context: context, spec: spec);

      expect(result.fileId, equals('file-1'));
      expect(result.name, equals('report.pdf'));
    });

    test('throws FormatException when the response is not a JSON object', () async {
      final adapter = _QueueAdapter([
        const _RawResponse('[]', 'application/json'),
      ]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      await expectLater(
        datasource.uploadFile(context: context, spec: spec),
        throwsA(isA<FormatException>()),
      );
    });

    test('forwards the source extra verbatim so the web blob adapter sees it', () async {
      final adapter = _QueueAdapter([fileResponse]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);
      final blobSpec = WorkplaceUploadFileSpec(
        fileName: 'report.pdf',
        mimeType: 'application/pdf',
        fileSize: 1234,
        source: _FakeUploadSource(dioExtra: {
          'upload-attachment': {'sourceUrl': 'blob:x'},
        }),
      );

      await datasource.uploadFile(context: context, spec: blobSpec);

      final uploadExtra =
          adapter.capturedOptions.single.extra['upload-attachment'] as Map;
      expect(uploadExtra['sourceUrl'], equals('blob:x'));
    });

    test('applies the transfer timeout, which defaults to the Dio instance', () async {
      final adapter = _QueueAdapter([fileResponse, fileResponse]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);
      const timeout = Duration(minutes: 30);

      await datasource.uploadFile(
        context: context,
        spec: spec,
        transfer: const WorkplaceUploadTransfer(timeout: timeout),
      );
      await datasource.uploadFile(context: context, spec: spec);

      expect(adapter.capturedOptions[0].sendTimeout, equals(timeout));
      expect(adapter.capturedOptions[0].receiveTimeout, equals(timeout));
      expect(adapter.capturedOptions[1].sendTimeout, isNull);
      expect(adapter.capturedOptions[1].receiveTimeout, isNull);
    });

    test('sends the upload through the injected executor', () async {
      final executor = _RecordingExecutor();

      await WorkplaceDriveDataSourceImpl(executor: executor)
          .uploadFile(context: context, spec: spec);

      final route = executor.routes.single;
      expect(route.method, equals('POST'));
      expect(route.pathSegments, equals(['files', 'io.cozy.apps/mail']));
    });

    test('maps the domain transfer onto the request transfer', () async {
      final executor = _RecordingExecutor();
      final cancel = Completer<void>();
      void onProgress(int sent, int total) {}

      await WorkplaceDriveDataSourceImpl(executor: executor).uploadFile(
        context: context,
        spec: spec,
        transfer: WorkplaceUploadTransfer(
          onProgress: onProgress,
          cancelSignal: cancel.future,
          timeout: const Duration(minutes: 30),
        ),
      );
      final sent = executor.transfers.single;
      expect(sent.onSendProgress, same(onProgress));
      expect(sent.timeout, equals(const Duration(minutes: 30)));
      expect(sent.cancelToken!.isCancelled, isFalse);

      cancel.complete();
      await Future<void>.delayed(Duration.zero);
      expect(sent.cancelToken!.isCancelled, isTrue);
    });

    test('cancels the request when the cancel signal fails', () async {
      final executor = _RecordingExecutor();
      final cancel = Completer<void>();

      await WorkplaceDriveDataSourceImpl(executor: executor).uploadFile(
        context: context,
        spec: spec,
        transfer: WorkplaceUploadTransfer(cancelSignal: cancel.future),
      );
      cancel.completeError(StateError('signal failed'));
      await Future<void>.delayed(Duration.zero);

      expect(executor.transfers.single.cancelToken!.isCancelled, isTrue);
    });

    test('sends no cancel token without a cancel signal', () async {
      final executor = _RecordingExecutor();

      await WorkplaceDriveDataSourceImpl(executor: executor)
          .uploadFile(context: context, spec: spec);

      expect(executor.transfers.single.cancelToken, isNull);
    });

    test('WorkplaceFileResponse.fromJson parses a real stack payload', () {
      final parsed = WorkplaceFileResponse.fromJson(fileResponse);
      expect(parsed.data.id, equals('file-1'));
      expect(parsed.data.attributes?.name, equals('report.pdf'));
    });
  });
}
