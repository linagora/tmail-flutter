@TestOn('chrome')
library;

import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/datasource_impl/workplace_datasource_impl.dart';
import 'package:workplace/data/workplace_dio.dart';
import 'package:workplace/domain/entity/workplace_action_config.dart';
import 'package:workplace/domain/entity/workplace_intent_config.dart';
import 'package:workplace/domain/entity/workplace_theme.dart';

@JS('window')
external JSObject get _window;

/// Installs a fake `window._cozyBridge.fetchJSON` so `CozyBridge.isAvailable` is true.
void _installBridge(JSAny? Function(JSObject options) handler) {
  JSPromise<JSAny?> fetchJson(JSObject options) =>
      Future<JSAny?>.value(handler(options)).toJS;

  final bridge = JSObject();
  bridge['fetchJSON'] = fetchJson.toJS;
  _window['_cozyBridge'] = bridge;
}

/// Removes the bridge so `CozyBridge.isAvailable` is false (`isSupported` stays true on chrome).
void _removeBridge() => _window['_cozyBridge'] = null;

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

void main() {
  late WorkplaceDataSourceImpl datasource;
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
    datasource = WorkplaceDataSourceImpl();
    originalDio = WorkplaceDio.instance;
  });

  tearDown(() {
    _removeBridge();
    WorkplaceDio.setInstance(originalDio);
  });

  group('WorkplaceDataSourceImpl::createIntent::CozyBridge::', () {
    test('Should return WorkplaceIntent via the bridge when available', () async {
      JSObject? capturedOptions;
      _installBridge((options) {
        capturedOptions = options;
        return intentResponse.jsify();
      });

      final result = await datasource.createIntent(
        platformUrl: Uri.parse('https://platform.example.com'),
        config: const WorkplaceIntentConfig(
          addAsLink: WorkplaceActionConfig(label: 'https://link.url'),
          theme: WorkplaceTheme.light,
        ),
      );

      expect(result.intentId, equals('intent-abc'));
      expect(result.intentUrl, equals(Uri.parse('https://drive.example.com/pick')));

      final decoded = capturedOptions!.dartify() as Map;
      expect(decoded['method'], equals('POST'));
      expect(decoded['path'], equals('/intents'));
    });

    test('Should reject a null access token when the bridge is unavailable', () async {
      _removeBridge();

      expect(
        () => datasource.createIntent(
          platformUrl: Uri.parse('https://platform.example.com'),
          accessToken: null,
          config: const WorkplaceIntentConfig(
            addAsLink: WorkplaceActionConfig(label: 'https://link.url'),
            theme: WorkplaceTheme.light,
          ),
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('Should fall back to the bearer-token flow when the bridge is unavailable but an access token is present', () async {
      _removeBridge();
      final adapter = _MockAdapter(intentResponse);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      final result = await datasource.createIntent(
        platformUrl: Uri.parse('https://platform.example.com'),
        accessToken: 'test-token',
        config: const WorkplaceIntentConfig(
          addAsLink: WorkplaceActionConfig(label: 'https://link.url'),
          theme: WorkplaceTheme.light,
        ),
      );

      expect(result.intentId, equals('intent-abc'));
      expect(
        adapter.capturedOptions!.headers['Authorization'],
        equals('Bearer test-token'),
      );
    });
  });
}
