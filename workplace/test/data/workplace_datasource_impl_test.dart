import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/datasource_impl/workplace_datasource_impl.dart';
import 'package:workplace/data/workplace_dio.dart';
import 'package:workplace/domain/entity/workplace_action_config.dart';
import 'package:workplace/domain/entity/workplace_theme.dart';

/// Captures the last request and returns a fixed JSON response.
class _MockAdapter implements HttpClientAdapter {
  RequestOptions? capturedOptions;
  final dynamic responseData;

  _MockAdapter(this.responseData);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future? cancelFuture,
  ) async {
    capturedOptions = options;
    return ResponseBody.fromString(
      jsonEncode(responseData),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json; charset=utf-8'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Always throws a DioException to simulate a network failure.
class _ErrorAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future? cancelFuture,
  ) async {
    throw DioException(requestOptions: options, message: 'Network error');
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late WorkplaceDataSourceImpl datasource;

  setUp(() {
    datasource = WorkplaceDataSourceImpl();
  });

  Map<String, dynamic> buildResponse({
    required String id,
    required String href,
  }) => {
    'data': {
      'id': id,
      'attributes': {
        'action': 'PICK',
        'type': 'files',
        'permissions': ['GET'],
        'services': [
          {'href': href},
        ],
      },
    },
  };

  group('WorkplaceDataSourceImpl::parseIntentResponse::', () {
    test('Should return WorkplaceIntent with correct id and url', () {
      final result = datasource.parseIntentResponse(
        buildResponse(id: 'intent-1', href: 'https://drive.example.com/pick'),
        requireHttps: false,
      );

      expect(result.intentId, equals('intent-1'));
      expect(result.intentUrl, equals(Uri.parse('https://drive.example.com/pick')));
    });

    test('Should parse JSON string input', () {
      const jsonString =
          '{"data":{"id":"intent-str","attributes":{"action":"PICK","type":"files","permissions":["GET"],"services":[{"href":"https://drive.example.com/str"}]}}}';

      final result = datasource.parseIntentResponse(
        jsonString,
        requireHttps: false,
      );

      expect(result.intentId, equals('intent-str'));
      expect(result.intentUrl.host, equals('drive.example.com'));
    });

    test('Should throw StateError when services list is empty', () {
      final data = {
        'data': {
          'id': 'intent-1',
          'attributes': {
            'action': 'PICK',
            'type': 'files',
            'permissions': ['GET'],
            'services': <dynamic>[],
          },
        },
      };

      expect(
        () => datasource.parseIntentResponse(data, requireHttps: false),
        throwsA(isA<StateError>()),
      );
    });

    test('Should throw FormatException for unsupported input type', () {
      expect(
        () => datasource.parseIntentResponse(42, requireHttps: false),
        throwsA(isA<FormatException>()),
      );
    });

    test('Should throw ArgumentError when requireHttps is true and URL is http', () {
      expect(
        () => datasource.parseIntentResponse(
          buildResponse(id: 'intent-1', href: 'http://drive.example.com/pick'),
          requireHttps: true,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Should accept http URL when requireHttps is false', () {
      final result = datasource.parseIntentResponse(
        buildResponse(id: 'intent-1', href: 'http://drive.example.com/pick'),
        requireHttps: false,
      );

      expect(result.intentUrl.scheme, equals('http'));
    });

    test('Should use kReleaseMode as default for requireHttps', () {
      // In debug/test mode, kReleaseMode is false so http URLs are accepted
      if (kReleaseMode) {
        expect(
          () => datasource.parseIntentResponse(
            buildResponse(id: 'intent-1', href: 'http://drive.example.com/pick'),
          ),
          throwsA(isA<ArgumentError>()),
        );
      } else {
        expect(
          datasource.parseIntentResponse(
            buildResponse(id: 'intent-1', href: 'http://drive.example.com/pick'),
          ),
          isNotNull,
        );
      }
    });

    test('Should parse client from attributes when present', () {
      final data = {
        'data': {
          'id': 'intent-1',
          'attributes': {
            'action': 'PICK',
            'type': 'files',
            'permissions': ['GET'],
            'services': [
              {'href': 'https://drive.example.com/pick'},
            ],
            'client': 'client-abc',
          },
        },
      };

      final result = datasource.parseIntentResponse(data, requireHttps: false);

      expect(result.client, equals('client-abc'));
    });

    test('Should have null client when attributes omit it', () {
      final result = datasource.parseIntentResponse(
        buildResponse(id: 'intent-1', href: 'https://drive.example.com/pick'),
        requireHttps: false,
      );

      expect(result.client, isNull);
    });

    test('Should use first service href when multiple services are present', () {
      final data = {
        'data': {
          'id': 'intent-multi',
          'attributes': {
            'action': 'PICK',
            'type': 'files',
            'permissions': ['GET'],
            'services': [
              {'href': 'https://drive.example.com/first'},
              {'href': 'https://drive.example.com/second'},
            ],
          },
        },
      };

      final result = datasource.parseIntentResponse(data, requireHttps: false);

      expect(result.intentUrl, equals(Uri.parse('https://drive.example.com/first')));
    });
  });

  group('WorkplaceDataSourceImpl::createIntent::', () {
    late Dio originalDio;

    final intentResponse = {
      'data': {
        'id': 'intent-abc',
        'attributes': {
          'action': 'PICK',
          'type': 'files',
          'permissions': ['GET'],
          'services': [
            {'href': 'https://drive.example.com/pick'},
          ],
        },
      },
    };

    setUp(() {
      originalDio = WorkplaceDio.instance;
    });

    tearDown(() {
      WorkplaceDio.setInstance(originalDio);
    });

    test('Should return WorkplaceIntent with correct id and url', () async {
      final adapter = _MockAdapter(intentResponse);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      final result = await datasource.createIntent(
        platformUrl: Uri.parse('https://platform.example.com'),
        accessToken: 'test-token',
        addAsLink: const WorkplaceActionConfig(label: 'https://link.url'),
        addAsAttachment: const WorkplaceActionConfig(label: 'https://attach.url'),
        theme: WorkplaceTheme.light,
      );

      expect(result.intentId, equals('intent-abc'));
      expect(result.intentUrl, equals(Uri.parse('https://drive.example.com/pick')));
    });

    test('Should append /intents to platform URL', () async {
      final adapter = _MockAdapter(intentResponse);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      await datasource.createIntent(
        platformUrl: Uri.parse('https://platform.example.com/api/'),
        accessToken: 'test-token',
        addAsLink: const WorkplaceActionConfig(label: 'https://link.url'),
        addAsAttachment: const WorkplaceActionConfig(label: 'https://attach.url'),
        theme: WorkplaceTheme.light,
      );

      expect(
        adapter.capturedOptions!.uri.pathSegments.last,
        equals('intents'),
      );
    });

    test('Should include force_session_id=true query parameter', () async {
      final adapter = _MockAdapter(intentResponse);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      await datasource.createIntent(
        platformUrl: Uri.parse('https://platform.example.com'),
        accessToken: 'test-token',
        addAsLink: const WorkplaceActionConfig(label: 'https://link.url'),
        addAsAttachment: const WorkplaceActionConfig(label: 'https://attach.url'),
        theme: WorkplaceTheme.light,
      );

      expect(
        adapter.capturedOptions!.uri.queryParameters['force_session_id'],
        equals('true'),
      );
    });

    test('Should send Authorization Bearer header', () async {
      final adapter = _MockAdapter(intentResponse);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      await datasource.createIntent(
        platformUrl: Uri.parse('https://platform.example.com'),
        accessToken: 'my-secret-token',
        addAsLink: const WorkplaceActionConfig(label: 'https://link.url'),
        addAsAttachment: const WorkplaceActionConfig(label: 'https://attach.url'),
        theme: WorkplaceTheme.light,
      );

      expect(
        adapter.capturedOptions!.headers['Authorization'],
        equals('Bearer my-secret-token'),
      );
    });

    test('Should send correct POST body fields for intent creation', () async {
      final adapter = _MockAdapter(intentResponse);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      await datasource.createIntent(
        platformUrl: Uri.parse('https://platform.example.com'),
        accessToken: 'test-token',
        addAsLink: const WorkplaceActionConfig(label: 'https://link.url'),
        addAsAttachment: const WorkplaceActionConfig(label: 'https://attach.url'),
        theme: WorkplaceTheme.dark,
      );

      // Normalize through jsonEncode so nested Dart objects are fully serialized
      final body = jsonDecode(jsonEncode(adapter.capturedOptions!.data)) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      expect(data['type'], equals('io.cozy.intents'));

      final attributes = data['attributes'] as Map<String, dynamic>;
      expect(attributes['action'], equals('PICK'));
      expect(attributes['type'], equals('io.cozy.files'));
      expect(attributes['permissions'], equals(['GET']));

      final config = attributes['data'] as Map<String, dynamic>;
      final sharingLink = config['sharingLink'] as Map<String, dynamic>;
      expect(sharingLink['label'], equals('https://link.url'));
      final downloadLink = config['downloadLink'] as Map<String, dynamic>;
      expect(downloadLink['label'], equals('https://attach.url'));
      final theme = config['theme'] as Map<String, dynamic>;
      expect(theme['type'], equals('dark'));
    });

    test('Should serialize attachment size limits in intent request', () async {
      final adapter = _MockAdapter(intentResponse);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      await datasource.createIntent(
        platformUrl: Uri.parse('https://platform.example.com'),
        accessToken: 'test-token',
        addAsLink: const WorkplaceActionConfig(label: 'https://link.url'),
        addAsAttachment: const WorkplaceActionConfig(
          label: 'https://attach.url',
          maxFileSize: 5000,
          availableSize: 4500,
        ),
        theme: WorkplaceTheme.light,
      );

      final body = jsonDecode(jsonEncode(adapter.capturedOptions!.data)) as Map<String, dynamic>;
      final attributes = (body['data'] as Map<String, dynamic>)['attributes'] as Map<String, dynamic>;
      final config = attributes['data'] as Map<String, dynamic>;
      final downloadLink = config['downloadLink'] as Map<String, dynamic>;

      expect(downloadLink['label'], equals('https://attach.url'));
      expect(downloadLink['maxFileSize'], equals(5000));
      expect(downloadLink['availableSize'], equals(4500));
    });

    test('Should send explicit null downloadLink to hide the attachment button when addAsAttachment is omitted', () async {
      final adapter = _MockAdapter(intentResponse);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      await datasource.createIntent(
        platformUrl: Uri.parse('https://platform.example.com'),
        accessToken: 'test-token',
        addAsLink: const WorkplaceActionConfig(label: 'https://link.url'),
        theme: WorkplaceTheme.light,
      );

      final body = jsonDecode(jsonEncode(adapter.capturedOptions!.data)) as Map<String, dynamic>;
      final attributes = (body['data'] as Map<String, dynamic>)['attributes'] as Map<String, dynamic>;
      final config = attributes['data'] as Map<String, dynamic>;

      expect(config.containsKey('downloadLink'), isTrue);
      expect(config['downloadLink'], isNull);
    });

    test('Should propagate DioException on network error', () async {
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = _ErrorAdapter());

      expect(
        () => datasource.createIntent(
          platformUrl: Uri.parse('https://platform.example.com'),
          accessToken: 'test-token',
          addAsLink: const WorkplaceActionConfig(label: 'https://link.url'),
          addAsAttachment: const WorkplaceActionConfig(label: 'https://attach.url'),
          theme: WorkplaceTheme.light,
        ),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('WorkplaceDataSourceImpl::exchangeToken::', () {
    late Dio originalDio;

    final tokenResponse = {'access_token': 'exchange-token-xyz'};

    setUp(() {
      originalDio = WorkplaceDio.instance;
    });

    tearDown(() {
      WorkplaceDio.setInstance(originalDio);
    });

    test('Should return access token string on success', () async {
      WorkplaceDio.setInstance(
        Dio()..httpClientAdapter = _MockAdapter(tokenResponse),
      );

      final result = await datasource.exchangeToken(
        Uri.parse('https://platform.example.com'),
        'oidc-id-token',
      );

      expect(result, equals('exchange-token-xyz'));
    });

    test('Should append /auth/token_exchange to platform URL', () async {
      final adapter = _MockAdapter(tokenResponse);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      await datasource.exchangeToken(
        Uri.parse('https://platform.example.com/api/'),
        'oidc-id-token',
      );

      final segments = adapter.capturedOptions!.uri.pathSegments;
      expect(segments[segments.length - 2], equals('auth'));
      expect(segments.last, equals('token_exchange'));
    });

    test('Should send correct POST body fields for token exchange', () async {
      final adapter = _MockAdapter(tokenResponse);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      await datasource.exchangeToken(
        Uri.parse('https://platform.example.com'),
        'oidc-id-token',
      );

      final body = jsonDecode(jsonEncode(adapter.capturedOptions!.data)) as Map<String, dynamic>;
      expect(body['id_token'], equals('oidc-id-token'));
      expect(body['exchange_type'], equals('app'));
    });

    test('Should propagate DioException on network error', () async {
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = _ErrorAdapter());

      expect(
        () => datasource.exchangeToken(
          Uri.parse('https://platform.example.com'),
          'oidc-id-token',
        ),
        throwsA(isA<DioException>()),
      );
    });
  });
}
