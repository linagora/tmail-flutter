import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/workplace_dio.dart';
import 'package:workplace/domain/entity/workplace_action_config.dart';
import 'package:workplace/domain/entity/workplace_intent_config.dart';
import 'package:workplace/domain/entity/workplace_theme.dart';
import 'package:workplace/presentation/intent_fetcher/token_drive_intent_fetcher.dart';

// Queues one response per HTTP request; `null` throws a DioException.
class _SequentialAdapter implements HttpClientAdapter {
  final List<Map<String, dynamic>?> _queue;
  final List<RequestOptions> requests = [];
  int _index = 0;

  _SequentialAdapter(this._queue);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future? cancelFuture,
  ) async {
    requests.add(options);
    final item = _queue[_index++];
    if (item == null) {
      throw DioException(requestOptions: options, message: 'Network error');
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

final _platformUrl = Uri.parse('https://platform.example.com');
const _config = WorkplaceIntentConfig(
  addAsLink: WorkplaceActionConfig(label: 'Link'),
  theme: WorkplaceTheme.light,
);
final _tokenResponse = {'access_token': 'drive-access-token'};
final _intentResponse = {
  'data': {
    'id': 'intent-xyz',
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

void main() {
  late Dio originalDio;

  setUp(() => originalDio = WorkplaceDio.instance);
  tearDown(() => WorkplaceDio.setInstance(originalDio));

  group('TokenDriveIntentFetcher::', () {
    test('is always available', () {
      expect(TokenDriveIntentFetcher(oidcTokenGetter: () => null).isAvailable, isTrue);
    });

    test('throws StateError when the OIDC token is null', () async {
      final fetcher = TokenDriveIntentFetcher(oidcTokenGetter: () => null);

      await expectLater(
        fetcher.fetchIntent(_platformUrl, _config),
        throwsA(isA<StateError>().having((e) => e.message, 'message', contains('OIDC token'))),
      );
    });

    test('propagates DioException when the token exchange fails', () async {
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = _SequentialAdapter([null]));
      final fetcher = TokenDriveIntentFetcher(oidcTokenGetter: () => 'oidc-token');

      await expectLater(
        fetcher.fetchIntent(_platformUrl, _config),
        throwsA(isA<DioException>()),
      );
    });

    test('exchanges the token then creates the intent with the bearer header', () async {
      final adapter = _SequentialAdapter([_tokenResponse, _intentResponse]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);
      final fetcher = TokenDriveIntentFetcher(oidcTokenGetter: () => 'oidc-token');

      final result = await fetcher.fetchIntent(_platformUrl, _config);

      expect(result.intentId, equals('intent-xyz'));
      expect(adapter.requests[0].path, endsWith('/auth/token_exchange'));
      expect(adapter.requests[1].headers['Authorization'], equals('Bearer drive-access-token'));
    });
  });
}
