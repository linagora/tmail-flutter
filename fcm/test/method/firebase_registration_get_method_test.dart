import 'package:dio/dio.dart';
import 'package:fcm/method/get/firebase_registration_get_method.dart';
import 'package:fcm/method/get/firebase_registration_get_response.dart';
import 'package:fcm/model/device_client_id.dart';
import 'package:fcm/model/firebase_expired_time.dart';
import 'package:fcm/model/firebase_registration.dart';
import 'package:fcm/model/firebase_registration_id.dart';
import 'package:fcm/model/type_name.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';

void main() {
  group('test to json firebase registration get method', () {
    final expectFirebaseRegistration1 = FirebaseRegistration(
      id: FirebaseRegistrationId(Id('e50b2c1d-9553-41a3-b0a7-a7d26b599ee1')),
      deviceClientId: DeviceClientId('b37ff8001ca0'),
      expires: FirebaseExpiredTime(UTCDate(DateTime.parse('2018-07-31T00:13:21Z'))),
      types: [TypeName.mailboxType],
    );

    final expectFirebaseRegistration2 = FirebaseRegistration(
      id: FirebaseRegistrationId(Id('f2d0aab5-e976-4e8b-ad4b-b380a5b987e4')),
      deviceClientId: DeviceClientId('X8980fc'),
      expires: FirebaseExpiredTime(UTCDate(DateTime.parse('2018-07-12T05:55:00Z'))),
      types: [TypeName.mailboxType, TypeName.emailType, TypeName.emailDelivery],
    );

    test('firebase registration get method and response parsing', () async {
      final baseOption = BaseOptions(method: 'POST');
      final dio = Dio(baseOption)..options.baseUrl = 'http://domain.com/jmap';
      final dioAdapter = DioAdapter(dio: dio);
      dioAdapter.onPost(
        '',
        (server) => server.reply(200, {
          "sessionState": "2c9f1b12-b35a",
          "methodResponses": [
            [
              "FirebaseRegistration/get",
              {
                "notFound": [],
                "list": [
                  {
                    "id": "e50b2c1d-9553-41a3-b0a7-a7d26b599ee1",
                    "deviceClientId": "b37ff8001ca0",
                    "expires": "2018-07-31T00:13:21Z",
                    "types": ["Mailbox"]
                  },
                  {
                    "id": "f2d0aab5-e976-4e8b-ad4b-b380a5b987e4",
                    "deviceClientId": "X8980fc",
                    "expires": "2018-07-12T05:55:00Z",
                    "types": ["Mailbox", "Email", "EmailDelivery"]
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
            "com:linagora:params:jmap:firebase:push"
          ],
          "methodCalls": [
            [
              "FirebaseRegistration/get",
              {},
              "c0"
            ]
          ]
        },
        headers: {
          "accept": "application/json;jmapVersion=rfc-8621",
          "content-type": "application/json; charset=utf-8",
          "content-length": 133
        }
      );

      final httpClient = HttpClient(dio);
      final processingInvocation = ProcessingInvocation();
      final requestBuilder = JmapRequestBuilder(httpClient, processingInvocation);

      final firebaseRegistrationGetMethod = FirebaseRegistrationGetMethod();
      final firebaseRegistrationGetInvocation = requestBuilder.invocation(firebaseRegistrationGetMethod);
      final response = await (requestBuilder
          ..usings(firebaseRegistrationGetMethod.requiredCapabilities))
        .build()
        .execute();

      final resultList = response.parse<FirebaseRegistrationGetResponse>(
        firebaseRegistrationGetInvocation.methodCallId,
        FirebaseRegistrationGetResponse.deserialize
      );

      expect(resultList?.list.length, equals(2));
      expect(resultList?.list, containsAll([expectFirebaseRegistration1, expectFirebaseRegistration2]));
    });
  });
}