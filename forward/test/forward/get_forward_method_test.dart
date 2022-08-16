import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forward/forward/forward_id.dart';
import 'package:forward/forward/get/get_forward_method.dart';
import 'package:forward/forward/get/get_forward_response.dart';
import 'package:forward/forward/tmail_forward.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';

void main() {
  group('test to json get forward method', () {
    final expectRuleFilter1 = TmailForward(
      id: ForwardIdSingleton.forwardIdSingleton,
      localCopy: true,
      forwards: {"bob@domain.org", "alice@domain.org"},
    );

    test('get forward method and response parsing', () async {
      final baseOption = BaseOptions(method: 'POST');
      final dio = Dio(baseOption)..options.baseUrl = 'http://domain.com';
      final dioAdapter = DioAdapter(dio: dio);
      dioAdapter.onPost(
          '/jmap',
          (server) => server.reply(200, {
                "sessionState": "abcdefghij",
                "methodResponses": [
                  [
                    "Forward/get",
                    {
                      "accountId": "123",
                      "notFound": [],
                      "state": "1",
                      "list": [
                        {
                          "id": "singleton",
                          "localCopy": true,
                          "forwards": ["bob@domain.org", "alice@domain.org"]
                        }
                      ]
                    },
                    "c0"
                  ]
                ]
              }),
          data: {
            "using": [
              "urn:ietf:params:jmap:core",
              "com:linagora:params:jmap:forward"
            ],
            "methodCalls": [
              [
                "Forward/get",
                {
                  "accountId":
                      "29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6",
                  "ids": ["singleton"]
                },
                "c0"
              ]
            ]
          },
          headers: {
            "accept": "application/json;jmapVersion=rfc-8621",
            "content-type": "application/json; charset=utf-8",
            "content-length": 212
          });

      final httpClient = HttpClient(dio);
      final processingInvocation = ProcessingInvocation();
      final requestBuilder =
          JmapRequestBuilder(httpClient, processingInvocation);
      final accountId = AccountId(Id(
          '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6'));

      final getForwardMethod = GetForwardMethod(accountId)
        ..addIds({ForwardIdSingleton.forwardIdSingleton.id});
      final getRuleFilterInvocation =
          requestBuilder.invocation(getForwardMethod);
      final response = await (requestBuilder
            ..usings(getForwardMethod.requiredCapabilities))
          .build()
          .execute();

      final resultList = response.parse<GetForwardResponse>(
          getRuleFilterInvocation.methodCallId,
          GetForwardResponse.deserialize);

      expect(resultList?.list.length, equals(1));
      expect(resultList?.list, containsAll({expectRuleFilter1}));
    });
  });
}
