import 'package:delegation/delegation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';

import '../method_fixtures.dart';

void main() {
  group('GetDelegatedAccountMethod', () {
    final accountId = AccountId(Id('account-a'));

    Future<GetDelegatedAccountResponse?> execute(Map<String, dynamic> methodResponse) async {
      final dio = createDio();
      DioAdapter(dio: dio).onPost(
        '',
        (server) => server.reply(200, {
          'sessionState': 'state',
          'methodResponses': [
            ['DelegatedAccount/get', methodResponse, 'c0'],
          ],
        }),
        data: {
          'using': [
            'urn:ietf:params:jmap:core',
            'urn:apache:james:params:jmap:delegation',
          ],
          'methodCalls': [
            ['DelegatedAccount/get', {'accountId': 'account-a'}, 'c0'],
          ],
        },
        headers: createJMAPHeader(),
      );

      final builder = createBuilder(dio);
      final method = GetDelegatedAccountMethod(accountId);
      final invocation = builder.invocation(method);
      final result = await (builder..usings(method.requiredCapabilities)).build().execute();
      return result.parse<GetDelegatedAccountResponse>(
        invocation.methodCallId,
        GetDelegatedAccountResponse.deserialize,
      );
    }

    test('should parse every delegated account when the response has no state', () async {
      final response = await execute({
        'accountId': 'account-a',
        'list': [
          {'id': 'delegation-1', 'username': 'owner1@example.com'},
          {'id': 'delegation-2', 'username': 'owner2@example.com'},
        ],
        'notFound': [],
      });

      expect(response!.list, [
        DelegatedAccount(id: Id('delegation-1'), username: 'owner1@example.com'),
        DelegatedAccount(id: Id('delegation-2'), username: 'owner2@example.com'),
      ]);
      expect(response.notFound, isEmpty);
    });

    test('should return an empty list when nothing is delegated to me', () async {
      final response = await execute({
        'accountId': 'account-a',
        'list': [],
        'notFound': [],
      });

      expect(response!.list, isEmpty);
    });
  });
}
