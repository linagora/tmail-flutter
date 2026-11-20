import 'package:delegation/delegation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/error/method/exception/error_method_response_exception.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:tmail_ui_user/features/delegation/data/network/delegate_api.dart';

void main() {
  final accountId = AccountId(Id('account-a'));
  final bob = Delegate(id: Id('delegate-1'), username: 'bob@example.com');
  final alice = Delegate(id: Id('delegate-2'), username: 'alice@example.com');
  const using = [
    'urn:ietf:params:jmap:core',
    'urn:apache:james:params:jmap:delegation',
  ];
  const headers = {'accept': 'application/json;jmapVersion=rfc-8621'};
  final getOnlyRequest = {
    'using': using,
    'methodCalls': [
      ['Delegate/get', {'accountId': 'account-a'}, 'c0'],
    ],
  };

  late DioAdapter dioAdapter;
  late DelegateApi api;
  var httpCallCount = 0;

  setUp(() {
    final dio = Dio(BaseOptions(method: 'POST'))..options.baseUrl = 'http://domain.com/jmap';
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      httpCallCount++;
      handler.next(options);
    }));
    dioAdapter = DioAdapter(dio: dio);
    api = DelegateApi(HttpClient(dio));
    httpCallCount = 0;
  });

  void replyTo({
    required Map<String, dynamic> request,
    required List<dynamic> methodResponses,
  }) {
    dioAdapter.onPost(
      '',
      (server) => server.reply(200, {
        'sessionState': 'state',
        'methodResponses': methodResponses,
      }),
      data: request,
      headers: headers,
    );
  }

  void replyToGet(Map<String, dynamic> getResponse) {
    replyTo(
      request: getOnlyRequest,
      methodResponses: [
        ['Delegate/get', getResponse, 'c0'],
      ],
    );
  }

  void replyToSetThenGet({
    required Map<String, dynamic> request,
    required Object setResponse,
    required Object getResponse,
  }) {
    replyTo(
      request: request,
      methodResponses: [
        setResponse is Map<String, dynamic>
            ? ['Delegate/set', setResponse, 'c0']
            : setResponse,
        getResponse is Map<String, dynamic>
            ? ['Delegate/get', getResponse, 'c1']
            : getResponse,
      ],
    );
  }

  group('DelegateApi.getDelegates', () {
    test('should return the delegates of the server', () async {
      replyToGet({
        'accountId': 'account-a',
        'list': [
          {'id': 'delegate-1', 'username': 'bob@example.com'},
        ],
        'notFound': [],
      });

      expect(await api.getDelegates(accountId), [bob]);
    });

    test('should return an empty list when list is empty', () async {
      replyToGet({
        'accountId': 'account-a',
        'list': [],
        'notFound': [],
      });

      expect(await api.getDelegates(accountId), isEmpty);
    });
  });

  group('DelegateApi.addDelegates', () {
    final usernames = {'bob@example.com', 'alice@example.com'};
    final setThenGetRequest = {
      'using': using,
      'methodCalls': [
        [
          'Delegate/set',
          {
            'accountId': 'account-a',
            'create': {
              'c0': {'username': 'bob@example.com'},
              'c1': {'username': 'alice@example.com'},
            },
          },
          'c0',
        ],
        ['Delegate/get', {'accountId': 'account-a'}, 'c1'],
      ],
    };

    test('should send set then get in one request with the given accountId', () async {
      replyToSetThenGet(
        request: setThenGetRequest,
        setResponse: {
          'accountId': 'account-a',
          'newState': 's2',
          'created': {
            'c0': {'id': 'delegate-1'},
            'c1': {'id': 'delegate-2'},
          },
        },
        getResponse: {
          'accountId': 'account-a',
          'list': [
            {'id': 'delegate-1', 'username': 'bob@example.com'},
            {'id': 'delegate-2', 'username': 'alice@example.com'},
          ],
          'notFound': [],
        },
      );

      final result = await api.addDelegates(accountId, usernames);

      expect(httpCallCount, 1);
      expect(result.addedUsernames, ['bob@example.com', 'alice@example.com']);
      expect(result.rejectedUsernames, isEmpty);
      expect(result.delegates, [bob, alice]);
    });

    test('should mark only the invalidArguments username as rejected', () async {
      replyToSetThenGet(
        request: setThenGetRequest,
        setResponse: {
          'accountId': 'account-a',
          'newState': 's2',
          'created': {
            'c0': {'id': 'delegate-1'},
          },
          'notCreated': {
            'c1': {'type': 'invalidArguments', 'description': 'unknown user'},
          },
        },
        getResponse: {
          'accountId': 'account-a',
          'list': [
            {'id': 'delegate-1', 'username': 'bob@example.com'},
          ],
          'notFound': [],
        },
      );

      final result = await api.addDelegates(accountId, usernames);

      expect(result.addedUsernames, ['bob@example.com']);
      expect(result.addedUsernames, isNot(contains('alice@example.com')));
      expect(result.rejectedUsernames.keys, ['alice@example.com']);
      expect(result.rejectedUsernames['alice@example.com']!.type.value, 'invalidArguments');
      expect(result.delegates, [bob]);
    });

    test('should reject a username absent from created and notCreated with null error', () async {
      replyToSetThenGet(
        request: setThenGetRequest,
        setResponse: {
          'accountId': 'account-a',
          'newState': 's2',
          'created': {
            'c0': {'id': 'delegate-1'},
          },
        },
        getResponse: {
          'accountId': 'account-a',
          'list': [
            {'id': 'delegate-1', 'username': 'bob@example.com'},
          ],
          'notFound': [],
        },
      );

      final result = await api.addDelegates(accountId, usernames);

      expect(result.addedUsernames, ['bob@example.com']);
      expect(result.rejectedUsernames, {'alice@example.com': null});
      expect(result.addedUsernames, isNot(contains('alice@example.com')));
    });

    test('should return delegates null when get answers an error, without a second request', () async {
      replyToSetThenGet(
        request: setThenGetRequest,
        setResponse: {
          'accountId': 'account-a',
          'newState': 's2',
          'created': {
            'c0': {'id': 'delegate-1'},
            'c1': {'id': 'delegate-2'},
          },
        },
        getResponse: ['error', {'type': 'serverFail'}, 'c1'],
      );

      final result = await api.addDelegates(accountId, usernames);

      expect(httpCallCount, 1);
      expect(result.addedUsernames, ['bob@example.com', 'alice@example.com']);
      expect(result.rejectedUsernames, isEmpty);
      expect(result.delegates, isNull);
    });

    test('should throw when set answers an error invocation', () async {
      replyToSetThenGet(
        request: setThenGetRequest,
        setResponse: ['error', {'type': 'forbidden'}, 'c0'],
        getResponse: {
          'accountId': 'account-a',
          'list': [],
          'notFound': [],
        },
      );

      await expectLater(
        api.addDelegates(accountId, usernames),
        throwsA(isA<ErrorMethodResponseException>()),
      );
    });
  });

  group('DelegateApi.removeDelegate', () {
    final setThenGetDestroyRequest = {
      'using': using,
      'methodCalls': [
        [
          'Delegate/set',
          {
            'accountId': 'account-a',
            'destroy': ['delegate-1'],
          },
          'c0',
        ],
        ['Delegate/get', {'accountId': 'account-a'}, 'c1'],
      ],
    };

    test('should return the removed delegate and refreshed list when destroy succeeds', () async {
      replyToSetThenGet(
        request: setThenGetDestroyRequest,
        setResponse: {
          'accountId': 'account-a',
          'newState': 's2',
          'destroyed': ['delegate-1'],
        },
        getResponse: {
          'accountId': 'account-a',
          'list': [
            {'id': 'delegate-2', 'username': 'alice@example.com'},
          ],
          'notFound': [],
        },
      );

      final result = await api.removeDelegate(accountId, bob);

      expect(result.removedDelegate, bob);
      expect(result.delegates, [alice]);
    });

    test('should throw and not return a result when the server does not destroy', () async {
      replyToSetThenGet(
        request: setThenGetDestroyRequest,
        setResponse: {
          'accountId': 'account-a',
          'newState': 's2',
          'notDestroyed': {
            'delegate-1': {'type': 'notFound'},
          },
        },
        getResponse: {
          'accountId': 'account-a',
          'list': [
            {'id': 'delegate-1', 'username': 'bob@example.com'},
          ],
          'notFound': [],
        },
      );

      await expectLater(
        api.removeDelegate(accountId, bob),
        throwsA(isA<UnknownMethodResponse>()),
      );
    });

    test('should return delegates null when get answers an error after a successful destroy', () async {
      replyToSetThenGet(
        request: setThenGetDestroyRequest,
        setResponse: {
          'accountId': 'account-a',
          'newState': 's2',
          'destroyed': ['delegate-1'],
        },
        getResponse: ['error', {'type': 'serverFail'}, 'c1'],
      );

      final result = await api.removeDelegate(accountId, bob);

      expect(result.removedDelegate, bob);
      expect(result.delegates, isNull);
    });
  });
}
