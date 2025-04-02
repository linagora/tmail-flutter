import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/email/data/network/calendar_event_api.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/calendar_event_exceptions.dart';
import 'package:tmail_ui_user/features/email/presentation/model/blob_calendar_event.dart';

import '../../../../fixtures/account_fixtures.dart';
import 'calendar_event_api_test.mocks.dart';

@GenerateNiceMocks([MockSpec<HttpClient>()])
void main() {
  group('CalendarEventAPI::test', () {
    late HttpClient httpClient;
    late CalendarEventAPI calendarEventAPI;

    setUp(() {
      httpClient = MockHttpClient();
      calendarEventAPI = CalendarEventAPI(httpClient);
    });

    group('parse::test', () {
      test('SHOULD return list of BlobCalendarEvent WHEN parse method success', () async {
        final blobIds = {Id('blob_1'), Id('blob_2')};
        
        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "CalendarEvent/parse",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "parsed": {
                  "blob_1": [
                    {
                      "uid": "event1",
                      "title": "Meeting 1",
                      "start": "2024-03-20T10:00:00Z",
                      "duration": "PT1H"
                    }
                  ],
                  "blob_2": [
                    {
                      "uid": "event2",
                      "title": "Meeting 2",
                      "start": "2024-03-21T14:00:00Z",
                      "duration": "PT2H"
                    }
                  ]
                }
              },
              "c0"
            ],
            [
              "CalendarEventAttendance/get",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "list": [
                  {
                    "blobId": "blob_1",
                    "isFree": true
                  },
                  {
                    "blobId": "blob_2",
                    "isFree": false
                  }
                ]
              },
              "c1"
            ]
          ]
        });

        final result = await calendarEventAPI.parse(
          AccountFixtures.aliceAccountId,
          blobIds
        );

        verify(httpClient.post(
          '',
          data: {
            "using": [
              "urn:ietf:params:jmap:core",
              "com:linagora:params:calendar:event",
            ],
            "methodCalls": [
              [
                "CalendarEvent/parse",
                {
                  "accountId": AccountFixtures.aliceAccountId.asString,
                  "blobIds": ["blob_1", "blob_2"]
                },
                "c0"
              ],
              [
                "CalendarEventAttendance/get",
                {
                  "accountId": AccountFixtures.aliceAccountId.asString,
                  "blobIds": ["blob_1", "blob_2"]
                },
                "c1"
              ]
            ]
          },
          cancelToken: anyNamed('cancelToken'),
        )).called(1);

        expect(result, isA<List<BlobCalendarEvent>>());
        expect(result.length, 2);
        expect(result[0].blobId.value, 'blob_1');
        expect(result[0].isFree, true);
        expect(result[1].blobId.value, 'blob_2');
        expect(result[1].isFree, false);
      });

      test('SHOULD throw NotParsableCalendarEventException WHEN response has notParsable', () async {
        final blobIds = {Id('blob_1')};
        
        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "CalendarEvent/parse",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "notParsable": ["blob_1"]
              },
              "c0"
            ],
            [
              "CalendarEventAttendance/get",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "list": []
              },
              "c1"
            ]
          ]
        });

        expect(
          () => calendarEventAPI.parse(AccountFixtures.aliceAccountId, blobIds),
          throwsA(isA<NotParsableCalendarEventException>())
        );
      });

      test('SHOULD throw NotFoundCalendarEventException WHEN response has notFound', () async {
        final blobIds = {Id('blob_1')};
        
        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "CalendarEvent/parse",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "notFound": ["blob_1"]
              },
              "c0"
            ],
            [
              "CalendarEventAttendance/get",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "list": []
              },
              "c1"
            ]
          ]
        });

        expect(
          () => calendarEventAPI.parse(AccountFixtures.aliceAccountId, blobIds),
          throwsA(isA<NotFoundCalendarEventException>())
        );
      });

      test('SHOULD throw NotParsableCalendarEventException WHEN response is empty', () async {
        final blobIds = {Id('blob_1')};
        
        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "CalendarEvent/parse",
              {
                "accountId": AccountFixtures.aliceAccountId.asString
              },
              "c0"
            ],
            [
              "CalendarEventAttendance/get",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "list": []
              },
              "c1"
            ]
          ]
        });

        expect(
          () => calendarEventAPI.parse(AccountFixtures.aliceAccountId, blobIds),
          throwsA(isA<NotParsableCalendarEventException>())
        );
      });

      test('SHOULD return calendar events with default isFree value WHEN CalendarEventAttendance/get returns error', () async {
        final blobIds = {Id('blob_1')};
        
        when(httpClient.post(
          '',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenAnswer((_) async => {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "CalendarEvent/parse",
              {
                "accountId": AccountFixtures.aliceAccountId.asString,
                "parsed": {
                  "blob_1": [
                    {
                      "uid": "event1",
                      "title": "Meeting 1",
                      "start": "2024-03-20T10:00:00Z",
                      "duration": "PT1H"
                    }
                  ]
                }
              },
              "c0"
            ],
            [
              "error",
              {
                "type": "invalidArguments",
                "description": "Invalid blobIds"
              },
              "c1"
            ]
          ]
        });

        final result = await calendarEventAPI.parse(
          AccountFixtures.aliceAccountId,
          blobIds
        );

        expect(result, isA<List<BlobCalendarEvent>>());
        expect(result.length, 1);
        expect(result[0].blobId.value, 'blob_1');
        expect(result[0].isFree, true);
      });
    });
  });
}