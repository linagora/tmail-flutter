import 'package:delegation/delegation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/request/reference_path.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';
import 'package:jmap_dart_client/jmap/core/request/result_reference.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';

import '../method_fixtures.dart';

void main() {
  group('SetDelegateMethod', () {
    final accountId = AccountId(Id('account-a'));
    final creationId = Id('c0');
    final delegateId = Id('delegate-1');

    Future<SetDelegateResponse?> execute({
      required Map<String, dynamic> methodArgs,
      required Map<String, dynamic> methodResponse,
      required SetDelegateMethod method,
    }) async {
      final dio = createDio();
      DioAdapter(dio: dio).onPost(
        '',
        (server) => server.reply(200, {
          'sessionState': 'state',
          'methodResponses': [
            ['Delegate/set', methodResponse, 'c0'],
          ],
        }),
        data: {
          'using': [
            'urn:ietf:params:jmap:core',
            'urn:apache:james:params:jmap:delegation',
          ],
          'methodCalls': [
            ['Delegate/set', methodArgs, 'c0'],
          ],
        },
        headers: createJMAPHeader(),
      );

      final builder = createBuilder(dio);
      final invocation = builder.invocation(method);
      final result = await (builder..usings(method.requiredCapabilities)).build().execute();
      return result.parse<SetDelegateResponse>(
        invocation.methodCallId,
        SetDelegateResponse.deserialize,
      );
    }

    test('should send only accountId when nothing is set', () {
      expect(SetDelegateMethod(accountId).toJson(), {'accountId': 'account-a'});
    });

    test('should send create as username objects keyed by creation id', () {
      final method = SetDelegateMethod(accountId)
        ..addCreate(creationId, DelegateCreation(username: 'bob@example.com'));

      expect(method.toJson(), {
        'accountId': 'account-a',
        'create': {
          'c0': {'username': 'bob@example.com'},
        },
      });
    });

    test('should send destroy ids and keep ifInState and #destroy', () {
      final method = SetDelegateMethod(accountId)
        ..addIfInState(State('s1'))
        ..addDestroy({delegateId})
        ..addReferenceDestroy(
          ResultReference(MethodCallId('c0'), MethodName('Delegate/get'), ReferencePath.idsPath),
        );

      expect(method.toJson(), {
        'accountId': 'account-a',
        'ifInState': 's1',
        'destroy': ['delegate-1'],
        '#destroy': {'resultOf': 'c0', 'name': 'Delegate/get', 'path': '/ids/*'},
      });
    });

    test('should parse created as creation id to server id', () async {
      final response = await execute(
        methodArgs: {
          'accountId': 'account-a',
          'create': {
            'c0': {'username': 'bob@example.com'},
          },
        },
        methodResponse: {
          'accountId': 'account-a',
          'newState': 's2',
          'created': {
            'c0': {'id': 'delegate-1'},
          },
        },
        method: SetDelegateMethod(accountId)
          ..addCreate(creationId, DelegateCreation(username: 'bob@example.com')),
      );

      expect(response!.created, {creationId: delegateId});
      expect(response.notCreated, isNull);
    });

    test('should parse notCreated when the server refuses a create', () async {
      final response = await execute(
        methodArgs: {
          'accountId': 'account-a',
          'create': {
            'c0': {'username': 'unknown@example.com'},
          },
        },
        methodResponse: {
          'accountId': 'account-a',
          'newState': 's2',
          'notCreated': {
            'c0': {'type': 'invalidArguments', 'description': 'unknown user'},
          },
        },
        method: SetDelegateMethod(accountId)
          ..addCreate(creationId, DelegateCreation(username: 'unknown@example.com')),
      );

      expect(response!.created, isNull);
      expect(response.notCreated!.keys, [creationId]);
      expect(response.notCreated![creationId]!.type.value, 'invalidArguments');
    });

    test('should parse destroyed and notDestroyed', () async {
      final response = await execute(
        methodArgs: {
          'accountId': 'account-a',
          'destroy': ['delegate-1'],
        },
        methodResponse: {
          'accountId': 'account-a',
          'newState': 's2',
          'destroyed': ['delegate-1'],
          'notDestroyed': {
            'delegate-2': {'type': 'notFound'},
          },
        },
        method: SetDelegateMethod(accountId)..addDestroy({delegateId}),
      );

      expect(response!.destroyed, {delegateId});
      expect(response.notDestroyed!.keys, [Id('delegate-2')]);
      expect(response.notDestroyed![Id('delegate-2')]!.type.value, 'notFound');
    });
  });
}
