import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/email/get/get_email_response.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/email/query/query_email_response.dart';
import 'package:jmap_dart_client/jmap/mail/email/search_snippet/search_snippet.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:model/extensions/email_id_extensions.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_email.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_emails_response.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';

class MockGetEmailResponse extends GetEmailResponse {
  final List<Email> emailList;

  MockGetEmailResponse(this.emailList) : super(
    AccountId(Id('abc')),
    State('123'),
    emailList,
    [],
  );
}

class MockQueryEmailResponse extends QueryEmailResponse {
  final Set<Id> idList;

  MockQueryEmailResponse(this.idList) : super(
    AccountId(Id('abc')),
    State('123'),
    false,
    UnsignedInt(0),
    idList,
    UnsignedInt(0),
    UnsignedInt(0),
  );
}

void main() {
  final baseOption  = BaseOptions(method: 'POST');
  final dio = Dio(baseOption)..options.baseUrl = 'http://domain.com/jmap';
  final dioAdapterHeaders = <String, dynamic>{
    'accept': 'application/json;jmapVersion=rfc-8621',
  };
  late DioAdapter dioAdapter;
  late HttpClient httpClient;
  late ThreadAPI threadApi;

  final sessionState = State('some-session-state');
  final state = State('some-state');
  final sinceState = State('since-state');
  final newState = State('new-state');
  final filter = EmailFilterCondition(text: 'some-text');
  final queryState = State('some-query-state');

  setUp(() {
    dioAdapter = DioAdapter(dio: dio);
    httpClient = HttpClient(dio);
    threadApi = ThreadAPI(httpClient);
  });

  group('thread api test:', () {
    group('searchEmails:', () {
      Map<String, dynamic> generateRequest({required Filter filter}) => {
        "using": [
          "urn:ietf:params:jmap:core",
          "urn:ietf:params:jmap:mail",
          "urn:apache:james:params:jmap:mail:shares",
        ],
        "methodCalls": [
          [
            "Email/query",
            {
              "accountId": AccountFixtures.aliceAccountId.id.value,
              "filter": filter.toJson(),
            },
            "c0"
          ],
          [
            "SearchSnippet/get",
            {
              "accountId": AccountFixtures.aliceAccountId.id.value,
              "filter": filter.toJson(),
              "#emailIds": {
                "resultOf": "c0",
                "name": "Email/query",
                "path": "/ids/*"
              },
            },
            "c1"
          ],
          [
            "Email/get",
            {
              "accountId": AccountFixtures.aliceAccountId.id.value,
              "#ids": {
                "resultOf": "c0",
                "name": "Email/query",
                "path": "/ids/*"
              },
            },
            "c2"
          ]
        ]
      };

      Map<String, dynamic> generateResponse({
        required List<SearchEmail> foundSearchEmails,
        required List<EmailId> notFoundEmailIds,
        ErrorMethodResponse? searchSnippetError,
      }) => {
        "sessionState": sessionState.value,
        "methodResponses": [
          [
            "Email/query",
            {
              "accountId": AccountFixtures.aliceAccountId.id.value,
              "ids": foundSearchEmails
                .map((searchEmail) => searchEmail.id?.id.value)
                .toList()
                ..addAll(notFoundEmailIds.map((emailId) => emailId.id.value)),
              "queryState": queryState.value,
              "canCalculateChanges": true,
              "position": 0,
            },
            "c0"
          ],
          if (searchSnippetError == null)
            [
              "SearchSnippet/get",
              {
                "accountId": AccountFixtures.aliceAccountId.id.value,
                "notFound": notFoundEmailIds
                  .map((emailId) => emailId.id.value)
                  .toList(),
                "state": state.value,
                "list": foundSearchEmails
                  .map((searchEmail) => SearchSnippet(
                    emailId: searchEmail.id!,
                    subject: searchEmail.searchSnippetSubject,
                    preview: searchEmail.searchSnippetPreview).toJson())
                  .toList(),
              },
              "c1"
            ]
          else
            [
              "error",
              {
                "type": searchSnippetError.type.value,
              },
              "c1"
            ],
          [
            "Email/get",
            {
              "accountId": AccountFixtures.aliceAccountId.id.value,
              "state": state.value,
              "list": foundSearchEmails
                .map((searchEmail) => searchEmail.toJson())
                .toList(),
              "notFound": notFoundEmailIds
                .map((emailId) => emailId.id.value)
                .toList(),
            },
            "c2"
          ]
        ]
      };

      test(
        'should return SearchEmailResponse including search snippets '
        'when search snippet method return values',
      () async {
        // arrange
        final searchEmail = SearchEmail(
          id: EmailId(Id('someEmailId')),
          searchSnippetSubject: 'searchSnippetSubject',
          searchSnippetPreview: 'searchSnippetPreview',
        );
        dioAdapter.onPost(
          '',
          (server) => server.reply(
            200,
            generateResponse(
              foundSearchEmails: [searchEmail],
              notFoundEmailIds: [],
            ),
          ),
          data: generateRequest(filter: filter),
        );

        // act
        final result = await threadApi.searchEmails(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          filter: filter,
        );

        // assert
        expect(
          result,
          equals(
            SearchEmailsResponse(
              searchSnippets: [
                SearchSnippet(
                  emailId: searchEmail.id!,
                  subject: searchEmail.searchSnippetSubject,
                  preview: searchEmail.searchSnippetPreview,
                ),
              ],
              emailList: [Email(id: searchEmail.id)],
              state: state
            ),
          ),
        );
      });

      test(
        'should return SearchEmailResponse without search snippets '
        'when search snippet method return error',
      () async {
        // arrange
        final searchEmail = SearchEmail(
          id: EmailId(Id('someEmailId')),
          searchSnippetSubject: 'searchSnippetSubject',
          searchSnippetPreview: 'searchSnippetPreview',
        );
        dioAdapter.onPost(
          '',
          (server) => server.reply(
            200,
            generateResponse(
              foundSearchEmails: [searchEmail],
              notFoundEmailIds: [],
              searchSnippetError: UnknownMethodResponse(),
            ),
          ),
          data: generateRequest(filter: filter),
        );

        // act
        final result = await threadApi.searchEmails(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          filter: filter,
        );

        // assert
        expect(
          result,
          equals(
            SearchEmailsResponse(
              searchSnippets: null,
              emailList: [Email(id: searchEmail.id)],
              state: state
            ),
          ),
        );
      });
    });

    group('sortEmails::test', () {
      test('Should returns emails as is when emailList is empty', () {
        final getEmailResponse = MockGetEmailResponse([]);
        final queryEmailResponse = MockQueryEmailResponse({
          Id('id1'),
          Id('id2'),
        });

        final result = threadApi.sortEmails(
          getEmailResponse: getEmailResponse,
          queryEmailResponse: queryEmailResponse,
        );

        expect(result, []);
      });

      test('Should returns emails as is when idList is empty', () {
        final getEmailResponse = MockGetEmailResponse([
          Email(id: EmailId(Id('id1'))),
          Email(id: EmailId(Id('id2'))),
        ]);
        final queryEmailResponse = MockQueryEmailResponse({});

        final result = threadApi.sortEmails(
          getEmailResponse: getEmailResponse,
          queryEmailResponse: queryEmailResponse,
        );

        expect(result, [
          Email(id: EmailId(Id('id1'))),
          Email(id: EmailId(Id('id2'))),
        ]);
      });

      test('Sorts emails according to idList', () {
        final getEmailResponse = MockGetEmailResponse([
          Email(id: EmailId(Id('id1'))),
          Email(id: EmailId(Id('id2'))),
          Email(id: EmailId(Id('id3'))),
        ]);
        final queryEmailResponse = MockQueryEmailResponse({
          Id('id2'),
          Id('id3'),
          Id('id1'),
        });

        final result = threadApi.sortEmails(
          getEmailResponse: getEmailResponse,
          queryEmailResponse: queryEmailResponse,
        );

        expect(
          result?.map((e) => e.id!.asString).toList(),
          ['id2', 'id3', 'id1'],
        );
      });

      test('Should returns null if getEmailResponse is null', () {
        const getEmailResponse = null;
        final queryEmailResponse = MockQueryEmailResponse({Id('id1')});

        final result = threadApi.sortEmails(
          getEmailResponse: getEmailResponse,
          queryEmailResponse: queryEmailResponse,
        );

        expect(result, isNull);
      });

      test('Should returns emails as is when queryEmailResponse is null', () {
        final getEmailResponse = MockGetEmailResponse([
          Email(id: EmailId(Id('id1'))),
          Email(id: EmailId(Id('id2'))),
        ]);
        const queryEmailResponse = null;

        final result = threadApi.sortEmails(
          getEmailResponse: getEmailResponse,
          queryEmailResponse: queryEmailResponse,
        );

        expect(
          result,
          [
            Email(id: EmailId(Id('id1'))),
            Email(id: EmailId(Id('id2'))),
          ],
        );
      });

      test('Should remain in original order when the emailList contains emails whose id does not appear in idList', () {
        final getEmailResponse = MockGetEmailResponse([
          Email(id: EmailId(Id('id1'))),
          Email(id: EmailId(Id('id2'))),
          Email(id: EmailId(Id('id3'))),
        ]);
        final queryEmailResponse = MockQueryEmailResponse({
          Id('id4'),
          Id('id5'),
        });

        final result = threadApi.sortEmails(
          getEmailResponse: getEmailResponse,
          queryEmailResponse: queryEmailResponse,
        );

        expect(
          result?.map((e) => e.id!.asString).toList(),
          ['id1', 'id2', 'id3'],
        );
      });

      test(
        'Should still be sorted according to the ids that are present in emailList\n'
        'when idList contains ids that do not match any in emailList',
      () {
        final getEmailResponse = MockGetEmailResponse([
          Email(id: EmailId(Id('id1'))),
          Email(id: EmailId(Id('id2'))),
        ]);
        final queryEmailResponse = MockQueryEmailResponse({
          Id('id1'),
          Id('id2'),
          Id('id3'),
        });

        final result = threadApi.sortEmails(
          getEmailResponse: getEmailResponse,
          queryEmailResponse: queryEmailResponse,
        );

        expect(
          result?.map((e) => e.id!.asString).toList(),
          ['id1', 'id2'],
        );
      });

      test(
        'When both emailList and idList have ids that do not match\n'
        'only the emails whose ids appear in both lists are sorted according to the order in idList\n'
        'and emails that are not in idList are preserved in their original positions in the final list',
      () {
        final getEmailResponse = MockGetEmailResponse([
          Email(id: EmailId(Id('id1'))),
          Email(id: EmailId(Id('id2'))),
          Email(id: EmailId(Id('id3'))),
          Email(id: EmailId(Id('id4'))),
        ]);
        final queryEmailResponse = MockQueryEmailResponse({
          Id('id3'),
          Id('id1'),
        });

        final result = threadApi.sortEmails(
          getEmailResponse: getEmailResponse,
          queryEmailResponse: queryEmailResponse,
        );

        expect(
          result?.map((e) => e.id!.asString).toList(),
          ['id3', 'id1', 'id2', 'id4'],
        );
      });
    });

    group('getChanges:', () {
      int emailSize = 10;

      final createdEmailIds = List.generate(
        emailSize,
        (index) => EmailId(Id('created_$index')),
      );

      final updatedEmailIds = List.generate(
        emailSize,
        (index) => EmailId(Id('updated_$index')),
      );

      final destroyedEmailIds = List.generate(
        emailSize,
        (index) => EmailId(Id('destroyed_$index')),
      );

      final createdEmails = List.generate(
        emailSize,
        (index) => Email(
          id: EmailId(Id('created_$index')),
          subject: 'Subject $index',
          preview: 'Preview $index',
        ),
      );

      final updatedEmails = List.generate(
        emailSize,
        (index) => Email(
          id: EmailId(Id('updated_$index')),
          keywords: {
            KeyWordIdentifier.emailSeen: true,
          },
          mailboxIds: {
            MailboxId(Id('inbox-id')): true,
          },
        ),
      );

      final defaultCreatedProperties = Properties({
        'subject',
        'preview',
      });

      final defaultUpdatedProperties = Properties({
        'mailboxIds',
        'keywords',
      });

      // Helper to generate Email/changes request
      Map<String, dynamic> generateChangesRequest() => {
        "using": [
          "urn:ietf:params:jmap:core",
          "urn:ietf:params:jmap:mail",
          "urn:apache:james:params:jmap:mail:shares"
        ],
        "methodCalls": [
          [
            "Email/changes",
            {
              "accountId": AccountFixtures.aliceAccountId.asString,
              "sinceState": sinceState.value,
            },
            "c0"
          ],
        ],
      };

      // Helper to generate Email/changes response
      Map<String, dynamic> generateChangesResponse({
        List<EmailId>? created,
        List<EmailId>? updated,
        List<EmailId>? destroyed,
        bool hasMoreChanges = false,
      }) => {
        "sessionState": sessionState.value,
        "methodResponses": [
          [
            "Email/changes",
            {
              "accountId": AccountFixtures.aliceAccountId.asString,
              "oldState": sinceState.value,
              "newState": newState.value,
              "hasMoreChanges": hasMoreChanges,
              "created": (created ?? createdEmailIds)
                  .map((emailId) => emailId.id.value)
                  .toList(),
              "updated": (updated ?? updatedEmailIds)
                  .map((emailId) => emailId.id.value)
                  .toList(),
              "destroyed": (destroyed ?? destroyedEmailIds)
                  .map((emailId) => emailId.id.value)
                  .toList(),
            },
            "c0"
          ],
        ]
      };

      // Helper to generate Email/get request for specific IDs
      Map<String, dynamic> generateEmailGetRequest({
        required List<EmailId> emailIds,
        required Properties properties,
      }) => {
        "using": [
          "urn:ietf:params:jmap:core",
          "urn:ietf:params:jmap:mail",
          "urn:apache:james:params:jmap:mail:shares"
        ],
        "methodCalls": [
          [
            "Email/get",
            {
              "accountId": AccountFixtures.aliceAccountId.asString,
              "ids": emailIds.map((id) => id.id.value).toList(),
              "properties": properties.value.toList(),
            },
            "c0"
          ],
        ],
      };

      // Helper to generate Email/get response
      Map<String, dynamic> generateEmailGetResponse({
        required List<Email> emails,
        List<EmailId>? notFoundIds,
      }) => {
        "sessionState": sessionState.value,
        "methodResponses": [
          [
            "Email/get",
            {
              "accountId": AccountFixtures.aliceAccountId.asString,
              "state": newState.value,
              "list": emails.map((email) => email.toJson()).toList(),
              "notFound": (notFoundIds ?? [])
                  .map((emailId) => emailId.id.value)
                  .toList(),
            },
            "c0"
          ],
        ]
      };

      test(
        'should make separate requests for Email/changes and Email/get '
        'and return created, updated, destroyed emails',
      () async {
        // arrange
        // First request: Email/changes
        dioAdapter.onPost(
          '',
          (server) => server.reply(200, generateChangesResponse()),
          data: generateChangesRequest(),
          headers: dioAdapterHeaders,
        );

        // Second request: Email/get for updated emails
        dioAdapter.onPost(
          '',
          (server) => server.reply(
            200,
            generateEmailGetResponse(emails: updatedEmails),
          ),
          data: generateEmailGetRequest(
            emailIds: updatedEmailIds,
            properties: defaultUpdatedProperties,
          ),
          headers: dioAdapterHeaders,
        );

        // Third request: Email/get for created emails
        dioAdapter.onPost(
          '',
          (server) => server.reply(
            200,
            generateEmailGetResponse(emails: createdEmails),
          ),
          data: generateEmailGetRequest(
            emailIds: createdEmailIds,
            properties: defaultCreatedProperties,
          ),
          headers: dioAdapterHeaders,
        );

        // act
        final result = await threadApi.getChanges(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          sinceState,
          propertiesCreated: defaultCreatedProperties,
          propertiesUpdated: defaultUpdatedProperties,
        );

        // assert
        expect(result.created, equals(createdEmails));
        expect(result.updated, equals(updatedEmails));
        expect(result.destroyed, equals(destroyedEmailIds));
        expect(result.newStateChanges, equals(newState));
        expect(result.hasMoreChanges, isFalse);
      });

      test(
        'should return only destroyed emails '
        'when both created and updated properties are absent',
      () async {
        // arrange
        dioAdapter.onPost(
          '',
          (server) => server.reply(200, generateChangesResponse()),
          data: generateChangesRequest(),
          headers: dioAdapterHeaders,
        );

        // act
        final result = await threadApi.getChanges(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          sinceState,
        );

        // assert
        expect(result.created, isNull);
        expect(result.updated, isNull);
        expect(result.destroyed, equals(destroyedEmailIds));
        expect(result.newStateChanges, equals(newState));
      });

      test(
        'should add notFound IDs to destroyed list '
        'when Email/get returns notFound',
      () async {
        // arrange
        final notFoundIds = [
          EmailId(Id('created_8')),
          EmailId(Id('created_9')),
        ];
        final foundEmails = createdEmails.sublist(0, 8);

        dioAdapter.onPost(
          '',
          (server) => server.reply(200, generateChangesResponse()),
          data: generateChangesRequest(),
          headers: dioAdapterHeaders,
        );

        dioAdapter.onPost(
          '',
          (server) => server.reply(
            200,
            generateEmailGetResponse(
              emails: foundEmails,
              notFoundIds: notFoundIds,
            ),
          ),
          data: generateEmailGetRequest(
            emailIds: createdEmailIds,
            properties: defaultCreatedProperties,
          ),
          headers: dioAdapterHeaders,
        );

        // act
        final result = await threadApi.getChanges(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          sinceState,
          propertiesCreated: defaultCreatedProperties,
        );

        // assert
        expect(result.created, equals(foundEmails));
        expect(
          result.destroyed,
          equals([...destroyedEmailIds, ...notFoundIds]),
        );
      });

      test(
        'should limit created emails fetched when maxCreatedEmailsToFetch is specified',
      () async {
        // arrange
        const maxToFetch = 3;
        final limitedCreatedIds = createdEmailIds.sublist(0, maxToFetch);
        final limitedCreatedEmails = createdEmails.sublist(0, maxToFetch);

        dioAdapter.onPost(
          '',
          (server) => server.reply(200, generateChangesResponse()),
          data: generateChangesRequest(),
          headers: dioAdapterHeaders,
        );

        dioAdapter.onPost(
          '',
          (server) => server.reply(
            200,
            generateEmailGetResponse(emails: limitedCreatedEmails),
          ),
          data: generateEmailGetRequest(
            emailIds: limitedCreatedIds,
            properties: defaultCreatedProperties,
          ),
          headers: dioAdapterHeaders,
        );

        // act
        final result = await threadApi.getChanges(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          sinceState,
          propertiesCreated: defaultCreatedProperties,
          maxCreatedEmailsToFetch: maxToFetch,
        );

        // assert
        expect(result.created?.length, equals(maxToFetch));
        expect(result.created, equals(limitedCreatedEmails));
      });

      test(
        'should not limit when maxCreatedEmailsToFetch is greater than actual IDs',
      () async {
        // arrange
        const maxToFetch = 100; // More than we have

        dioAdapter.onPost(
          '',
          (server) => server.reply(200, generateChangesResponse()),
          data: generateChangesRequest(),
          headers: dioAdapterHeaders,
        );

        dioAdapter.onPost(
          '',
          (server) => server.reply(
            200,
            generateEmailGetResponse(emails: createdEmails),
          ),
          data: generateEmailGetRequest(
            emailIds: createdEmailIds,
            properties: defaultCreatedProperties,
          ),
          headers: dioAdapterHeaders,
        );

        // act
        final result = await threadApi.getChanges(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          sinceState,
          propertiesCreated: defaultCreatedProperties,
          maxCreatedEmailsToFetch: maxToFetch,
        );

        // assert
        expect(result.created?.length, equals(emailSize));
        expect(result.created, equals(createdEmails));
      });

      test(
        'should return empty created list when no created IDs',
      () async {
        // arrange
        dioAdapter.onPost(
          '',
          (server) => server.reply(
            200,
            generateChangesResponse(created: []),
          ),
          data: generateChangesRequest(),
          headers: dioAdapterHeaders,
        );

        // act
        final result = await threadApi.getChanges(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          sinceState,
          propertiesCreated: defaultCreatedProperties,
        );

        // assert
        expect(result.created, isNull);
      });
    });

    group('getChanges batching:', () {
      // These tests verify that when there are many IDs,
      // they are fetched in batches respecting maxObjectsInGet

      test(
        'should fetch all created emails in single batch when count is below maxObjectsInGet',
      () async {
        // Generate 12 IDs - will be fetched in one batch since maxObjectsInGet=50
        final largeCreatedIds = List.generate(
          12,
          (index) => EmailId(Id('batch_created_$index')),
        );
        final largeCreatedEmails = List.generate(
          12,
          (index) => Email(
            id: EmailId(Id('batch_created_$index')),
            subject: 'Subject $index',
          ),
        );

        final properties = Properties({'subject'});

        // Email/changes request - use specific request matcher
        dioAdapter.onPost(
          '',
          (server) => server.reply(200, {
            "sessionState": sessionState.value,
            "methodResponses": [
              [
                "Email/changes",
                {
                  "accountId": AccountFixtures.aliceAccountId.asString,
                  "oldState": "batch-since",
                  "newState": "batch-new",
                  "hasMoreChanges": false,
                  "created": largeCreatedIds.map((id) => id.id.value).toList(),
                  "updated": <String>[],
                  "destroyed": <String>[],
                },
                "c0"
              ],
            ]
          }),
          data: {
            "using": [
              "urn:ietf:params:jmap:core",
              "urn:ietf:params:jmap:mail",
              "urn:apache:james:params:jmap:mail:shares"
            ],
            "methodCalls": [
              [
                "Email/changes",
                {
                  "accountId": AccountFixtures.aliceAccountId.asString,
                  "sinceState": "batch-since",
                },
                "c0"
              ],
            ],
          },
          headers: dioAdapterHeaders,
        );

        // Email/get request - use specific request matcher
        dioAdapter.onPost(
          '',
          (server) => server.reply(200, {
            "sessionState": sessionState.value,
            "methodResponses": [
              [
                "Email/get",
                {
                  "accountId": AccountFixtures.aliceAccountId.asString,
                  "state": "batch-new",
                  "list": largeCreatedEmails.map((e) => e.toJson()).toList(),
                  "notFound": <String>[],
                },
                "c0"
              ],
            ]
          }),
          data: {
            "using": [
              "urn:ietf:params:jmap:core",
              "urn:ietf:params:jmap:mail",
              "urn:apache:james:params:jmap:mail:shares"
            ],
            "methodCalls": [
              [
                "Email/get",
                {
                  "accountId": AccountFixtures.aliceAccountId.asString,
                  "ids": largeCreatedIds.map((id) => id.id.value).toList(),
                  "properties": properties.value.toList(),
                },
                "c0"
              ],
            ],
          },
          headers: dioAdapterHeaders,
        );

        // act
        final result = await threadApi.getChanges(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          State('batch-since'),
          propertiesCreated: properties,
        );

        // assert
        expect(result.created?.length, equals(12));
        expect(result.newStateChanges, equals(State('batch-new')));
      });
    });
  });
}
