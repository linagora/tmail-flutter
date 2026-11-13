import 'package:delegation/delegation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/error/method/exception/error_method_response_exception.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:tmail_ui_user/features/delegation/data/network/delegated_account_api.dart';

void main() {
  final accountId = AccountId(Id('account-a'));
  final delegationId = Id('delegation-1');
  const using = [
    'urn:ietf:params:jmap:core',
    'urn:apache:james:params:jmap:delegation',
  ];
  const headers = {'accept': 'application/json;jmapVersion=rfc-8621'};

  late DioAdapter dioAdapter;
  late DelegatedAccountApi api;

  setUp(() {
    final dio = Dio(BaseOptions(method: 'POST'))..options.baseUrl = 'http://domain.com/jmap';
    dioAdapter = DioAdapter(dio: dio);
    api = DelegatedAccountApi(HttpClient(dio));
  });

  void replyToSet(Map<String, dynamic> methodResponse) {
    dioAdapter.onPost(
      '',
      (server) => server.reply(200, {
        'sessionState': 'state',
        'methodResponses': [
          ['DelegatedAccount/set', methodResponse, 'c0'],
        ],
      }),
      data: {
        'using': using,
        'methodCalls': [
          [
            'DelegatedAccount/set',
            {
              'accountId': 'account-a',
              'destroy': ['delegation-1'],
            },
            'c0',
          ],
        ],
      },
      headers: headers,
    );
  }

  group('DelegatedAccountApi.getDelegatedAccounts', () {
    test('should return the delegated accounts of the server', () async {
      dioAdapter.onPost(
        '',
        (server) => server.reply(200, {
          'sessionState': 'state',
          'methodResponses': [
            [
              'DelegatedAccount/get',
              {
                'accountId': 'account-a',
                'list': [
                  {'id': 'delegation-1', 'username': 'owner@example.com'},
                ],
                'notFound': [],
              },
              'c0',
            ],
          ],
        }),
        data: {
          'using': using,
          'methodCalls': [
            ['DelegatedAccount/get', {'accountId': 'account-a'}, 'c0'],
          ],
        },
        headers: headers,
      );

      final result = await api.getDelegatedAccounts(accountId);

      expect(result, [DelegatedAccount(id: delegationId, username: 'owner@example.com')]);
    });

    test('should throw instead of returning an empty list when the server refuses the call', () async {
      dioAdapter.onPost(
        '',
        (server) => server.reply(200, {
          'sessionState': 'state',
          'methodResponses': [
            ['error', {'type': 'forbidden'}, 'c0'],
          ],
        }),
        data: {
          'using': using,
          'methodCalls': [
            ['DelegatedAccount/get', {'accountId': 'account-a'}, 'c0'],
          ],
        },
        headers: headers,
      );

      await expectLater(
        api.getDelegatedAccounts(accountId),
        throwsA(isA<ErrorMethodResponseException>()),
      );
    });
  });

  group('DelegatedAccountApi.removeDelegatedAccount', () {
    test('should complete when the server destroys the delegation', () async {
      replyToSet({
        'accountId': 'account-a',
        'newState': 's2',
        'destroyed': ['delegation-1'],
      });

      await expectLater(api.removeDelegatedAccount(accountId, delegationId), completes);
    });

    test('should throw when the server does not destroy the delegation', () async {
      replyToSet({
        'accountId': 'account-a',
        'newState': 's2',
        'notDestroyed': {
          'delegation-1': {'type': 'notFound'},
        },
      });

      await expectLater(
        api.removeDelegatedAccount(accountId, delegationId),
        throwsA(isA<UnknownMethodResponse>()),
      );
    });
  });
}
