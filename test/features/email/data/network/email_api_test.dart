import 'package:collection/collection.dart';
import 'package:core/data/network/dio_client.dart';
import 'package:core/data/network/download/download_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:uuid/uuid.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'email_api_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<HttpClient>(),
  MockSpec<DownloadManager>(),
  MockSpec<DioClient>(),
  MockSpec<Uuid>(),
])
void main() {
  group('EmailAPI::test', () {
    late HttpClient httpClient;
    late DownloadManager downloadManager;
    late DioClient dioClient;
    late Uuid uuid;
    late EmailAPI emailApi;

    setUp(() {
      httpClient = MockHttpClient();
      downloadManager = MockDownloadManager();
      dioClient = MockDioClient();
      uuid = MockUuid();

      emailApi = EmailAPI(
        httpClient,
        downloadManager,
        dioClient,
        uuid,
      );
    });

    group('markAsRead::test', () {
      test(
        'SHOULD calls execute the correct number of times\n'
        'WHEN maxObjectsInSet equal defaultMaxObjectsInSet\n'
        'AND defaultMaxObjectsInSet is 50',
      () async {
        // Arrange
        const defaultMaxObjectsInSet = 50;
        const maxObjectsInSet = 50;
        const totalEmails = 100;
        final maxBatches = [maxObjectsInSet, defaultMaxObjectsInSet, totalEmails].min;
        final countIterations = (totalEmails / maxBatches).ceil();
        final aliceSession = SessionFixtures.getAliceSessionWithMaxObjectsInSet(maxObjectsInSet);

        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "Email/set",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "oldState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "newState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "updated": {
                  for (var item in List.generate(maxBatches, (index) => {"email_$index": null}))
                    item.keys.first: item.values.first
                }
              },
              "c0"
            ],
            [
              "Email/get",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "state": "b965db40-c11c-11ef-9cfb-ef2eae0e64b1",
                "list": List.generate(maxBatches, (index) => {
                  "id": "email_$index",
                  "keywords": {
                    "\$seen": true
                  }
                }),
                "notFound": []
              },
              "c1"
            ]
          ]
        });

        final emailIds = List.generate(
          totalEmails,
          (index) => EmailId(Id('email_$index')),
        );

        // Act
        final result = await emailApi.markAsRead(
          aliceSession,
          AccountFixtures.aliceAccountId,
          emailIds,
          ReadActions.markAsRead,
        );

        // Assert
        verify(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).called(countIterations);
        expect(result.emailIdsSuccess.length, totalEmails);
        expect(result.mapErrors.isEmpty, isTrue);
      });

      test(
        'SHOULD calls execute the correct number of times\n'
        'WHEN maxObjectsInSet is greater than defaultMaxObjectsInSet\n'
        'AND defaultMaxObjectsInSet is 50',
      () async {
        // Arrange
        const defaultMaxObjectsInSet = 50;
        const maxObjectsInSet = 200;
        const totalEmails = 100;
        final maxBatches = [maxObjectsInSet, defaultMaxObjectsInSet, totalEmails].min;
        final countIterations = (totalEmails / maxBatches).ceil();
        final aliceSession = SessionFixtures.getAliceSessionWithMaxObjectsInSet(maxObjectsInSet);

        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "Email/set",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "oldState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "newState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "updated": {
                  for (var item in List.generate(maxBatches, (index) => {"email_$index": null}))
                    item.keys.first: item.values.first
                }
              },
              "c0"
            ],
            [
              "Email/get",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "state": "b965db40-c11c-11ef-9cfb-ef2eae0e64b1",
                "list": List.generate(maxBatches, (index) => {
                  "id": "email_$index",
                  "keywords": {
                    "\$seen": true
                  }
                }),
                "notFound": []
              },
              "c1"
            ]
          ]
        });

        final emailIds = List.generate(
          totalEmails,
          (index) => EmailId(Id('email_$index')),
        );

        // Act
        final result = await emailApi.markAsRead(
          aliceSession,
          AccountFixtures.aliceAccountId,
          emailIds,
          ReadActions.markAsRead,
        );

        // Assert
        verify(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).called(countIterations);
        expect(result.emailIdsSuccess.length, totalEmails);
        expect(result.mapErrors.isEmpty, isTrue);
      });

      test(
        'SHOULD calls execute the correct number of times\n'
        'WHEN maxObjectsInSet is less than defaultMaxObjectsInSet\n'
        'AND defaultMaxObjectsInSet is 50',
      () async {
        // Arrange
        const defaultMaxObjectsInSet = 50;
        const maxObjectsInSet = 20;
        const totalEmails = 100;
        final maxBatches = [maxObjectsInSet, defaultMaxObjectsInSet, totalEmails].min;
        final countIterations = (totalEmails / maxBatches).ceil();
        final aliceSession = SessionFixtures.getAliceSessionWithMaxObjectsInSet(maxObjectsInSet);

        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "Email/set",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "oldState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "newState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "updated": {
                  for (var item in List.generate(maxBatches, (index) => {"email_$index": null}))
                    item.keys.first: item.values.first
                }
              },
              "c0"
            ],
            [
              "Email/get",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "state": "b965db40-c11c-11ef-9cfb-ef2eae0e64b1",
                "list": List.generate(maxBatches, (index) => {
                  "id": "email_$index",
                  "keywords": {
                    "\$seen": true
                  }
                }),
                "notFound": []
              },
              "c1"
            ]
          ]
        });

        final emailIds = List.generate(
          totalEmails,
          (index) => EmailId(Id('email_$index')),
        );

        // Act
        final result = await emailApi.markAsRead(
          aliceSession,
          AccountFixtures.aliceAccountId,
          emailIds,
          ReadActions.markAsRead,
        );

        // Assert
        verify(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).called(countIterations);
        expect(result.emailIdsSuccess.length, totalEmails);
        expect(result.mapErrors.isEmpty, isTrue);
      });

      test(
        'SHOULD calls execute the correct number of times\n'
        'WHEN totalEmails is less than defaultMaxObjectsInSet\n'
        'WHEN maxObjectsInSet equal defaultMaxObjectsInSet\n'
        'AND defaultMaxObjectsInSet is 50',
      () async {
        // Arrange
        const defaultMaxObjectsInSet = 50;
        const maxObjectsInSet = 50;
        const totalEmails = 30;
        final maxBatches = [maxObjectsInSet, defaultMaxObjectsInSet, totalEmails].min;
        final countIterations = (totalEmails / maxBatches).ceil();
        final aliceSession = SessionFixtures.getAliceSessionWithMaxObjectsInSet(maxObjectsInSet);

        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "Email/set",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "oldState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "newState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "updated": {
                  for (var item in List.generate(maxBatches, (index) => {"email_$index": null}))
                    item.keys.first: item.values.first
                }
              },
              "c0"
            ],
            [
              "Email/get",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "state": "b965db40-c11c-11ef-9cfb-ef2eae0e64b1",
                "list": List.generate(maxBatches, (index) => {
                  "id": "email_$index",
                  "keywords": {
                    "\$seen": true
                  }
                }),
                "notFound": []
              },
              "c1"
            ]
          ]
        });

        final emailIds = List.generate(
          totalEmails,
          (index) => EmailId(Id('email_$index')),
        );

        // Act
        final result = await emailApi.markAsRead(
          aliceSession,
          AccountFixtures.aliceAccountId,
          emailIds,
          ReadActions.markAsRead,
        );

        // Assert
        verify(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).called(countIterations);
        expect(result.emailIdsSuccess.length, totalEmails);
        expect(result.mapErrors.isEmpty, isTrue);
      });
    });

    group('markAsStar::test', () {
      test(
        'SHOULD calls execute the correct number of times\n'
        'WHEN maxObjectsInSet equal defaultMaxObjectsInSet\n'
        'AND defaultMaxObjectsInSet is 50',
      () async {
        // Arrange
        const defaultMaxObjectsInSet = 50;
        const maxObjectsInSet = 50;
        const totalEmails = 100;
        final maxBatches = [maxObjectsInSet, defaultMaxObjectsInSet, totalEmails].min;
        final countIterations = (totalEmails / maxBatches).ceil();
        final aliceSession = SessionFixtures.getAliceSessionWithMaxObjectsInSet(maxObjectsInSet);

        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "Email/set",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "oldState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "newState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "updated": {
                  for (var item in List.generate(maxBatches, (index) => {"email_$index": null}))
                    item.keys.first: item.values.first
                }
              },
              "c0"
            ],
            [
              "Email/get",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "state": "b965db40-c11c-11ef-9cfb-ef2eae0e64b1",
                "list": List.generate(maxBatches, (index) => {
                  "id": "email_$index",
                  "keywords": {
                    "\$flagged": true
                  }
                }),
                "notFound": []
              },
              "c1"
            ]
          ]
        });

        final emailIds = List.generate(
          totalEmails,
          (index) => EmailId(Id('email_$index')),
        );

        // Act
        final result = await emailApi.markAsStar(
          aliceSession,
          AccountFixtures.aliceAccountId,
          emailIds,
          MarkStarAction.markStar,
        );

        // Assert
        verify(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).called(countIterations);
        expect(result.emailIdsSuccess.length, totalEmails);
        expect(result.mapErrors.isEmpty, isTrue);
      });

      test(
        'SHOULD calls execute the correct number of times\n'
        'WHEN maxObjectsInSet is greater than defaultMaxObjectsInSet\n'
        'AND defaultMaxObjectsInSet is 50',
      () async {
        // Arrange
        const defaultMaxObjectsInSet = 50;
        const maxObjectsInSet = 200;
        const totalEmails = 100;
        final maxBatches = [maxObjectsInSet, defaultMaxObjectsInSet, totalEmails].min;
        final countIterations = (totalEmails / maxBatches).ceil();
        final aliceSession = SessionFixtures.getAliceSessionWithMaxObjectsInSet(maxObjectsInSet);

        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "Email/set",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "oldState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "newState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "updated": {
                  for (var item in List.generate(maxBatches, (index) => {"email_$index": null}))
                    item.keys.first: item.values.first
                }
              },
              "c0"
            ],
            [
              "Email/get",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "state": "b965db40-c11c-11ef-9cfb-ef2eae0e64b1",
                "list": List.generate(maxBatches, (index) => {
                  "id": "email_$index",
                  "keywords": {
                    "\$flagged": true
                  }
                }),
                "notFound": []
              },
              "c1"
            ]
          ]
        });

        final emailIds = List.generate(
          totalEmails,
          (index) => EmailId(Id('email_$index')),
        );

        // Act
        final result = await emailApi.markAsStar(
          aliceSession,
          AccountFixtures.aliceAccountId,
          emailIds,
          MarkStarAction.markStar,
        );

        // Assert
        verify(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).called(countIterations);
        expect(result.emailIdsSuccess.length, totalEmails);
        expect(result.mapErrors.isEmpty, isTrue);
      });

      test(
        'SHOULD calls execute the correct number of times\n'
        'WHEN maxObjectsInSet is less than defaultMaxObjectsInSet\n'
        'AND defaultMaxObjectsInSet is 50',
      () async {
        // Arrange
        const defaultMaxObjectsInSet = 50;
        const maxObjectsInSet = 20;
        const totalEmails = 100;
        final maxBatches = [maxObjectsInSet, defaultMaxObjectsInSet, totalEmails].min;
        final countIterations = (totalEmails / maxBatches).ceil();
        final aliceSession = SessionFixtures.getAliceSessionWithMaxObjectsInSet(maxObjectsInSet);

        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "Email/set",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "oldState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "newState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "updated": {
                  for (var item in List.generate(maxBatches, (index) => {"email_$index": null}))
                    item.keys.first: item.values.first
                }
              },
              "c0"
            ],
            [
              "Email/get",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "state": "b965db40-c11c-11ef-9cfb-ef2eae0e64b1",
                "list": List.generate(maxBatches, (index) => {
                  "id": "email_$index",
                  "keywords": {
                    "\$flagged": true
                  }
                }),
                "notFound": []
              },
              "c1"
            ]
          ]
        });

        final emailIds = List.generate(
          totalEmails,
          (index) => EmailId(Id('email_$index')),
        );

        // Act
        final result = await emailApi.markAsStar(
          aliceSession,
          AccountFixtures.aliceAccountId,
          emailIds,
          MarkStarAction.markStar,
        );

        // Assert
        verify(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).called(countIterations);
        expect(result.emailIdsSuccess.length, totalEmails);
        expect(result.mapErrors.isEmpty, isTrue);
      });

      test(
        'SHOULD calls execute the correct number of times\n'
        'WHEN totalEmails is less than defaultMaxObjectsInSet\n'
        'WHEN maxObjectsInSet equal defaultMaxObjectsInSet\n'
        'AND defaultMaxObjectsInSet is 50',
      () async {
        // Arrange
        const defaultMaxObjectsInSet = 50;
        const maxObjectsInSet = 50;
        const totalEmails = 30;
        final maxBatches = [maxObjectsInSet, defaultMaxObjectsInSet, totalEmails].min;
        final countIterations = (totalEmails / maxBatches).ceil();
        final aliceSession = SessionFixtures.getAliceSessionWithMaxObjectsInSet(maxObjectsInSet);

        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "Email/set",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "oldState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "newState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "updated": {
                  for (var item in List.generate(maxBatches, (index) => {"email_$index": null}))
                    item.keys.first: item.values.first
                }
              },
              "c0"
            ],
            [
              "Email/get",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "state": "b965db40-c11c-11ef-9cfb-ef2eae0e64b1",
                "list": List.generate(maxBatches, (index) => {
                  "id": "email_$index",
                  "keywords": {
                    "\$flagged": true
                  }
                }),
                "notFound": []
              },
              "c1"
            ]
          ]
        });

        final emailIds = List.generate(
          totalEmails,
          (index) => EmailId(Id('email_$index')),
        );

        // Act
        final result = await emailApi.markAsStar(
          aliceSession,
          AccountFixtures.aliceAccountId,
          emailIds,
          MarkStarAction.markStar,
        );

        // Assert
        verify(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).called(countIterations);
        expect(result.emailIdsSuccess.length, totalEmails);
        expect(result.mapErrors.isEmpty, isTrue);
      });
    });

    group('deleteMultipleEmailsPermanently::test', () {
      test(
        'SHOULD calls execute the correct number of times\n'
        'WHEN maxObjectsInSet equal defaultMaxObjectsInSet\n'
        'AND defaultMaxObjectsInSet is 50',
      () async {
        // Arrange
        const defaultMaxObjectsInSet = 50;
        const maxObjectsInSet = 50;
        const totalEmails = 100;
        final maxBatches = [maxObjectsInSet, defaultMaxObjectsInSet, totalEmails].min;
        final countIterations = (totalEmails / maxBatches).ceil();
        final aliceSession = SessionFixtures.getAliceSessionWithMaxObjectsInSet(maxObjectsInSet);

        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "Email/set",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "oldState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "newState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "destroyed": List.generate(maxBatches, (index) => "email_$index")
              },
              "c0"
            ]
          ]
        });

        final emailIds = List.generate(
          totalEmails,
          (index) => EmailId(Id('email_$index')),
        );

        // Act
        final result = await emailApi.deleteMultipleEmailsPermanently(
          aliceSession,
          AccountFixtures.aliceAccountId,
          emailIds,
        );

        // Assert
        verify(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).called(countIterations);
        expect(result.emailIdsSuccess.length, totalEmails);
        expect(result.mapErrors.isEmpty, isTrue);
      });

      test(
        'SHOULD calls execute the correct number of times\n'
        'WHEN maxObjectsInSet is greater than defaultMaxObjectsInSet\n'
        'AND defaultMaxObjectsInSet is 50',
      () async {
        // Arrange
        const defaultMaxObjectsInSet = 50;
        const maxObjectsInSet = 200;
        const totalEmails = 100;
        final maxBatches = [maxObjectsInSet, defaultMaxObjectsInSet, totalEmails].min;
        final countIterations = (totalEmails / maxBatches).ceil();
        final aliceSession = SessionFixtures.getAliceSessionWithMaxObjectsInSet(maxObjectsInSet);

        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "Email/set",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "oldState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "newState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "destroyed": List.generate(maxBatches, (index) => "email_$index")
              },
              "c0"
            ]
          ]
        });

        final emailIds = List.generate(
          totalEmails,
          (index) => EmailId(Id('email_$index')),
        );

        // Act
        final result = await emailApi.deleteMultipleEmailsPermanently(
          aliceSession,
          AccountFixtures.aliceAccountId,
          emailIds,
        );

        // Assert
        verify(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).called(countIterations);
        expect(result.emailIdsSuccess.length, totalEmails);
        expect(result.mapErrors.isEmpty, isTrue);
      });

      test(
        'SHOULD calls execute the correct number of times\n'
        'WHEN maxObjectsInSet is less than defaultMaxObjectsInSet\n'
        'AND defaultMaxObjectsInSet is 50',
      () async {
        // Arrange
        const defaultMaxObjectsInSet = 50;
        const maxObjectsInSet = 20;
        const totalEmails = 100;
        final maxBatches = [maxObjectsInSet, defaultMaxObjectsInSet, totalEmails].min;
        final countIterations = (totalEmails / maxBatches).ceil();
        final aliceSession = SessionFixtures.getAliceSessionWithMaxObjectsInSet(maxObjectsInSet);

        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "Email/set",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "oldState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "newState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "destroyed": List.generate(maxBatches, (index) => "email_$index")
              },
              "c0"
            ]
          ]
        });

        final emailIds = List.generate(
          totalEmails,
          (index) => EmailId(Id('email_$index')),
        );

        // Act
        final result = await emailApi.deleteMultipleEmailsPermanently(
          aliceSession,
          AccountFixtures.aliceAccountId,
          emailIds,
        );

        // Assert
        verify(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).called(countIterations);
        expect(result.emailIdsSuccess.length, totalEmails);
        expect(result.mapErrors.isEmpty, isTrue);
      });

      test(
        'SHOULD calls execute the correct number of times\n'
        'WHEN totalEmails is less than defaultMaxObjectsInSet\n'
        'WHEN maxObjectsInSet equal defaultMaxObjectsInSet\n'
        'AND defaultMaxObjectsInSet is 50',
      () async {
        // Arrange
        const defaultMaxObjectsInSet = 50;
        const maxObjectsInSet = 50;
        const totalEmails = 30;
        final maxBatches = [maxObjectsInSet, defaultMaxObjectsInSet, totalEmails].min;
        final countIterations = (totalEmails / maxBatches).ceil();
        final aliceSession = SessionFixtures.getAliceSessionWithMaxObjectsInSet(maxObjectsInSet);

        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "Email/set",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "oldState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "newState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "destroyed": List.generate(maxBatches, (index) => "email_$index")
              },
              "c0"
            ]
          ]
        });

        final emailIds = List.generate(
          totalEmails,
          (index) => EmailId(Id('email_$index')),
        );

        // Act
        final result = await emailApi.deleteMultipleEmailsPermanently(
          aliceSession,
          AccountFixtures.aliceAccountId,
          emailIds,
        );

        // Assert
        verify(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).called(countIterations);
        expect(result.emailIdsSuccess.length, totalEmails);
        expect(result.mapErrors.isEmpty, isTrue);
      });
    });

    group('moveToMailbox::test', () {
      test(
        'SHOULD calls execute the correct number of times\n'
        'WHEN maxObjectsInSet equal defaultMaxObjectsInSet\n'
        'AND defaultMaxObjectsInSet is 50',
      () async {
        // Arrange
        const defaultMaxObjectsInSet = 50;
        const maxObjectsInSet = 50;
        const totalEmails = 100;
        final maxBatches = [maxObjectsInSet, defaultMaxObjectsInSet, totalEmails].min;
        final countIterations = (totalEmails / maxBatches).ceil();
        final aliceSession = SessionFixtures.getAliceSessionWithMaxObjectsInSet(maxObjectsInSet);

        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "Email/set",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "oldState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "newState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "updated": {
                  for (var item in List.generate(maxBatches, (index) => {"email_$index": null}))
                    item.keys.first: item.values.first
                }
              },
              "c0"
            ]
          ]
        });

        final emailIds = List.generate(
          totalEmails,
          (index) => EmailId(Id('email_$index')),
        );

        // Act
        final result = await emailApi.moveToMailbox(
          aliceSession,
          AccountFixtures.aliceAccountId,
          MoveToMailboxRequest(
            {
              MailboxId(Id('mailboxA')): emailIds,
            },
            MailboxId(Id('mailboxB')),
            MoveAction.moving,
            EmailActionType.moveToMailbox,
          ),
        );

        // Assert
        verify(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).called(countIterations);
        expect(result.emailIdsSuccess.length, totalEmails);
        expect(result.mapErrors.isEmpty, isTrue);
      });

      test(
        'SHOULD calls execute the correct number of times\n'
        'WHEN maxObjectsInSet is greater than defaultMaxObjectsInSet\n'
        'AND defaultMaxObjectsInSet is 50',
      () async {
        // Arrange
        const defaultMaxObjectsInSet = 50;
        const maxObjectsInSet = 200;
        const totalEmails = 100;
        final maxBatches = [maxObjectsInSet, defaultMaxObjectsInSet, totalEmails].min;
        final countIterations = (totalEmails / maxBatches).ceil();
        final aliceSession = SessionFixtures.getAliceSessionWithMaxObjectsInSet(maxObjectsInSet);

        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "Email/set",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "oldState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "newState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "updated": {
                  for (var item in List.generate(maxBatches, (index) => {"email_$index": null}))
                    item.keys.first: item.values.first
                }
              },
              "c0"
            ]
          ]
        });

        final emailIds = List.generate(
          totalEmails,
              (index) => EmailId(Id('email_$index')),
        );

        // Act
        final result = await emailApi.moveToMailbox(
          aliceSession,
          AccountFixtures.aliceAccountId,
          MoveToMailboxRequest(
            {
              MailboxId(Id('mailboxA')): emailIds,
            },
            MailboxId(Id('mailboxB')),
            MoveAction.moving,
            EmailActionType.moveToMailbox,
          ),
        );

        // Assert
        verify(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).called(countIterations);
        expect(result.emailIdsSuccess.length, totalEmails);
        expect(result.mapErrors.isEmpty, isTrue);
      });

      test(
        'SHOULD calls execute the correct number of times\n'
        'WHEN maxObjectsInSet is less than defaultMaxObjectsInSet\n'
        'AND defaultMaxObjectsInSet is 50',
      () async {
        // Arrange
        const defaultMaxObjectsInSet = 50;
        const maxObjectsInSet = 20;
        const totalEmails = 100;
        final maxBatches = [maxObjectsInSet, defaultMaxObjectsInSet, totalEmails].min;
        final countIterations = (totalEmails / maxBatches).ceil();
        final aliceSession = SessionFixtures.getAliceSessionWithMaxObjectsInSet(maxObjectsInSet);

        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "Email/set",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "oldState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "newState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "updated": {
                  for (var item in List.generate(maxBatches, (index) => {"email_$index": null}))
                    item.keys.first: item.values.first
                }
              },
              "c0"
            ]
          ]
        });

        final emailIds = List.generate(
          totalEmails,
          (index) => EmailId(Id('email_$index')),
        );

        // Act
        final result = await emailApi.moveToMailbox(
          aliceSession,
          AccountFixtures.aliceAccountId,
          MoveToMailboxRequest(
            {
              MailboxId(Id('mailboxA')): emailIds,
            },
            MailboxId(Id('mailboxB')),
            MoveAction.moving,
            EmailActionType.moveToMailbox,
          ),
        );

        // Assert
        verify(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).called(countIterations);
        expect(result.emailIdsSuccess.length, totalEmails);
        expect(result.mapErrors.isEmpty, isTrue);
      });

      test(
        'SHOULD calls execute the correct number of times\n'
        'WHEN totalEmails is less than defaultMaxObjectsInSet\n'
        'WHEN maxObjectsInSet equal defaultMaxObjectsInSet\n'
        'AND defaultMaxObjectsInSet is 50',
      () async {
        // Arrange
        const defaultMaxObjectsInSet = 50;
        const maxObjectsInSet = 50;
        const totalEmails = 30;
        final maxBatches = [maxObjectsInSet, defaultMaxObjectsInSet, totalEmails].min;
        final countIterations = (totalEmails / maxBatches).ceil();
        final aliceSession = SessionFixtures.getAliceSessionWithMaxObjectsInSet(maxObjectsInSet);

        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "Email/set",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "oldState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "newState": "4cb1e760-c11b-11ef-9cfb-ef2eae0e64b1",
                "updated": {
                  for (var item in List.generate(maxBatches, (index) => {"email_$index": null}))
                    item.keys.first: item.values.first
                }
              },
              "c0"
            ]
          ]
        });

        final emailIds = List.generate(
          totalEmails,
          (index) => EmailId(Id('email_$index')),
        );

        // Act
        final result = await emailApi.moveToMailbox(
          aliceSession,
          AccountFixtures.aliceAccountId,
          MoveToMailboxRequest(
            {
              MailboxId(Id('mailboxA')): emailIds,
            },
            MailboxId(Id('mailboxB')),
            MoveAction.moving,
            EmailActionType.moveToMailbox,
          ),
        );

        // Assert
        verify(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).called(countIterations);
        expect(result.emailIdsSuccess.length, totalEmails);
        expect(result.mapErrors.isEmpty, isTrue);
      });
    });
  });
}
