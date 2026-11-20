import 'package:delegation/delegation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';

import '../method_fixtures.dart';

void main() {
  group('GetDelegateMethod', () {
    final accountId = AccountId(Id('account-a'));

    Future<GetDelegateResponse?> execute(Map<String, dynamic> methodResponse) async {
      final dio = createDio();
      DioAdapter(dio: dio).onPost(
        '',
        (server) => server.reply(200, {
          'sessionState': 'state',
          'methodResponses': [
            ['Delegate/get', methodResponse, 'c0'],
          ],
        }),
        data: {
          'using': [
            'urn:ietf:params:jmap:core',
            'urn:apache:james:params:jmap:delegation',
          ],
          'methodCalls': [
            ['Delegate/get', {'accountId': 'account-a'}, 'c0'],
          ],
        },
        headers: createJMAPHeader(),
      );

      final builder = createBuilder(dio);
      final method = GetDelegateMethod(accountId);
      final invocation = builder.invocation(method);
      final result = await (builder..usings(method.requiredCapabilities)).build().execute();
      return result.parse<GetDelegateResponse>(
        invocation.methodCallId,
        GetDelegateResponse.deserialize,
      );
    }

    test('should parse list and notFound when the response has no state', () async {
      final response = await execute({
        'accountId': 'account-a',
        'list': [
          {'id': 'delegate-1', 'username': 'bob@example.com'},
          {'id': 'delegate-2', 'username': 'alice@example.com'},
        ],
        'notFound': ['missing-id'],
      });

      expect(response!.list, [
        Delegate(id: Id('delegate-1'), username: 'bob@example.com'),
        Delegate(id: Id('delegate-2'), username: 'alice@example.com'),
      ]);
      expect(response.notFound, [Id('missing-id')]);
    });

    test('should return an empty list when I have no delegates', () async {
      final response = await execute({
        'accountId': 'account-a',
        'list': [],
        'notFound': [],
      });

      expect(response!.list, isEmpty);
      expect(response.notFound, isEmpty);
    });
  });
}
