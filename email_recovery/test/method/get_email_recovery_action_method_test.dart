import 'package:dio/dio.dart';
import 'package:email_recovery/email_recovery/email_recovery_action.dart';
import 'package:email_recovery/email_recovery/email_recovery_action_id.dart';
import 'package:email_recovery/email_recovery/email_recovery_status.dart.dart';
import 'package:email_recovery/email_recovery/get/get_email_recovery_action_method.dart';
import 'package:email_recovery/email_recovery/get/get_email_recovery_action_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:http_mock_adapter/src/adapters/dio_adapter.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';

void main() {
  group('test to json email recovery action get method', () {
    final expectEmailRecoveryAction = EmailRecoveryAction(
      id: EmailRecoveryActionId(Id('2034-495-05857-57abcd-0876664')),
      status: EmailRecoveryStatus.inProgress,
    );

    test('email recovery action get method and response parsing', () async {
      final baseOption = BaseOptions(method: 'POST');
      final dio = Dio(baseOption)..options.baseUrl = 'http://domain.com/jmap';
      final dioAdapter = DioAdapter(dio: dio);
      dioAdapter.onPost(
        '',
        (server) => server.reply(200, {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "EmailRecoveryAction/get",
              {
                "notFound": [],
                "list": [
                  {
                    "id": "2034-495-05857-57abcd-0876664",
                    "status": "inProgress"
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
            "com:linagora:params:jmap:messages:vault"
          ],
          "methodCalls": [
            [
              "EmailRecoveryAction/get",
              {},
              "c0"
            ]
          ]
        },
        headers: {
          "accept": "application/json;jmapVersion=rfc-8621",
        }
      );

      final httpClient = HttpClient(dio);
      final processingInvocation = ProcessingInvocation();
      final requestBuilder = JmapRequestBuilder(httpClient, processingInvocation);

      final getEmailRecoveryActionMethod = GetEmailRecoveryActionMethod();
      final getEmailRecoveryActionInvocation = requestBuilder.invocation(getEmailRecoveryActionMethod);
      final response = await (requestBuilder
          ..usings(getEmailRecoveryActionMethod.requiredCapabilities))
        .build()
        .execute();
      
      final resultList = response.parse<GetEmailRecoveryActionResponse>(
        getEmailRecoveryActionInvocation.methodCallId,
        GetEmailRecoveryActionResponse.deserialize
      );

      expect(resultList?.list.length, equals(1));
      expect(resultList?.list, contains(expectEmailRecoveryAction));
    });
  });
}
