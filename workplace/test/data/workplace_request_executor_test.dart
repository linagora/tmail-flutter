import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/datasource_impl/workplace_request_executor.dart';
import 'package:workplace/data/workplace_dio.dart';
import 'package:workplace/domain/entity/workplace_access_mode.dart';

/// Captures the last request and returns an empty JSON object.
class _CaptureAdapter implements HttpClientAdapter {
  RequestOptions? captured;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future? cancelFuture,
  ) async {
    captured = options;
    return ResponseBody.fromString(
      jsonEncode({'ok': true}),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json; charset=utf-8'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  const executor = WorkplaceRequestExecutor();
  late Dio originalDio;
  late _CaptureAdapter adapter;

  WorkplaceRequestContext bearer(String token) => WorkplaceRequestContext(
        platformUrl: Uri.parse('https://platform.example.com/base?lang=fr'),
        accessMode: BearerTokenAccessMode(token),
      );

  setUp(() {
    originalDio = WorkplaceDio.instance;
    adapter = _CaptureAdapter();
    WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);
  });

  tearDown(() => WorkplaceDio.setInstance(originalDio));

  group('WorkplaceRequestExecutor::bearer::', () {
    test('appends encoded segments after the platform path and merges query params', () async {
      await executor.send(
        context: bearer('tok'),
        route: const WorkplaceRequestRoute(
          method: 'POST',
          pathSegments: ['files', 'io.cozy.apps/mail'],
          queryParameters: {'Type': 'file'},
        ),
      );

      final options = adapter.captured!;
      expect(options.method, equals('POST'));
      expect(options.uri.path, equals('/base/files/io.cozy.apps%2Fmail'));
      expect(
        options.uri.queryParameters,
        equals({'lang': 'fr', 'Type': 'file', 'force_session_id': 'true'}),
      );
    });

    test('skips the empty segment of a trailing-slash platform URL', () async {
      await executor.send(
        context: WorkplaceRequestContext(
          platformUrl: Uri.parse('https://platform.example.com/base/'),
          accessMode: const BearerTokenAccessMode('tok'),
        ),
        route: const WorkplaceRequestRoute(method: 'GET', pathSegments: ['apps']),
      );

      expect(adapter.captured!.uri.path, equals('/base/apps'));
    });

    test('sends the bearer token with the body headers and extra', () async {
      await executor.send(
        context: bearer('tok'),
        route: const WorkplaceRequestRoute(method: 'GET', pathSegments: ['apps', 'drive']),
        body: const WorkplaceRequestBody(headers: {'X-Test': '1'}, extra: {'k': 'v'}),
      );

      final options = adapter.captured!;
      expect(options.headers['Authorization'], equals('Bearer tok'));
      expect(options.headers['X-Test'], equals('1'));
      expect(options.extra['k'], equals('v'));
    });

    test('forwards the send progress, cancel token and timeout', () async {
      void onSendProgress(int sent, int total) {}
      final ProgressCallback progress = onSendProgress;
      final cancelToken = CancelToken();
      const timeout = Duration(minutes: 5);

      await executor.send(
        context: bearer('tok'),
        route: const WorkplaceRequestRoute(method: 'PUT', pathSegments: ['files']),
        transfer: WorkplaceRequestTransfer(
          onSendProgress: progress,
          cancelToken: cancelToken,
          timeout: timeout,
        ),
      );

      final options = adapter.captured!;
      expect(options.onSendProgress, same(progress));
      expect(options.cancelToken, same(cancelToken));
      expect(options.sendTimeout, equals(timeout));
      expect(options.receiveTimeout, equals(timeout));
    });

    test('keeps the WorkplaceDio timeouts when the transfer sets none', () async {
      const defaultTimeout = Duration(seconds: 10);
      WorkplaceDio.setInstance(
        Dio(BaseOptions(sendTimeout: defaultTimeout, receiveTimeout: defaultTimeout))
          ..httpClientAdapter = adapter,
      );

      await executor.send(
        context: bearer('tok'),
        route: const WorkplaceRequestRoute(method: 'GET', pathSegments: ['apps']),
      );

      final options = adapter.captured!;
      expect(options.sendTimeout, equals(defaultTimeout));
      expect(options.receiveTimeout, equals(defaultTimeout));
    });

    test('throws StateError on a blank token without sending', () async {
      await expectLater(
        executor.send(
          context: bearer('  '),
          route: const WorkplaceRequestRoute(method: 'GET', pathSegments: ['apps']),
        ),
        throwsStateError,
      );
      expect(adapter.captured, isNull);
    });
  });
}
