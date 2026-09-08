@TestOn('chrome')
library;

import 'dart:convert';
import 'dart:js_interop';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/datasource_impl/workplace_datasource_impl.dart';
import 'package:workplace/data/workplace_dio.dart';
import 'package:workplace/domain/entity/workplace_action_config.dart';
import 'package:workplace/domain/entity/workplace_intent_access_mode.dart';
import 'package:workplace/domain/entity/workplace_intent_config.dart';
import 'package:workplace/domain/entity/workplace_theme.dart';

import '../test_utils/cozy_bridge_test_helper.dart';

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
    removeCozyBridge();
    WorkplaceDio.setInstance(originalDio);
  });

  group('WorkplaceDataSourceImpl::createIntent::CozyBridge::', () {
    test('Should return WorkplaceIntent via the bridge when available', () async {
      JSObject? capturedOptions;
      installCozyBridge((options) {
        capturedOptions = options;
        return intentResponse.jsify();
      });

      final result = await datasource.createIntent(
        platformUrl: Uri.parse('https://platform.example.com'),
        accessMode: const BridgeAccessMode(),
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

    test('Should propagate the error when the bridge fetchJSON call throws', () async {
      installCozyBridge((options) => throw StateError('bridge rejected'));

      // Crossing the JS promise boundary re-boxes the Dart error, so only
      // the propagation itself is asserted, not the original StateError type.
      expect(
        () => datasource.createIntent(
          platformUrl: Uri.parse('https://platform.example.com'),
          accessMode: const BridgeAccessMode(),
          config: const WorkplaceIntentConfig(
            addAsLink: WorkplaceActionConfig(label: 'https://link.url'),
            theme: WorkplaceTheme.light,
          ),
        ),
        throwsA(anything),
      );
    });

    test('Should use the bearer-token flow when explicitly requested', () async {
      final adapter = _MockAdapter(intentResponse);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      final result = await datasource.createIntent(
        platformUrl: Uri.parse('https://platform.example.com'),
        accessMode: const BearerTokenAccessMode('test-token'),
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
