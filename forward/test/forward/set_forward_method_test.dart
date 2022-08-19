import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forward/forward/forward_id.dart';
import 'package:forward/forward/get/get_forward_method.dart';
import 'package:forward/forward/get/get_forward_response.dart';
import 'package:forward/forward/set/set_forward_method.dart';
import 'package:forward/forward/tmail_forward.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';

void main() {
  group('test to json set forward method', () {
    final expectedUpdated = TMailForward(
      id: ForwardIdSingleton.forwardIdSingleton,
      localCopy: true,
      forwards: {'dab@domain.com', 'vuda@gmail.com'}
    );

    test('set forward method and response parsing', () async {
      final baseOption  = BaseOptions(method: 'POST');
      final dio = Dio(baseOption)
        ..options.baseUrl = 'http://domain.com';
      final dioAdapter = DioAdapter(dio: dio);
      dioAdapter.onPost(
        '/jmap',
        (server) => server.reply(200, {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "Forward/set",
              {
                "accountId": "0d14dbabe6482aff5cbf922e04cef51a40b4eabccbe12d28fe27c97038752555",
                "newState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
                "updated": {
                  "singleton": {}
                }
              },
              "c0"
            ],
            [
              "Forward/get",
              {
                "accountId": "0d14dbabe6482aff5cbf922e04cef51a40b4eabccbe12d28fe27c97038752555",
                "notFound": [],
                "state": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
                "list": [
                  {
                    "id": "singleton",
                    "localCopy": true,
                    "forwards": [
                      "dab@domain.com",
                      "vuda@gmail.com"
                    ]
                  }
                ]
              },
              "c1"
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
              "Forward/set",
              {
                "accountId": "0d14dbabe6482aff5cbf922e04cef51a40b4eabccbe12d28fe27c97038752555",
                "update": {
                  "singleton": {
                    "id": "singleton",
                    "localCopy": true,
                    "forwards": [
                      "dab@domain.com",
                      "vuda@gmail.com"
                    ]
                  }
                }
              },
              "c0"
            ],
            [
              "Forward/get",
              {
                "accountId": "0d14dbabe6482aff5cbf922e04cef51a40b4eabccbe12d28fe27c97038752555",
                "ids": [
                  "singleton"
                ]
              },
              "c1"
            ]
          ]
        },
        headers: {
          "accept": "application/json;jmapVersion=rfc-8621",
          "content-type": "application/json; charset=utf-8",
          "content-length": 420
        }
      );

      final accountId = AccountId(Id('0d14dbabe6482aff5cbf922e04cef51a40b4eabccbe12d28fe27c97038752555'));
      final httpClient = HttpClient(dio);
      final processingInvocation = ProcessingInvocation();

      final setForwardMethod = SetForwardMethod(accountId)
        ..addUpdatesSingleton({
          ForwardIdSingleton.forwardIdSingleton.id : TMailForward(
              id: ForwardIdSingleton.forwardIdSingleton,
              localCopy: true,
              forwards: {'dab@domain.com', 'vuda@gmail.com'}
          )
        });

      final requestBuilder = JmapRequestBuilder(httpClient, processingInvocation)
        ..invocation(setForwardMethod);

      final getForwardMethod = GetForwardMethod(accountId)
        ..addIds({ForwardIdSingleton.forwardIdSingleton.id});
      final getForwardInvocation = requestBuilder.invocation(getForwardMethod);

      final response = await (requestBuilder
          ..usings(setForwardMethod.requiredCapabilities))
        .build()
        .execute();

      final getForwardResponse = response.parse<GetForwardResponse>(
          getForwardInvocation.methodCallId,
          GetForwardResponse.deserialize);

      expect(getForwardResponse!.list.length, equals(1));
      expect(getForwardResponse.list, containsAll({expectedUpdated}));
    });
  });
}