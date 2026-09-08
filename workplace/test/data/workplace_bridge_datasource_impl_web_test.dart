@TestOn('chrome')
library;

import 'dart:js_interop';

import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/datasource_impl/workplace_bridge_datasource_impl.dart';
import 'package:workplace/domain/entity/workplace_action_config.dart';
import 'package:workplace/domain/entity/workplace_intent_config.dart';
import 'package:workplace/domain/entity/workplace_theme.dart';

import '../test_utils/cozy_bridge_test_helper.dart';

void main() {
  late WorkplaceBridgeDataSourceImpl datasource;

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

  const config = WorkplaceIntentConfig(
    addAsLink: WorkplaceActionConfig(label: 'https://link.url'),
    theme: WorkplaceTheme.light,
  );

  setUp(() => datasource = WorkplaceBridgeDataSourceImpl());
  tearDown(removeCozyBridge);

  group('WorkplaceBridgeDataSourceImpl::isAvailable::', () {
    test('Should be false when window._cozyBridge is absent', () {
      removeCozyBridge();
      expect(datasource.isAvailable, isFalse);
    });

    test('Should be true once fetchJSON is attached to window._cozyBridge', () {
      installCozyBridge((_) => intentResponse.jsify());
      expect(datasource.isAvailable, isTrue);
    });
  });

  group('WorkplaceBridgeDataSourceImpl::createIntent::', () {
    test('Should POST /intents through the bridge and return WorkplaceIntent', () async {
      JSObject? capturedOptions;
      installCozyBridge((options) {
        capturedOptions = options;
        return intentResponse.jsify();
      });

      final result = await datasource.createIntent(config);

      expect(result.intentId, equals('intent-abc'));
      expect(result.intentUrl, equals(Uri.parse('https://drive.example.com/pick')));

      final decoded = capturedOptions!.dartify() as Map;
      expect(decoded['method'], equals('POST'));
      expect(decoded['path'], equals('/intents'));
      expect((decoded['body'] as Map)['data'], isA<Map>());
    });

    test('Should propagate the error when the bridge fetchJSON call rejects', () async {
      installCozyBridge((_) => throw StateError('bridge rejected'));

      // Crossing the JS promise boundary re-boxes the Dart error, so only
      // the propagation itself is asserted, not the original StateError type.
      expect(() => datasource.createIntent(config), throwsA(anything));
    });
  });
}
