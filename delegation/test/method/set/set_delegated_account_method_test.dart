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
  group('SetDelegatedAccountMethod', () {
    final accountId = AccountId(Id('account-a'));
    final delegationId = Id('delegation-1');

    Future<SetDelegatedAccountResponse?> execute(Map<String, dynamic> methodResponse) async {
      final dio = createDio();
      DioAdapter(dio: dio).onPost(
        '',
        (server) => server.reply(200, {
          'sessionState': 'state',
          'methodResponses': [
            ['DelegatedAccount/set', methodResponse, 'c0'],
          ],
        }),
        data: {
          'using': [
            'urn:ietf:params:jmap:core',
            'urn:apache:james:params:jmap:delegation',
          ],
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
        headers: createJMAPHeader(),
      );

      final builder = createBuilder(dio);
      final method = SetDelegatedAccountMethod(accountId)..addDestroy({delegationId});
      final invocation = builder.invocation(method);
      final result = await (builder..usings(method.requiredCapabilities)).build().execute();
      return result.parse<SetDelegatedAccountResponse>(
        invocation.methodCallId,
        SetDelegatedAccountResponse.deserialize,
      );
    }

    test('should send no destroy key when nothing is to be destroyed', () {
      expect(SetDelegatedAccountMethod(accountId).toJson(), {'accountId': 'account-a'});
    });

    test('should send ifInState and #destroy when they are set', () {
      final method = SetDelegatedAccountMethod(accountId)
        ..addIfInState(State('s1'))
        ..addReferenceDestroy(ResultReference(MethodCallId('c0'), MethodName('DelegatedAccount/get'), ReferencePath.idsPath));

      expect(method.toJson(), {
        'accountId': 'account-a',
        'ifInState': 's1',
        '#destroy': {'resultOf': 'c0', 'name': 'DelegatedAccount/get', 'path': '/ids/*'},
      });
    });

    test('should send only destroy and parse the destroyed id', () async {
      final response = await execute({
        'accountId': 'account-a',
        'newState': 's2',
        'destroyed': ['delegation-1'],
      });

      expect(response!.destroyed, {delegationId});
      expect(response.notDestroyed, isNull);
    });

    test('should parse notDestroyed when the server refuses the destroy', () async {
      final response = await execute({
        'accountId': 'account-a',
        'newState': 's2',
        'notDestroyed': {
          'delegation-1': {'type': 'forbidden', 'description': 'not allowed'},
        },
      });

      expect(response!.destroyed, isNull);
      expect(response.notDestroyed!.keys, [delegationId]);
      expect(response.notDestroyed![delegationId]!.type.value, 'forbidden');
    });
  });
}
