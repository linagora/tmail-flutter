import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:tmail_ui_user/features/base/mixin/batch_set_email_processing_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/handle_error_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/mail_api_mixin.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/personal_account.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/core_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/default_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/mail_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/mdn_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/submission_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/vacation_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/websocket_capability.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/sort/collation_identifier.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';

// --- Fixtures Cloned from Integration Tests ---

class AccountFixtures {
  static final aliceAccountId = AccountId(Id('29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6'));
  static final aliceAccount = PersonalAccount(
    'dab',
    AuthenticationType.oidc,
    isSelected: true,
    accountId: aliceAccountId,
    apiUrl: 'https://domain.com/jmap',
    userName: UserName('Alice')
  );
}

class SessionFixtures {
  static final aliceSession = Session(
    {
      CapabilityIdentifier.jmapSubmission: SubmissionCapability(
        maxDelayedSend: UnsignedInt(0),
        submissionExtensions: {}
      ),
      CapabilityIdentifier.jmapCore: CoreCapability(
        maxSizeUpload: UnsignedInt(20971520),
        maxConcurrentUpload: UnsignedInt(4),
        maxSizeRequest: UnsignedInt(10000000),
        maxConcurrentRequests: UnsignedInt(4),
        maxCallsInRequest: UnsignedInt(16),
        maxObjectsInGet: UnsignedInt(500),
        maxObjectsInSet: UnsignedInt(500),
        collationAlgorithms: {CollationIdentifier("i;unicode-casemap")}
      ),
      CapabilityIdentifier.jmapMail: MailCapability(
        maxMailboxesPerEmail: UnsignedInt(10000000),
        maxSizeAttachmentsPerEmail: UnsignedInt(20000000),
        emailQuerySortOptions: {"receivedAt", "sentAt", "size", "from", "to", "subject"},
        mayCreateTopLevelMailbox: true
      ),
      CapabilityIdentifier.jmapWebSocket: WebSocketCapability(
        supportsPush: true,
        url: Uri.parse('ws://domain.com/jmap/ws')
      ),
      CapabilityIdentifier(Uri.parse('urn:apache:james:params:jmap:mail:quota')): DefaultCapability(<String, dynamic>{}),
      CapabilityIdentifier(Uri.parse('urn:apache:james:params:jmap:mail:shares')): DefaultCapability(<String, dynamic>{}),
      CapabilityIdentifier.jmapVacationResponse: VacationCapability(),
      CapabilityIdentifier.jmapMdn: MdnCapability(),
    },
    {
      AccountFixtures.aliceAccountId: Account(
        AccountName('alice@domain.tld'),
        true,
        false,
        {
          CapabilityIdentifier.jmapSubmission: SubmissionCapability(
            maxDelayedSend: UnsignedInt(0),
            submissionExtensions: {}
          ),
          CapabilityIdentifier.jmapWebSocket: WebSocketCapability(
            supportsPush: true,
            url: Uri.parse('ws://domain.com/jmap/ws')
          ),
          CapabilityIdentifier.jmapCore: CoreCapability(
            maxSizeUpload: UnsignedInt(20971520),
            maxConcurrentUpload: UnsignedInt(4),
            maxSizeRequest: UnsignedInt(10000000),
            maxConcurrentRequests: UnsignedInt(4),
            maxCallsInRequest: UnsignedInt(16),
            maxObjectsInGet: UnsignedInt(500),
            maxObjectsInSet: UnsignedInt(500),
            collationAlgorithms: {CollationIdentifier("i;unicode-casemap")}
          ),
          CapabilityIdentifier.jmapMail: MailCapability(
            maxMailboxesPerEmail: UnsignedInt(10000000),
            maxSizeAttachmentsPerEmail: UnsignedInt(20000000),
            emailQuerySortOptions: {"receivedAt", "sentAt", "size", "from", "to", "subject"},
            mayCreateTopLevelMailbox: true
          ),
          CapabilityIdentifier(Uri.parse('urn:apache:james:params:jmap:mail:quota')): DefaultCapability(<String, dynamic>{}),
          CapabilityIdentifier(Uri.parse('urn:apache:james:params:jmap:mail:shares')): DefaultCapability(<String, dynamic>{}),
          CapabilityIdentifier.jmapVacationResponse: VacationCapability(),
          CapabilityIdentifier.jmapMdn: MdnCapability()
        }
      )
    },
    {
      CapabilityIdentifier.jmapSubmission: AccountFixtures.aliceAccountId,
      CapabilityIdentifier.jmapWebSocket: AccountFixtures.aliceAccountId,
      CapabilityIdentifier.jmapCore: AccountFixtures.aliceAccountId,
      CapabilityIdentifier.jmapMail: AccountFixtures.aliceAccountId,
      CapabilityIdentifier(Uri.parse('urn:apache:james:params:jmap:mail:quota')): AccountFixtures.aliceAccountId,
      CapabilityIdentifier(Uri.parse('urn:apache:james:params:jmap:mail:shares')): AccountFixtures.aliceAccountId,
      CapabilityIdentifier.jmapVacationResponse: AccountFixtures.aliceAccountId,
      CapabilityIdentifier.jmapMdn: AccountFixtures.aliceAccountId,
    },
    UserName('alice@domain.tld'),
    Uri.parse('http://domain.com/jmap'),
    Uri.parse('http://domain.com/download/{accountId}/{blobId}/?type={type}&name={name}'),
    Uri.parse('http://domain.com/upload/{accountId}'),
    Uri.parse('http://domain.com/eventSource?types={types}&closeAfter={closeafter}&ping={ping}'),
    State('2c9f1b12-b35a-43e6-9af2-0106fb53a943')
  );

  static getAliceSessionWithMaxObjectsInSet(int maxObjectsInSet) => Session(
    {
      CapabilityIdentifier.jmapSubmission: SubmissionCapability(
        maxDelayedSend: UnsignedInt(0),
        submissionExtensions: {}
      ),
      CapabilityIdentifier.jmapCore: CoreCapability(
        maxSizeUpload: UnsignedInt(20971520),
        maxConcurrentUpload: UnsignedInt(4),
        maxSizeRequest: UnsignedInt(10000000),
        maxConcurrentRequests: UnsignedInt(4),
        maxCallsInRequest: UnsignedInt(16),
        maxObjectsInGet: UnsignedInt(500),
        maxObjectsInSet: UnsignedInt(maxObjectsInSet),
        collationAlgorithms: {CollationIdentifier("i;unicode-casemap")}
      ),
      CapabilityIdentifier.jmapMail: MailCapability(
        maxMailboxesPerEmail: UnsignedInt(10000000),
        maxSizeAttachmentsPerEmail: UnsignedInt(20000000),
        emailQuerySortOptions: {"receivedAt", "sentAt", "size", "from", "to", "subject"},
        mayCreateTopLevelMailbox: true
      ),
      CapabilityIdentifier.jmapWebSocket: WebSocketCapability(
        supportsPush: true,
        url: Uri.parse('ws://domain.com/jmap/ws')
      ),
      CapabilityIdentifier(Uri.parse('urn:apache:james:params:jmap:mail:quota')): DefaultCapability(<String, dynamic>{}),
      CapabilityIdentifier(Uri.parse('urn:apache:james:params:jmap:mail:shares')): DefaultCapability(<String, dynamic>{}),
      CapabilityIdentifier.jmapVacationResponse: VacationCapability(),
      CapabilityIdentifier.jmapMdn: MdnCapability(),
    },
    {
      AccountFixtures.aliceAccountId: Account(
        AccountName('alice@domain.tld'),
        true,
        false,
        {
          CapabilityIdentifier.jmapSubmission: SubmissionCapability(
            maxDelayedSend: UnsignedInt(0),
            submissionExtensions: {}
          ),
          CapabilityIdentifier.jmapWebSocket: WebSocketCapability(
            supportsPush: true,
            url: Uri.parse('ws://domain.com/jmap/ws')
          ),
          CapabilityIdentifier.jmapCore: CoreCapability(
            maxSizeUpload: UnsignedInt(20971520),
            maxConcurrentUpload: UnsignedInt(4),
            maxSizeRequest: UnsignedInt(10000000),
            maxConcurrentRequests: UnsignedInt(4),
            maxCallsInRequest: UnsignedInt(16),
            maxObjectsInGet: UnsignedInt(500),
            maxObjectsInSet: UnsignedInt(maxObjectsInSet),
            collationAlgorithms: {CollationIdentifier("i;unicode-casemap")}
          ),
          CapabilityIdentifier.jmapMail: MailCapability(
            maxMailboxesPerEmail: UnsignedInt(10000000),
            maxSizeAttachmentsPerEmail: UnsignedInt(20000000),
            emailQuerySortOptions: {"receivedAt", "sentAt", "size", "from", "to", "subject"},
            mayCreateTopLevelMailbox: true
          ),
          CapabilityIdentifier(Uri.parse('urn:apache:james:params:jmap:mail:quota')): DefaultCapability(<String, dynamic>{}),
          CapabilityIdentifier(Uri.parse('urn:apache:james:params:jmap:mail:shares')): DefaultCapability(<String, dynamic>{}),
          CapabilityIdentifier.jmapVacationResponse: VacationCapability(),
          CapabilityIdentifier.jmapMdn: MdnCapability()
        }
      )
    },
    {
      CapabilityIdentifier.jmapSubmission: AccountFixtures.aliceAccountId,
      CapabilityIdentifier.jmapWebSocket: AccountFixtures.aliceAccountId,
      CapabilityIdentifier.jmapCore: AccountFixtures.aliceAccountId,
      CapabilityIdentifier.jmapMail: AccountFixtures.aliceAccountId,
      CapabilityIdentifier(Uri.parse('urn:apache:james:params:jmap:mail:quota')): AccountFixtures.aliceAccountId,
      CapabilityIdentifier(Uri.parse('urn:apache:james:params:jmap:mail:shares')): AccountFixtures.aliceAccountId,
      CapabilityIdentifier.jmapVacationResponse: AccountFixtures.aliceAccountId,
      CapabilityIdentifier.jmapMdn: AccountFixtures.aliceAccountId,
    },
    UserName('alice@domain.tld'),
    Uri.parse('http://domain.com/jmap'),
    Uri.parse('http://domain.com/download/{accountId}/{blobId}/?type={type}&name={name}'),
    Uri.parse('http://domain.com/upload/{accountId}'),
    Uri.parse('http://domain.com/eventSource?types={types}&closeAfter={closeafter}&ping={ping}'),
    State('2c9f1b12-b35a-43e6-9af2-0106fb53a943')
  );
}

// --- End Fixtures ---

class ManualMockHttpClient implements HttpClient {
  int postCallCount = 0;
  final Map<int, dynamic> _responses = {};

  void setResponse(int callIndex, dynamic response) {
    _responses[callIndex] = response;
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
    final response = _responses[postCallCount];
    postCallCount++;
    if (response is Map<String, dynamic>) {
       return response;
    }
    return <String, dynamic>{};
  }
  
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}


class TestBatchSetEmailProcessing
    with HandleSetErrorMixin, MailAPIMixin, BatchSetEmailProcessingMixin {}

void main() {
  group('BatchSetEmailProcessingMixin test', () {
    late ManualMockHttpClient httpClient;
    late TestBatchSetEmailProcessing testMixin;

    setUp(() {
      httpClient = ManualMockHttpClient();
      testMixin = TestBatchSetEmailProcessing();
      httpClient.postCallCount = 0; // Explicit reset or ensure new instance
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

      // Mock response for 3 batches (10, 10, 5)
      // Call 0: 10 success
      httpClient.setResponse(0, {
          "sessionState": "session_state",
          "methodResponses": [
            [
              "Email/set",
              {
                "accountId": AccountFixtures.aliceAccountId.id.value,
                "oldState": "oldState",
                "newState": "newState",
                "updated": {
                  for (var i = 0; i < 10; i++) "email_$i": null
                }
              },
              "c0"
            ]
          ]
        });
        
      // Call 1: 10 success
      httpClient.setResponse(1, {
          "sessionState": "session_state",
          "methodResponses": [
            [
              "Email/set",
              {
                  "accountId": AccountFixtures.aliceAccountId.id.value,
                "oldState": "oldState",
                "newState": "newState",
                "updated": {
                  for (var i = 10; i < 20; i++) "email_$i": null
                }
              },
              "c0"
            ]
          ]
        });

      // Call 2: 5 success
      httpClient.setResponse(2, {
          "sessionState": "session_state",
          "methodResponses": [
            [
              "Email/set",
              {
                  "accountId": AccountFixtures.aliceAccountId.id.value,
                "oldState": "oldState",
                "newState": "newState",
                "updated": {
                  for (var i = 20; i < 25; i++) "email_$i": null
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
        onGenerateUpdates: (batchIds) => {
          for (final id in batchIds) id.id: PatchObject({})
        },
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

      // Batch 1: Success (0-9)
      httpClient.setResponse(0, {
            "sessionState": "session_state",
            "methodResponses": [
              [
                "Email/set",
                {
                  "accountId": AccountFixtures.aliceAccountId.id.value,
                  "oldState": "oldState",
                  "newState": "newState",
                  "updated": {
                    for (var i = 0; i < 10; i++) "email_$i": null
                  }
                },
                "c0"
              ]
            ]
          });
          
      // Batch 2: Partial failure (10-19, 19 fails)
      httpClient.setResponse(1, {
            "sessionState": "session_state",
            "methodResponses": [
              [
                "Email/set",
                {
                  "accountId": AccountFixtures.aliceAccountId.id.value,
                  "oldState": "oldState",
                  "newState": "newState",
                  "updated": {
                     for (var i = 10; i < 19; i++) "email_$i": null
                  },
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
        onGenerateUpdates: (batchIds) => {
          for (final id in batchIds) id.id: PatchObject({})
        },
      );

      expect(result.emailIdsSuccess.length, 19);
      expect(result.mapErrors.length, 1);
      expect(result.mapErrors[Id('email_19')], isNotNull);
      expect(httpClient.postCallCount, 2);
    });
    test('executeBatchSetEmail should handle null response gracefully from a batch', () async {
      const maxObjects = 10;
      final session =
          SessionFixtures.getAliceSessionWithMaxObjectsInSet(maxObjects);
      const totalEmails = 20; // 2 batches
      final List<EmailId> emailIds = List<EmailId>.generate(
          totalEmails, (index) => EmailId(Id('email_$index')));

      // Batch 1: Success (0-9)
      httpClient.setResponse(0, {
        "sessionState": "session_state",
        "methodResponses": [
          [
            "Email/set",
            {
              "accountId": AccountFixtures.aliceAccountId.id.value,
              "oldState": "oldState",
              "newState": "newState",
              "updated": {
                for (var i = 0; i < 10; i++) "email_$i": null
              }
            },
            "c0"
          ]
        ]
      });

      // Batch 2: Null response (simulated by mismatching methodCallId)
      // Request uses 'c0' (default in tests usually), so we return 'c999'
      // This causes response.parse('c0') to not find the response and should return null.
      httpClient.setResponse(1, {
        "sessionState": "session_state",
        "methodResponses": [
          [
            "Email/set",
            {
               "accountId": AccountFixtures.aliceAccountId.id.value,
               "oldState": "oldState",
               "newState": "newState",
               "updated": {}
            },
            "c999" // Mismatched ID
          ]
        ]
      });

      final result = await testMixin.executeBatchSetEmail(
        session: session,
        accountId: AccountFixtures.aliceAccountId,
        emailIds: emailIds,
        httpClient: httpClient,
        onGenerateUpdates: (batchIds) => {
          for (final id in batchIds) id.id: PatchObject({})
        },
      );

      // Should have processed 10 successfully from first batch
      expect(result.emailIdsSuccess.length, 10);
      // And 0 from second batch (silently ignored/logged)
      expect(result.mapErrors, isEmpty);
      expect(httpClient.postCallCount, 2);
    });

    test('executeBatchSetEmail should handle exact match of maxObjectsInSet boundary', () async {
      const maxObjects = 10;
      final session =
          SessionFixtures.getAliceSessionWithMaxObjectsInSet(maxObjects);
      const totalEmails = 20; // Exactly 2 batches
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
              "updated": {
                for (var i = 0; i < 10; i++) "email_$i": null
              }
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
              "oldState": "oldState",
              "newState": "newState",
              "updated": {
                for (var i = 10; i < 20; i++) "email_$i": null
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
        onGenerateUpdates: (batchIds) => {
          for (final id in batchIds) id.id: PatchObject({})
        },
      );

      expect(result.emailIdsSuccess.length, 20);
      expect(result.mapErrors, isEmpty);
      expect(httpClient.postCallCount, 2);
    });
  });
}
