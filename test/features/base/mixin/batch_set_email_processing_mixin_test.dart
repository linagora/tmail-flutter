import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/base/mixin/batch_set_email_processing_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/handle_error_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/mail_api_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/session_mixin.dart';

import '../../../fixtures/account_fixtures.dart';
import '../../../fixtures/session_fixtures.dart';

class ManualMockHttpClient implements HttpClient {
  int postCallCount = 0;
  final Map<int, dynamic> _responses = {};
  final Map<int, Object> _errors = {}; // Store errors/exceptions to throw

  void setResponse(int callIndex, dynamic response) {
    _responses[callIndex] = response;
  }

  /// Simulate a crash for a specific batch
  void setError(int callIndex, Object error) {
    _errors[callIndex] = error;
  }

  @override
  Future<Map<String, dynamic>> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final currentCall = postCallCount;
    postCallCount++;

    // If an error is registered for this call, throw it immediately
    if (_errors.containsKey(currentCall)) {
      throw _errors[currentCall]!;
    }

    final response = _responses[currentCall];
    if (response is Map<String, dynamic>) {
      return response;
    }
    return <String, dynamic>{};
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestBatchSetEmailProcessing
    with HandleSetErrorMixin,
        SessionMixin,
        MailAPIMixin,
        BatchSetEmailProcessingMixin {}

void main() {
  group('BatchSetEmailProcessingMixin test', () {
    late ManualMockHttpClient httpClient;
    late TestBatchSetEmailProcessing testMixin;

    setUp(() {
      httpClient = ManualMockHttpClient();
      testMixin = TestBatchSetEmailProcessing();
      httpClient.postCallCount = 0;
    });

    test(
        'executeBatchSetEmail should return empty result when emailIds is empty',
        () async {
      final result = await testMixin.executeBatchSetEmail(
        session: SessionFixtures.aliceSession,
        accountId: AccountFixtures.aliceAccountId,
        emailIds: [],
        httpClient: httpClient,
        onGenerateUpdates: (_) => {},
      );

      expect(result.emailIdsSuccess, isEmpty);
      expect(result.mapErrors, isEmpty);
      expect(httpClient.postCallCount, 0);
    });

    test(
        'executeBatchSetEmail should split requests when email count exceeds maxObjects',
        () async {
      const maxObjects = 10;
      final session =
          SessionFixtures.getAliceSessionWithMaxObjectsInSet(maxObjects);
      const totalEmails = 25;
      final List<EmailId> emailIds = List<EmailId>.generate(
          totalEmails, (index) => EmailId(Id('email_$index')));

      // Batch 1 (0-9): Success
      httpClient.setResponse(0, {
        "sessionState": "session_state",
        "methodResponses": [
          [
            "Email/set",
            {
              "accountId": AccountFixtures.aliceAccountId.id.value,
              "oldState": "oldState",
              "newState": "newState",
              "updated": {for (var i = 0; i < 10; i++) "email_$i": null}
            },
            "c0"
          ]
        ]
      });

      // Batch 2 (10-19): Success
      httpClient.setResponse(1, {
        "sessionState": "session_state",
        "methodResponses": [
          [
            "Email/set",
            {
              "accountId": AccountFixtures.aliceAccountId.id.value,
              "oldState": "oldState",
              "newState": "newState",
              "updated": {for (var i = 10; i < 20; i++) "email_$i": null}
            },
            "c0"
          ]
        ]
      });

      // Batch 3 (20-24): Success
      httpClient.setResponse(2, {
        "sessionState": "session_state",
        "methodResponses": [
          [
            "Email/set",
            {
              "accountId": AccountFixtures.aliceAccountId.id.value,
              "oldState": "oldState",
              "newState": "newState",
              "updated": {for (var i = 20; i < 25; i++) "email_$i": null}
            },
            "c0"
          ]
        ]
      });

      final result = await testMixin.executeBatchSetEmail(
        session: session,
        accountId: AccountFixtures.aliceAccountId,
        emailIds: emailIds,
        httpClient: httpClient,
        onGenerateUpdates: (batchIds) =>
            {for (final id in batchIds) id.id: PatchObject({})},
      );

      expect(result.emailIdsSuccess.length, totalEmails);
      expect(result.mapErrors, isEmpty);
      expect(httpClient.postCallCount, 3);
    });

    test('executeBatchSetEmail should aggregate errors from batches', () async {
      const maxObjects = 10;
      final session =
          SessionFixtures.getAliceSessionWithMaxObjectsInSet(maxObjects);
      const totalEmails = 20;
      final List<EmailId> emailIds = List<EmailId>.generate(
          totalEmails, (index) => EmailId(Id('email_$index')));

      // Batch 1: Success
      httpClient.setResponse(0, {
        "sessionState": "session_state",
        "methodResponses": [
          [
            "Email/set",
            {
              "accountId": AccountFixtures.aliceAccountId.id.value,
              "oldState": "oldState",
              "newState": "newState",
              "updated": {for (var i = 0; i < 10; i++) "email_$i": null}
            },
            "c0"
          ]
        ]
      });

      // Batch 2: Partial failure (ID email_19 fails)
      httpClient.setResponse(1, {
        "sessionState": "session_state",
        "methodResponses": [
          [
            "Email/set",
            {
              "accountId": AccountFixtures.aliceAccountId.id.value,
              "oldState": "oldState",
              "newState": "newState",
              "updated": {for (var i = 10; i < 19; i++) "email_$i": null},
              "notUpdated": {
                "email_19": {
                  "type": "someError",
                  "description": "error description"
                }
              }
            },
            "c0"
          ]
        ]
      });

      final result = await testMixin.executeBatchSetEmail(
        session: session,
        accountId: AccountFixtures.aliceAccountId,
        emailIds: emailIds,
        httpClient: httpClient,
        onGenerateUpdates: (batchIds) =>
            {for (final id in batchIds) id.id: PatchObject({})},
      );

      expect(result.emailIdsSuccess.length, 19);
      expect(result.mapErrors.length, 1);
      expect(result.mapErrors[Id('email_19')], isNotNull);
      expect(httpClient.postCallCount, 2);
    });

    test(
        'executeBatchSetEmail should handle null response gracefully from a batch',
        () async {
      const maxObjects = 10;
      final session =
          SessionFixtures.getAliceSessionWithMaxObjectsInSet(maxObjects);
      const totalEmails = 20;
      final List<EmailId> emailIds = List<EmailId>.generate(
          totalEmails, (index) => EmailId(Id('email_$index')));

      // Batch 1: Success
      httpClient.setResponse(0, {
        "sessionState": "session_state",
        "methodResponses": [
          [
            "Email/set",
            {
              "accountId": AccountFixtures.aliceAccountId.id.value,
              "oldState": "oldState",
              "newState": "newState",
              "updated": {for (var i = 0; i < 10; i++) "email_$i": null}
            },
            "c0"
          ]
        ]
      });

      // Batch 2: Null response simulation (wrong methodCallId)
      httpClient.setResponse(1, {
        "sessionState": "session_state",
        "methodResponses": [
          [
            "Email/set",
            {
              "accountId": AccountFixtures.aliceAccountId.id.value,
              "updated": {}
            },
            "c999" // Mismatched ID causes parse to return null
          ]
        ]
      });

      final result = await testMixin.executeBatchSetEmail(
        session: session,
        accountId: AccountFixtures.aliceAccountId,
        emailIds: emailIds,
        httpClient: httpClient,
        onGenerateUpdates: (batchIds) =>
            {for (final id in batchIds) id.id: PatchObject({})},
      );

      expect(result.emailIdsSuccess.length, 10);
      expect(result.mapErrors, isEmpty);
      expect(httpClient.postCallCount, 2);
    });

    test(
        'executeBatchSetEmail should handle exact match of maxObjectsInSet boundary',
        () async {
      const maxObjects = 10;
      final session =
          SessionFixtures.getAliceSessionWithMaxObjectsInSet(maxObjects);
      const totalEmails = 20;
      final List<EmailId> emailIds = List<EmailId>.generate(
          totalEmails, (index) => EmailId(Id('email_$index')));

      // Batch 1: Success
      httpClient.setResponse(0, {
        "sessionState": "session_state",
        "methodResponses": [
          [
            "Email/set",
            {
              "accountId": AccountFixtures.aliceAccountId.id.value,
              "updated": {for (var i = 0; i < 10; i++) "email_$i": null}
            },
            "c0"
          ]
        ]
      });

      // Batch 2: Success
      httpClient.setResponse(1, {
        "sessionState": "session_state",
        "methodResponses": [
          [
            "Email/set",
            {
              "accountId": AccountFixtures.aliceAccountId.id.value,
              "updated": {for (var i = 10; i < 20; i++) "email_$i": null}
            },
            "c0"
          ]
        ]
      });

      final result = await testMixin.executeBatchSetEmail(
        session: session,
        accountId: AccountFixtures.aliceAccountId,
        emailIds: emailIds,
        httpClient: httpClient,
        onGenerateUpdates: (batchIds) =>
            {for (final id in batchIds) id.id: PatchObject({})},
      );

      expect(result.emailIdsSuccess.length, 20);
      expect(httpClient.postCallCount, 2);
    });

    test(
      'executeBatchSetEmail should continue processing subsequent batches even when one batch throws an exception',
      () async {
        // Setup: 3 batches of 10 emails each (Total 30)
        const maxObjects = 10;
        final session =
            SessionFixtures.getAliceSessionWithMaxObjectsInSet(maxObjects);
        const totalEmails = 30;
        final List<EmailId> emailIds = List<EmailId>.generate(
            totalEmails, (index) => EmailId(Id('email_$index')));

        // Batch 1 (0-9): SUCCESS
        httpClient.setResponse(0, {
          "sessionState": "session_state",
          "methodResponses": [
            [
              "Email/set",
              {
                "accountId": AccountFixtures.aliceAccountId.id.value,
                "updated": {for (var i = 0; i < 10; i++) "email_$i": null}
              },
              "c0"
            ]
          ]
        });

        // Batch 2 (10-19): FAILURE (Network Exception)
        // This simulates a DioException or any error during the API call
        httpClient.setError(1, Exception('Network connection failed'));

        // Batch 3 (20-29): SUCCESS
        // This ensures the loop didn't break after Batch 2 failed
        httpClient.setResponse(2, {
          "sessionState": "session_state",
          "methodResponses": [
            [
              "Email/set",
              {
                "accountId": AccountFixtures.aliceAccountId.id.value,
                "updated": {for (var i = 20; i < 30; i++) "email_$i": null}
              },
              "c0"
            ]
          ]
        });

        final result = await testMixin.executeBatchSetEmail(
          session: session,
          accountId: AccountFixtures.aliceAccountId,
          emailIds: emailIds,
          httpClient: httpClient,
          onGenerateUpdates: (batchIds) =>
              {for (final id in batchIds) id.id: PatchObject({})},
        );

        // Assertions:
        // We expect emails from Batch 1 and Batch 3 to be successful (10 + 10 = 20)
        expect(result.emailIdsSuccess.length, 20);

        // Ensure Batch 1 IDs are present
        expect(result.emailIdsSuccess.contains(EmailId(Id('email_0'))), isTrue);

        // Ensure Batch 3 IDs are present
        expect(
            result.emailIdsSuccess.contains(EmailId(Id('email_20'))), isTrue);

        // Ensure Batch 2 IDs are NOT present
        expect(
            result.emailIdsSuccess.contains(EmailId(Id('email_10'))), isFalse);

        // Ensure the httpClient was called 3 times (it tried all batches)
        expect(httpClient.postCallCount, 3);

        // mapErrors should be empty
        expect(result.mapErrors, isEmpty);
      },
    );
  });
}
