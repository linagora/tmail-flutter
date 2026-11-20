import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/core/error/error_type.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/error/method/exception/error_method_response_exception.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_api.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/role_extension.dart';
import 'package:uuid/uuid.dart';

import '../../../fixtures/account_fixtures.dart';
import '../../../fixtures/session_fixtures.dart';

import 'mailbox_api_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<HttpClient>(),
  MockSpec<Uuid>()
])
void main() {
  group('MailboxAPI::', () {
    late HttpClient httpClient;
    late Uuid uuid;
    late MailboxAPI mailboxAPI;

    final accountId = AccountFixtures.aliceAccountId;
    final session = SessionFixtures.aliceSession;

    final mapRoles = <Id, Role>{
      Id('sent-create-id'): PresentationMailbox.roleSent,
      Id('outbox-create-id'): PresentationMailbox.roleOutbox,
    };

    setUp(() {
      httpClient = MockHttpClient();
      uuid = MockUuid();

      mailboxAPI = MailboxAPI(httpClient, uuid);
    });

    group('createDefaultMailbox::', () {
      test('Should return full mailbox with input is a list roles when create mailbox success', () async {
        final mapResponseData = {
          "methodResponses": [
            [
              "Mailbox/set",
              {
                "oldState": "105",
                "newState": "107",
                "created": {
                  "sent-create-id": {
                    "id": "sent-id",
                    "myRights": {
                      "mayReadItems": true,
                      "mayAddItems": true,
                      "mayRemoveItems": true,
                      "mayCreateChild": true,
                      "mayDelete": true,
                      "maySubmit": true,
                      "maySetSeen": true,
                      "maySetKeywords": true,
                      "mayAdmin": true,
                      "mayRename": true
                    },
                    "totalEmails": 0,
                    "unreadEmails": 0,
                    "totalThreads": 0,
                    "unreadThreads": 0,
                    "isSeenShared": false,
                    "sortOrder": 10,
                    "showAsLabel": true
                  },
                  "outbox-create-id": {
                    "id": "outbox-id",
                    "myRights": {
                      "mayReadItems": true,
                      "mayAddItems": true,
                      "mayRemoveItems": true,
                      "mayCreateChild": true,
                      "mayDelete": true,
                      "maySubmit": true,
                      "maySetSeen": true,
                      "maySetKeywords": true,
                      "mayAdmin": true,
                      "mayRename": true
                    },
                    "totalEmails": 0,
                    "unreadEmails": 0,
                    "totalThreads": 0,
                    "unreadThreads": 0,
                    "isSeenShared": false,
                    "sortOrder": 10,
                    "showAsLabel": true
                  }
                },
                "updated": null,
                "destroyed": null,
                "notCreated": null,
                "notUpdated": null,
                "notDestroyed": null,
                "accountId": accountId.asString,
              },
              "c0"
            ]
          ],
          "sessionState": "0"
        };

        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => mapResponseData);

        final mailboxRecords = await mailboxAPI.createDefaultMailbox(
          session,
          accountId,
          mapRoles,
        );

        final listMailbox = mailboxRecords.$1;
        final mapErrors = mailboxRecords.$2;

        verify(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        ));
        expect(listMailbox.length, mapRoles.length);
        expect(mapErrors.isEmpty, isTrue);
        expect(
          listMailbox.any((mailbox) => mailbox.name!.name == PresentationMailbox.roleSent.mailboxName),
          isTrue,
        );
        expect(
          listMailbox.any((mailbox) => mailbox.name!.name == PresentationMailbox.roleOutbox.mailboxName),
          isTrue,
        );
      });

      test('Should return some mailbox list with input is a list roles when create mailbox fail', () async {
        final mapResponseData = {
          "methodResponses": [
            [
              "Mailbox/set",
              {
                "oldState": "105",
                "newState": "107",
                "created": {
                  "sent-create-id": {
                    "id": "sent-id",
                    "myRights": {
                      "mayReadItems": true,
                      "mayAddItems": true,
                      "mayRemoveItems": true,
                      "mayCreateChild": true,
                      "mayDelete": true,
                      "maySubmit": true,
                      "maySetSeen": true,
                      "maySetKeywords": true,
                      "mayAdmin": true,
                      "mayRename": true
                    },
                    "totalEmails": 0,
                    "unreadEmails": 0,
                    "totalThreads": 0,
                    "unreadThreads": 0,
                    "isSeenShared": false,
                    "sortOrder": 10,
                    "showAsLabel": true
                  }
                },
                "updated": null,
                "destroyed": null,
                "notCreated": {
                  "outbox-create-id": {
                    "type": "invalidProperties",
                    "properties": [
                      "role"
                    ]
                  }
                },
                "notUpdated": null,
                "notDestroyed": null,
                "accountId": accountId.asString,
              },
              "c0"
            ]
          ],
          "sessionState": "0"
        };

        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => mapResponseData);

        final mailboxRecords = await mailboxAPI.createDefaultMailbox(
          session,
          accountId,
          mapRoles,
        );

        final listMailbox = mailboxRecords.$1;
        final mapErrors = mailboxRecords.$2;

        verify(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        ));

        expect(listMailbox.length, lessThan(mapRoles.length));
        expect(mapErrors.isNotEmpty, isTrue);
        expect(
          listMailbox.any((mailbox) => mailbox.name?.name == PresentationMailbox.roleSent.mailboxName),
          isTrue,
        );
        expect(
          listMailbox.every((mailbox) => mailbox.name?.name != PresentationMailbox.roleOutbox.mailboxName),
          isTrue,
        );
      });

      test('Should throw exception when http client throw exception', () async {
        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenThrow(Exception());

        expect(
          () => mailboxAPI.createDefaultMailbox(session, accountId, mapRoles),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('setRoleDefaultMailbox::', () {
      final listMailbox = <Mailbox>[
        Mailbox(
          id: MailboxId(Id('sent-id')),
          name: MailboxName(PresentationMailbox.roleSent.mailboxName),
          role: PresentationMailbox.roleSent,
          isSubscribed: IsSubscribed(true),
        ) ,
        Mailbox(
          id: MailboxId(Id('outbox-id')),
          name: MailboxName(PresentationMailbox.roleOutbox.mailboxName),
          role: PresentationMailbox.roleOutbox,
          isSubscribed: IsSubscribed(true),
        )
      ];

      test('Should return full mailbox with role when update role mailbox success', () async {
        final mapResponseData = {
          "methodResponses": [
            [
              "Mailbox/set",
              {
                "oldState": "105",
                "newState": "107",
                "created": null,
                "updated": {
                  'sent-id': null,
                  'outbox-id': null
                },
                "destroyed": null,
                "notCreated": null,
                "notUpdated": null,
                "notDestroyed": null,
                "accountId": accountId.asString,
              },
              "c0"
            ]
          ],
          "sessionState": "0"
        };

        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => mapResponseData);

        final mailboxRecords = await mailboxAPI.setRoleDefaultMailbox(
          session,
          accountId,
          listMailbox,
        );

        final newListMailbox = mailboxRecords.$1;
        final mapErrors = mailboxRecords.$2;

        verify(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        ));
        expect(newListMailbox.length, listMailbox.length);
        expect(mapErrors.isEmpty, isTrue);
        expect(
          newListMailbox.any((mailbox) => mailbox.role == PresentationMailbox.roleSent),
          isTrue,
        );
        expect(
          newListMailbox.any((mailbox) => mailbox.role == PresentationMailbox.roleOutbox),
          isTrue,
        );
      });

      test('Should return some mailbox with role when update role mailbox fail', () async {
        final mapResponseData = {
          "methodResponses": [
            [
              "Mailbox/set",
              {
                "oldState": "105",
                "newState": "107",
                "created": null,
                "updated": {
                  'sent-id': null
                },
                "destroyed": null,
                "notCreated": null,
                "notUpdated": {
                  "outbox-id": {
                    "type": "invalidProperties",
                    "properties": [
                      "role"
                    ]
                  }
                },
                "notDestroyed": null,
                "accountId": accountId.asString,
              },
              "c0"
            ]
          ],
          "sessionState": "0"
        };

        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => mapResponseData);

        final mailboxRecords = await mailboxAPI.setRoleDefaultMailbox(
          session,
          accountId,
          listMailbox,
        );

        final newListMailbox = mailboxRecords.$1;
        final mapErrors = mailboxRecords.$2;

        verify(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        ));

        expect(newListMailbox.length,listMailbox.length);
        expect(mapErrors.isNotEmpty, isTrue);
        expect(
          newListMailbox.any((mailbox) => mailbox.role == PresentationMailbox.roleSent),
          isTrue,
        );
        expect(
          newListMailbox.every((mailbox) => mailbox.role != PresentationMailbox.roleOutbox),
          isTrue,
        );
      });

      test('Should throw exception when http client throw exception', () async {
        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenThrow(Exception());

        expect(
          () => mailboxAPI.setRoleDefaultMailbox(session, accountId, listMailbox),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getMailboxByRole::', () {
      List<Object> errorInvocation(ErrorType type, String methodCallId) =>
          ["error", {"type": type.value}, methodCallId];

      void serverAnswers(List<Object> query, List<Object> get) {
        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => {
          "methodResponses": [query, get],
          "sessionState": "0",
        });
      }

      test('Should return the mailbox Mailbox/get finds for the role', () async {
        serverAnswers(
          ["Mailbox/query", {
            "accountId": accountId.asString,
            "queryState": "1",
            "canCalculateChanges": false,
            "position": 0,
            "ids": ["sent-id"],
          }, "c0"],
          ["Mailbox/get", {
            "accountId": accountId.asString,
            "state": "1",
            "list": [{"id": "sent-id", "role": "sent"}],
            "notFound": [],
          }, "c1"],
        );

        final result = await mailboxAPI.getMailboxByRole(session, accountId, PresentationMailbox.roleSent);

        expect(result.mailbox?.id, MailboxId(Id('sent-id')));
      });

      test('Should throw the Mailbox/query error '
          'when Mailbox/get fails only because it references the failed Mailbox/query', () async {
        serverAnswers(
          errorInvocation(ErrorMethodResponse.accountNotFound, "c0"),
          errorInvocation(ErrorMethodResponse.invalidResultReference, "c1"),
        );

        await expectLater(
          mailboxAPI.getMailboxByRole(session, accountId, PresentationMailbox.roleSent),
          throwsA(isA<ErrorMethodResponseException>().having(
            (exception) => exception.errorResponse,
            'errorResponse',
            isA<AccountNotFoundMethodResponse>(),
          )),
        );
      });
    });

    group('clearMailbox method test', () {
      final trashMailboxId = MailboxId(Id('trash-id'));
      final notFoundMailboxId = MailboxId(Id('notFoundMailboxId'));

      test('Should return totalDeletedMessagesCount when clear mailbox success', () async {
        final mapResponseData = {
          "methodResponses": [
            [
              "Mailbox/clear",
              {
                "accountId": accountId.asString,
                "totalDeletedMessagesCount": 10,
              },
              "c0"
            ]
          ],
          "sessionState": "0"
        };

        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => mapResponseData);

        final result = await mailboxAPI.clearMailbox(
          session,
          accountId,
          trashMailboxId,
        );

        verify(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        ));

        expect(result.value, 10);
      });

      test('Should return notCleared when clear mailbox fail with mailbox id not found', () async {
        final mapResponseData = {
          "methodResponses": [
            [
              "Mailbox/clear",
              {
                "accountId": accountId.asString,
                "notCleared": {
                 "type": "notFound",
                 "description": "${notFoundMailboxId.id.value} can not be found"
                }
              },
              "c0"
            ]
          ],
          "sessionState": "0"
        };

        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => mapResponseData);

        expect(
          () => mailboxAPI.clearMailbox(session, accountId, notFoundMailboxId),
          throwsA(isA<SetError>()),
        );
      });

      test('Should throw exception when http client throw exception', () async {
        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenThrow(Exception());

        expect(
          () => mailboxAPI.clearMailbox(session, accountId, trashMailboxId),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
