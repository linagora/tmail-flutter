import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/datasource/workplace_drive_datasource.dart';
import 'package:workplace/data/datasource_impl/workplace_datasource_impl.dart';
import 'package:workplace/data/datasource_impl/workplace_drive_datasource_impl.dart';
import 'package:workplace/data/datasource_impl/workplace_request_executor.dart';
import 'package:workplace/data/model/workplace_permission_request.dart';
import 'package:workplace/data/model/workplace_enums.dart';
import 'package:workplace/data/repository_impl/workplace_repository_impl.dart';
import 'package:workplace/data/workplace_dio.dart';
import 'package:workplace/domain/entity/workplace_access_mode.dart';

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

/// Records the last request it is asked to send and answers with a share code.
class _RecordingExecutor implements WorkplaceRequestExecutor {
  WorkplaceRequestRoute? route;
  WorkplaceRequestBody? body;

  @override
  Future<dynamic> send({
    required WorkplaceRequestContext context,
    required WorkplaceRequestRoute route,
    WorkplaceRequestBody body = const WorkplaceRequestBody(),
    WorkplaceRequestTransfer transfer = const WorkplaceRequestTransfer(),
  }) async {
    this.route = route;
    this.body = body;
    return {
      'data': {
        'attributes': {
          'shortcodes': {'code': 'abc123'},
        },
      },
    };
  }
}

/// Records the arguments of the last share-link call; other calls are out of scope.
class _RecordingDataSource extends Fake implements WorkplaceDriveDataSource {
  WorkplaceRequestContext? context;
  String? fileId;

  @override
  Future<Uri> createShareLink({
    required WorkplaceRequestContext context,
    required String fileId,
  }) async {
    this.context = context;
    this.fileId = fileId;
    return Uri.parse('https://user-drive.example.com/public?sharecode=abc123');
  }
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

  Map<String, dynamic> capabilitiesResponse({required bool flat}) => {
        'data': {
          'type': 'io.cozy.settings',
          'id': 'io.cozy.settings.capabilities',
          'attributes': {'flat_subdomains': flat},
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
      final adapter = _QueueAdapter([capabilitiesResponse(flat: true), permissionResponse('abc123')]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      final link = await datasource.createShareLink(context: context, fileId: 'file-1');

      expect(link.toString(), equals('https://platform-drive.example.com/public?sharecode=abc123'));
      expect(adapter.capturedOptions.first.method, equals('GET'));
      expect(adapter.capturedOptions.first.uri.path, endsWith('/settings/capabilities'));
      expect(adapter.capturedOptions.last.uri.queryParameters['codes'], equals('code'));
      expect(adapter.capturedOptions, hasLength(2));
    });

    test('POSTs a JSON GET rule on the given file id to /permissions', () async {
      final executor = _RecordingExecutor();

      await WorkplaceDriveDataSourceImpl(executor: executor)
          .createShareLink(context: context, fileId: 'file-1');

      expect(executor.route?.method, equals('POST'));
      expect(executor.route?.pathSegments, equals(['permissions']));
      expect(executor.body?.headers, equals({'Content-Type': 'application/json'}));
      final rule = (executor.body?.data as Map)['data']['attributes']['permissions']['file'];
      expect(rule['type'], equals('io.cozy.files'));
      expect(rule['verbs'], equals(['GET']));
      expect(rule['values'], equals(['file-1']));
    });

    test('throws StateError when the response carries no share code', () async {
      final adapter = _QueueAdapter([
        capabilitiesResponse(flat: true),
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

    test('throws StateError when the share code is empty', () async {
      final adapter = _QueueAdapter([capabilitiesResponse(flat: true), permissionResponse('')]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      await expectLater(
        datasource.createShareLink(context: context, fileId: 'file-1'),
        throwsA(isA<StateError>()),
      );
    });

    test('builds the flat drive subdomain for a multi-label host', () async {
      final adapter = _QueueAdapter([capabilitiesResponse(flat: true), permissionResponse('abc123')]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);
      final nestedContext = WorkplaceRequestContext(
        platformUrl: Uri.parse('https://user.nested.example.com'),
        accessMode: const BearerTokenAccessMode('test-token'),
      );

      final link = await datasource.createShareLink(context: nestedContext, fileId: 'file-1');

      expect(link.host, equals('user-drive.nested.example.com'));
    });

    test('appends -drive to a single-label host', () async {
      final adapter = _QueueAdapter([capabilitiesResponse(flat: true), permissionResponse('abc123')]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);
      final singleLabelContext = WorkplaceRequestContext(
        platformUrl: Uri.parse('http://localhost'),
        accessMode: const BearerTokenAccessMode('test-token'),
      );

      final link = await datasource.createShareLink(context: singleLabelContext, fileId: 'file-1');

      expect(link.host, equals('localhost-drive'));
    });

    test('keeps the platform port and drops its path and query', () async {
      final adapter = _QueueAdapter([capabilitiesResponse(flat: true), permissionResponse('abc123')]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);
      final portContext = WorkplaceRequestContext(
        platformUrl: Uri.parse('https://user.example.com:8443/base/?lang=en'),
        accessMode: const BearerTokenAccessMode('test-token'),
      );

      final link = await datasource.createShareLink(context: portContext, fileId: 'file-1');

      expect(link.toString(), equals('https://user-drive.example.com:8443/public?sharecode=abc123'));
    });

    test('builds the flat drive subdomain, flat host', () async {
      final adapter = _QueueAdapter([capabilitiesResponse(flat: true), permissionResponse('abc123')]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);
      final flatContext = WorkplaceRequestContext(
        platformUrl: Uri.parse('https://user.example.com'),
        accessMode: const BearerTokenAccessMode('test-token'),
      );

      final link = await datasource.createShareLink(context: flatContext, fileId: 'file-1');

      expect(link.host, equals('user-drive.example.com'));
      expect(link.toString(), equals('https://user-drive.example.com/public?sharecode=abc123'));
    });

    test('builds the nested drive subdomain when the stack is not flat', () async {
      final adapter = _QueueAdapter([capabilitiesResponse(flat: false), permissionResponse('abc123')]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);
      final nestedContext = WorkplaceRequestContext(
        platformUrl: Uri.parse('https://user.example.com:8443/base/?lang=en'),
        accessMode: const BearerTokenAccessMode('test-token'),
      );

      final link = await datasource.createShareLink(context: nestedContext, fileId: 'file-1');

      expect(link.toString(), equals('https://drive.user.example.com:8443/public?sharecode=abc123'));
    });

    test('treats a missing flat_subdomains flag as nested', () async {
      final adapter = _QueueAdapter([
        {'data': {'attributes': <String, dynamic>{}}},
        permissionResponse('abc123'),
      ]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      final link = await datasource.createShareLink(context: context, fileId: 'file-1');

      expect(link.host, equals('drive.platform.example.com'));
    });

    test('mints no link when the capabilities request fails', () async {
      final adapter = _QueueAdapter([500]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      await expectLater(
        datasource.createShareLink(context: context, fileId: 'file-1'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.capturedOptions, hasLength(1));
    });
  });

  group('WorkplaceRepositoryImpl::createShareLink::', () {
    test('forwards the context and file id to the datasource', () async {
      final dataSource = _RecordingDataSource();

      final link = await WorkplaceRepositoryImpl(WorkplaceDataSourceImpl(), dataSource)
          .createShareLink(context: context, fileId: 'file-1');

      expect(dataSource.context, same(context));
      expect(dataSource.fileId, equals('file-1'));
      expect(link.queryParameters['sharecode'], equals('abc123'));
    });
  });
}
