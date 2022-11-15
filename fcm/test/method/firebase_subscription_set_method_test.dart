import 'package:dio/dio.dart';
import 'package:fcm/method/set/firebase_subscription_set_method.dart';
import 'package:fcm/method/set/firebase_subscription_set_response.dart';
import 'package:fcm/model/device_client_id.dart';
import 'package:fcm/model/firebase_expired_time.dart';
import 'package:fcm/model/firebase_subscription.dart';
import 'package:fcm/model/firebase_subscription_id.dart';
import 'package:fcm/model/firebase_token.dart';
import 'package:fcm/model/type_name.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';

void main() {
  group('test to json firebase subscription set method', () {
    final expectedFirebaseSubscriptionCreated = FirebaseSubscription(
      id: FirebaseSubscriptionId(Id('175dbd70-93d1-11ec-984e-e3f8b83572b4')),
      expires: FirebaseExpiredTime(UTCDate(DateTime.parse('2022-03-31T02:14:29Z'))),
    );

    test('firebase subscription set method and response parsing', () async {
      final baseOption  = BaseOptions(method: 'POST');
      final dio = Dio(baseOption)
        ..options.baseUrl = 'http://domain.com/jmap';
      final dioAdapter = DioAdapter(dio: dio);
      dioAdapter.onPost(
        '',
        (server) => server.reply(200, {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "FirebaseRegistration/set",
              {
                "created": {
                  "dab246": {
                    "id": "175dbd70-93d1-11ec-984e-e3f8b83572b4",
                    "expires": "2022-03-31T02:14:29Z"
                  }
                }
              },
              "c0"
            ]
          ]
        }),
        data: {
          "using": [
            "urn:ietf:params:jmap:core",
            "com:linagora:params:jmap:firebase:push"
          ],
          "methodCalls": [
            [
              "FirebaseRegistration/set",
              {
                "create": {
                  "dab246": {
                    "token": "token1",
                    "deviceClientId": "a123-b123-c123",
                    "types": ["Mailbox"]
                  }
                }
              },
              "c0"
            ]
          ]
        },
        headers: {
          "accept": "application/json;jmapVersion=rfc-8621",
          "content-type": "application/json; charset=utf-8",
          "content-length": 225
        }
      );

      final createRequestId = Id('dab246');

      final firebaseSubscriptionSetMethod = FirebaseSubscriptionSetMethod()
        ..addCreate(
          createRequestId,
          FirebaseSubscription(
            deviceClientId: DeviceClientId('a123-b123-c123'),
            token: FirebaseToken('token1'),
            types: [TypeName.mailboxType]
          )
        );

      final httpClient = HttpClient(dio);
      final requestBuilder = JmapRequestBuilder(httpClient, ProcessingInvocation());
      final firebaseSubscriptionSetInvocation = requestBuilder.invocation(firebaseSubscriptionSetMethod);
      final response = await (requestBuilder
          ..usings(firebaseSubscriptionSetMethod.requiredCapabilities))
        .build()
        .execute();

      final firebaseSubscriptionSetResponse = response.parse<FirebaseSubscriptionSetResponse>(
        firebaseSubscriptionSetInvocation.methodCallId,
        FirebaseSubscriptionSetResponse.deserialize);

      expect(
        firebaseSubscriptionSetResponse!.created![createRequestId]!.id,
        equals(expectedFirebaseSubscriptionCreated.id)
      );
    });
  });
}