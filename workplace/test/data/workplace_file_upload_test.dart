import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/datasource_impl/workplace_datasource_impl.dart';
import 'package:workplace/data/model/workplace_file_response.dart';
import 'package:workplace/data/workplace_dio.dart';
import 'package:workplace/domain/entity/workplace_access_mode.dart';
import 'package:workplace/domain/entity/workplace_request_context.dart';
import 'package:workplace/data/model/workplace_request_transfer.dart';
import 'package:workplace/domain/entity/workplace_upload_file_spec.dart';
import 'package:workplace/domain/entity/workplace_upload_source.dart';

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
    if (item is int) {
      throw DioException(
        requestOptions: options,
        response: Response(statusCode: item, requestOptions: options),
        type: DioExceptionType.badResponse,
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

/// Uploads [fileName] against a 409 then a success; returns the retried name.
Future<String?> _retriedName(
  WorkplaceDataSourceImpl datasource,
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
      source: const WorkplaceUploadSource(requestData: 'bytes'),
    ),
  );
  return adapter.capturedOptions[1].uri.queryParameters['Name'];
}

void main() {
  late WorkplaceDataSourceImpl datasource;
  late Dio originalDio;
  final context = WorkplaceRequestContext(
    platformUrl: Uri.parse('https://platform.example.com'),
    accessMode: const BearerTokenAccessMode('test-token'),
  );
  const spec = WorkplaceUploadFileSpec(
    fileName: 'report.pdf',
    mimeType: 'application/pdf',
    fileSize: 1234,
    source: WorkplaceUploadSource(requestData: 'bytes'),
  );

  final fileResponse = {
    'data': {
      'id': 'file-1',
      'attributes': {'name': 'report.pdf'},
    },
  };

  setUp(() {
    datasource = WorkplaceDataSourceImpl();
    originalDio = WorkplaceDio.instance;
  });

  tearDown(() => WorkplaceDio.setInstance(originalDio));

  group('WorkplaceDataSourceImpl::uploadFile::', () {
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
        source: WorkplaceUploadSource(
          requestData: Stream<List<int>>.fromIterable([
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

    test('retries once with a suffixed name on a 409 name conflict', () async {
      final adapter = _QueueAdapter([409, fileResponse]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      await datasource.uploadFile(context: context, spec: spec);

      expect(adapter.capturedOptions, hasLength(2));
      expect(adapter.capturedOptions[0].uri.queryParameters['Name'], equals('report.pdf'));
      expect(adapter.capturedOptions[1].uri.queryParameters['Name'], equals('report (1).pdf'));
    });

    test('suffixes an extension-less name by appending (1)', () async {
      final adapter = _QueueAdapter([409, fileResponse]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);
      const noExtSpec = WorkplaceUploadFileSpec(
        fileName: 'report',
        mimeType: 'application/pdf',
        fileSize: 1234,
        source: WorkplaceUploadSource(requestData: 'bytes'),
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

    test('forwards the source extra verbatim so the web blob adapter sees it', () async {
      final adapter = _QueueAdapter([fileResponse]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);
      const blobSpec = WorkplaceUploadFileSpec(
        fileName: 'report.pdf',
        mimeType: 'application/pdf',
        fileSize: 1234,
        source: WorkplaceUploadSource(requestExtra: {
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
        transfer: const WorkplaceRequestTransfer(timeout: timeout),
      );
      await datasource.uploadFile(context: context, spec: spec);

      expect(adapter.capturedOptions[0].sendTimeout, equals(timeout));
      expect(adapter.capturedOptions[0].receiveTimeout, equals(timeout));
      expect(adapter.capturedOptions[1].sendTimeout, isNull);
      expect(adapter.capturedOptions[1].receiveTimeout, isNull);
    });

    test('WorkplaceFileResponse.fromJson parses a real stack payload', () {
      final parsed = WorkplaceFileResponse.fromJson(fileResponse);
      expect(parsed.data.id, equals('file-1'));
      expect(parsed.data.attributes?.name, equals('report.pdf'));
    });
  });
}
