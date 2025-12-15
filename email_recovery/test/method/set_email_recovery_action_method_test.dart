import 'package:dio/dio.dart';
import 'package:email_recovery/email_recovery/email_recovery_action.dart';
import 'package:email_recovery/email_recovery/email_recovery_action_id.dart';
import 'package:email_recovery/email_recovery/email_recovery_status.dart.dart';
import 'package:email_recovery/email_recovery/set/set_email_recovery_action_method.dart';
import 'package:email_recovery/email_recovery/set/set_email_recovery_action_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';

void main() {
  group('test to json email recovery action set method', () {
    final expectEmailRecoveryAction = EmailRecoveryAction(
      id: EmailRecoveryActionId(Id('2034-495-05857-57abcd-0876664'))
    );

    test('email recovery action set method and response parsing', () async {
      final baseOption  = BaseOptions(method: 'POST');
      final dio = Dio(baseOption)..options.baseUrl = 'http://domain.com/jmap';
      final dioAdapter = DioAdapter(dio: dio);
      dioAdapter.onPost(
        '',
        (server) => server.reply(200, {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "EmailRecoveryAction/set",
              {
                "created": {
                  "hieubt": {
                    "id": "2034-495-05857-57abcd-0876664"
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
            "com:linagora:params:jmap:messages:vault"
          ],
          "methodCalls": [
            [
              "EmailRecoveryAction/set",
              {
                "create": {
                  "hieubt": {
                    "deletedBefore": "2023-02-09T10:00:00.000Z",
                    "deletedAfter": "2023-02-09T09:00:00.000Z",
                    "receivedBefore": "2023-02-09T10:00:00.000Z",
                    "receivedAfter": "2023-02-09T09:00:00.000Z",
                    "hasAttachment": "true",
                    "subject": "Simple topic",
                    "sender": "bob@domain.tld",
                    "recipients": ["alice@domain.tld"]
                  }
                }
              },
              "c0"
            ]
          ]
        },
        headers: {
          "accept": "application/json;jmapVersion=rfc-8621",
        }
      );

      final createRequestId = Id('hieubt');

      final emailRecoveryActionSetMethod = SetEmailRecoveryActionMethod()
        ..addCreate(
          createRequestId,
          EmailRecoveryAction(
            deletedBefore: UTCDate(DateTime.parse('2023-02-09T10:00:00Z')),
            deletedAfter: UTCDate(DateTime.parse('2023-02-09T09:00:00Z')),
            receivedBefore: UTCDate(DateTime.parse('2023-02-09T10:00:00Z')),
            receivedAfter: UTCDate(DateTime.parse('2023-02-09T09:00:00Z')),
            hasAttachment: true,
            subject: 'Simple topic',
            sender: 'bob@domain.tld',
            recipients: ['alice@domain.tld']
          )
        );
      
      final httpClient = HttpClient(dio);
      final requestBuilder = JmapRequestBuilder(httpClient, ProcessingInvocation());
      final emailRecoveryActionSetInvocation = requestBuilder.invocation(emailRecoveryActionSetMethod);
      final response = await (requestBuilder
          ..usings(emailRecoveryActionSetMethod.requiredCapabilities))
        .build()
        .execute();
      
      final emailRecoveryActionSetResponse = response.parse<SetEmailRecoveryActionResponse>(
        emailRecoveryActionSetInvocation.methodCallId,
        SetEmailRecoveryActionResponse.deserialize
      );

      expect(
        emailRecoveryActionSetResponse!.created![createRequestId]!.id,
        equals(expectEmailRecoveryAction.id)
      );
    });
  });

  group('test to json email recovery action set method not updated error', () {
    final updateRequestTaskId = Id('2034-495-05857-57abcd-0876664');
    final notUpdatedError = SetError(
      SetError.notFound,
      description: 'Task not found'
    );

    final expectNotUpdatedError = {updateRequestTaskId: notUpdatedError};

    test('email recovery action set method and response parsing', () async {
      final baseOption  = BaseOptions(method: 'POST');
      final dio = Dio(baseOption)..options.baseUrl = 'http://domain.com/jmap';
      final dioAdapter = DioAdapter(dio: dio);
      dioAdapter.onPost(
        '',
        (server) => server.reply(200, {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "EmailRecoveryAction/set",
              {
                "notUpdated": {
                  "2034-495-05857-57abcd-0876664": {
                    "type": "notFound",
                    "description": "Task not found"
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
            "com:linagora:params:jmap:messages:vault"
          ],
          "methodCalls": [
            [
              "EmailRecoveryAction/set",
              {
                "update": {
                  "2034-495-05857-57abcd-0876664": {
                    "status": "canceled"
                  }
                }
              },
              "c0"
            ]
          ]
        },
        headers: {
          "accept": "application/json;jmapVersion=rfc-8621",
        }
      );

      final pathObjectEmailRecoveryAction = PatchObject(
        EmailRecoveryAction(
          status: EmailRecoveryStatus.canceled
        ).toJson()
      );

      final emailRecoveryActionSetMethod = SetEmailRecoveryActionMethod()
        ..addUpdates({updateRequestTaskId: pathObjectEmailRecoveryAction});
      
      final httpClient = HttpClient(dio);
      final requestBuilder = JmapRequestBuilder(httpClient, ProcessingInvocation());
      final emailRecoveryActionSetInvocation = requestBuilder.invocation(emailRecoveryActionSetMethod);
      final response = await (requestBuilder
          ..usings(emailRecoveryActionSetMethod.requiredCapabilities))
        .build()
        .execute();
      
      final emailRecoveryActionSetResponse = response.parse<SetEmailRecoveryActionResponse>(
        emailRecoveryActionSetInvocation.methodCallId,
        SetEmailRecoveryActionResponse.deserialize
      );

      expect(
        emailRecoveryActionSetResponse!.notUpdated![updateRequestTaskId]!.type,
        equals(expectNotUpdatedError[updateRequestTaskId]!.type)
      );
      expect(
        emailRecoveryActionSetResponse.notUpdated![updateRequestTaskId]!.description,
        equals(expectNotUpdatedError[updateRequestTaskId]!.description)
      );
    });
  });
}