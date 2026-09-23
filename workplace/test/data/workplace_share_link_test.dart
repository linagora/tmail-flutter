import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/datasource_impl/workplace_drive_datasource_impl.dart';
import 'package:workplace/data/model/workplace_permission_request.dart';
import 'package:workplace/data/model/workplace_enums.dart';
import 'package:workplace/data/workplace_dio.dart';
import 'package:workplace/domain/entity/workplace_access_mode.dart';
import 'package:workplace/domain/entity/workplace_request_context.dart';

/// Queued responses; an int means "throw that HTTP status".
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

void main() {
  late WorkplaceDriveDataSourceImpl datasource;
  late Dio originalDio;
  final context = WorkplaceRequestContext(
    platformUrl: Uri.parse('https://platform.example.com'),
    accessMode: const BearerTokenAccessMode('test-token'),
  );

  Map<String, dynamic> permissionResponse(String code) => {
        'data': {
          'id': 'perm-1',
          'attributes': {
            'shortcodes': {'code': code},
          },
        },
      };

  setUp(() {
    datasource = WorkplaceDriveDataSourceImpl();
    originalDio = WorkplaceDio.instance;
  });

  tearDown(() => WorkplaceDio.setInstance(originalDio));

  group('WorkplaceDriveDataSourceImpl::createShareLink::', () {
    test('WorkplacePermissionRequest.toJson emits the io.cozy types and GET verb', () {
      final json = const WorkplacePermissionRequest(
        data: WorkplacePermissionDataRequest(
          type: WorkplaceDataRequestType.permissions,
          attributes: WorkplacePermissionAttributesRequest(
            permissions: WorkplacePermissionSetRequest(
              file: WorkplacePermissionRuleRequest(
                type: WorkplaceDocType.files,
                verbs: [WorkplacePermission.get],
                values: ['file-1'],
              ),
            ),
          ),
        ),
      ).toJson();

      expect(json['data']['type'], equals('io.cozy.permissions'));
      expect(json['data']['attributes']['permissions']['file']['type'], equals('io.cozy.files'));
      expect(json['data']['attributes']['permissions']['file']['verbs'], equals(['GET']));
      expect(json['data']['attributes']['permissions']['file']['values'], equals(['file-1']));
    });

    test('reads the code from shortcodes.code and builds <driveApp>/public?sharecode=', () async {
      final adapter = _QueueAdapter([permissionResponse('abc123')]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      final link = await datasource.createShareLink(context: context, fileId: 'file-1');

      expect(link.toString(), equals('https://platform-drive.example.com/public?sharecode=abc123'));
      expect(adapter.capturedOptions.first.uri.queryParameters['codes'], equals('code'));
      expect(adapter.capturedOptions, hasLength(1));
    });

    test('throws StateError when the response carries no share code', () async {
      final adapter = _QueueAdapter([
        {
          'data': {
            'id': 'perm-1',
            'attributes': {'shortcodes': null},
          },
        },
      ]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      await expectLater(
        datasource.createShareLink(context: context, fileId: 'file-1'),
        throwsA(isA<StateError>()),
      );
    });

    test('builds the flat drive subdomain, nested host', () async {
      final adapter = _QueueAdapter([permissionResponse('abc123')]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);
      final nestedContext = WorkplaceRequestContext(
        platformUrl: Uri.parse('https://user.nested.example.com'),
        accessMode: const BearerTokenAccessMode('test-token'),
      );

      final link = await datasource.createShareLink(context: nestedContext, fileId: 'file-1');

      expect(link.host, equals('user-drive.nested.example.com'));
    });

    test('builds the flat drive subdomain, flat host', () async {
      final adapter = _QueueAdapter([permissionResponse('abc123')]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);
      final flatContext = WorkplaceRequestContext(
        platformUrl: Uri.parse('https://user.example.com'),
        accessMode: const BearerTokenAccessMode('test-token'),
      );

      final link = await datasource.createShareLink(context: flatContext, fileId: 'file-1');

      expect(link.host, equals('user-drive.example.com'));
      expect(link.toString(), equals('https://user-drive.example.com/public?sharecode=abc123'));
    });
  });
}
