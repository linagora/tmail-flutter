import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/email/get/get_email_response.dart';
import 'package:jmap_dart_client/jmap/mail/email/query/query_email_response.dart';
import 'package:jmap_dart_client/jmap/mail/email/search_snippet/search_snippet.dart';
import 'package:model/extensions/email_id_extensions.dart';
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
  final dioAdapter = DioAdapter(dio: dio);
  final httpClient = HttpClient(dio);
  final threadApi = ThreadAPI(httpClient);

  final sessionState = State('some-session-state');
  final state = State('some-state');
  final filter = EmailFilterCondition(text: 'some-text');
  final queryState = State('some-query-state');

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
  });
}