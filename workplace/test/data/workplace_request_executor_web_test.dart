@TestOn('chrome')
library;

import 'dart:js_interop';

import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/datasource_impl/workplace_request_executor.dart';
import 'package:workplace/domain/entity/workplace_access_mode.dart';

import '../test_utils/cozy_bridge_test_helper.dart';

void main() {
  const executor = WorkplaceRequestExecutor();
  final context = WorkplaceRequestContext(
    platformUrl: Uri.parse('https://platform.example.com'),
    accessMode: const BridgeAccessMode(),
  );

  tearDown(removeCozyBridge);

  group('WorkplaceRequestExecutor::bridge::', () {
    test('encodes each path segment and appends the query string', () async {
      JSObject? captured;
      installCozyBridge((options) {
        captured = options;
        return {'ok': true}.jsify();
      });

      await executor.send(
        context: context,
        route: const WorkplaceRequestRoute(
          method: 'POST',
          pathSegments: ['files', 'io.cozy.apps/mail'],
          queryParameters: {'Type': 'file', 'Name': 'a b.pdf'},
        ),
      );

      final decoded = captured!.dartify() as Map;
      expect(decoded['method'], equals('POST'));
      expect(decoded['path'], equals('/files/io.cozy.apps%2Fmail?Type=file&Name=a+b.pdf'));
      expect(decoded.containsKey('body'), isFalse);
      expect(decoded.containsKey('headers'), isFalse);
    });

    test('encodes reserved characters in query keys and values', () async {
      JSObject? captured;
      installCozyBridge((options) {
        captured = options;
        return null;
      });

      await executor.send(
        context: context,
        route: const WorkplaceRequestRoute(
          method: 'GET',
          pathSegments: ['files'],
          queryParameters: {'a&b': 'c=d'},
        ),
      );

      final decoded = captured!.dartify() as Map;
      expect(decoded['path'], equals('/files?a%26b=c%3Dd'));
    });

    test('passes body and headers through when present', () async {
      JSObject? captured;
      installCozyBridge((options) {
        captured = options;
        return null;
      });

      await executor.send(
        context: context,
        route: const WorkplaceRequestRoute(method: 'POST', pathSegments: ['permissions']),
        body: const WorkplaceRequestBody(
          data: {'a': 1},
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final decoded = captured!.dartify() as Map;
      expect(decoded['body'], equals({'a': 1}));
      expect(decoded['headers'], equals({'Content-Type': 'application/json'}));
    });
  });
}
