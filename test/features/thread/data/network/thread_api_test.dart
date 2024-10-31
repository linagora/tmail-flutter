import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/email/search_snippet/search_snippet.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_email.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_emails_response.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';

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
  });
}