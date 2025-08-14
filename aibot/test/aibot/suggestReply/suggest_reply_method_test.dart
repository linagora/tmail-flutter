import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:aibot/suggestReply/suggest_reply_method.dart';
import 'package:aibot/suggestReply/suggest_reply_response.dart';

void main() {
  group('test suggest reply method', () {
    test('suggest reply method and response parsing', () async {
      final baseOption = BaseOptions(method: 'POST');
      final dio = Dio(baseOption)..options.baseUrl = 'http://domain.com/jmap';
      final dioAdapter = DioAdapter(dio: dio);

      final accountId = AccountId(Id(
          '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6'));
      const emailId = 'm123456';
      const userInput = 'Can you help me reply to this?';
      const expectedSuggestion =
          'Of course, here is a suggestion for your reply.';

      dioAdapter.onPost(
        '',
        (server) => server.reply(
          200,
          {
            "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
            "methodResponses": [
              [
                "AIBot/suggestReply",
                {
                  "accountId": accountId.id.value,
                  "suggestion": expectedSuggestion,
                },
                "c0"
              ]
            ]
          },
        ),
        data: {
          "using": [
            SuggestReplyMethod.capabilityIdentifier.value.toString(),
            "urn:ietf:params:jmap:core"
          ],
          "methodCalls": [
            [
              "AIBot/suggestReply",
              {
                "accountId": accountId.id.value,
                "emailId": emailId,
                "userInput": userInput
              },
              "c0"
            ]
          ]
        },
      );

      final httpClient = HttpClient(dio);
      final processingInvocation = ProcessingInvocation();
      final requestBuilder =
          JmapRequestBuilder(httpClient, processingInvocation);

      final suggestReplyMethod = SuggestReplyMethod(
        accountId: accountId,
        emailId: emailId,
        userInput: userInput,
      );

      final invocation = requestBuilder.invocation(suggestReplyMethod);
      final response = await (requestBuilder
            ..usings(suggestReplyMethod.requiredCapabilities))
          .build()
          .execute();
      final result = response.parse<SuggestReplyResponse>(
        invocation.methodCallId,
        SuggestReplyResponse.deserialize,
      );

      expect(result, isNotNull);
      expect(result?.suggestion, equals(expectedSuggestion));
      expect(result?.accountId, equals(accountId));
    });
  });
}
