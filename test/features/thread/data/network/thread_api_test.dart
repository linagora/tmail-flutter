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
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
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

    group('deleteEmailsBaseOnQuery:', () {
      Map<String, dynamic> generateDeleteRequest({
        required List<String> emailIds,
        Filter? filter,
      }) => {
        'methodCalls': [
          [
            'Email/query',
            {
              'accountId': AccountFixtures.aliceAccountId.id.value,
              if (filter != null) 'filter': filter.toJson(),
            },
            'c0'
          ],
          [
            'Email/set',
            {
              'accountId': AccountFixtures.aliceAccountId.id.value,
              '#destroy': {
                'resultOf': 'c0',
                'name': 'Email/query',
                'path': '/ids/*'
              }
            },
            'c1'
          ]
        ],
        'using': [
          'urn:ietf:params:jmap:mail',
          'urn:ietf:params:jmap:core'
        ],
      };

      test('should send correct JMAP request structure', () async {
        final emailIds = ['email1', 'email2'];
        final expectedRequest = generateDeleteRequest(
          emailIds: emailIds
        );
        
        dioAdapter.onPost(
          '',
          (server) => server.reply(
            200,
            {
              "sessionState": sessionState.value,
              "methodResponses": [
                [
                  "Email/query",
                  {
                    "accountId": AccountFixtures.aliceAccountId.id.value,
                    "ids": emailIds,
                    "queryState": queryState.value,
                    "canCalculateChanges": true,
                    "position": 0,
                  },
                  "c0"
                ],
                [
                  "Email/set",
                  {
                    "accountId": AccountFixtures.aliceAccountId.id.value,
                    "destroyed": emailIds,
                    "notDestroyed": null
                  },
                  "c1"
                ]
              ]
            },
          ),
          queryParameters: {},
          data: expectedRequest,
          headers: {
            "accept": "application/json;jmapVersion=rfc-8621",
            "content-length": 589,
          }
        );

        await threadApi.deleteEmailsBaseOnQuery(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
        );
      });

      test('should return true when all emails are successfully deleted', () async {
        final emailIds = ['email1', 'email2'];
        
        dioAdapter.onPost(
          '',
          (server) => server.reply(
            200,
            {
              "sessionState": sessionState.value,
              "methodResponses": [
                [
                  "Email/query",
                  {
                    "accountId": AccountFixtures.aliceAccountId.id.value,
                    "ids": emailIds,
                    "queryState": queryState.value,
                    "canCalculateChanges": false,
                    "position": 0,
                  },
                  "c0"
                ],
                [
                  "Email/set",
                  {
                    "accountId": AccountFixtures.aliceAccountId.id.value,
                    "destroyed": emailIds
                  },
                  "c1"
                ]
              ]
            },
          ),
          data: {
          "methodCalls": [
            [
              "Email/query",
              {
                "accountId": AccountFixtures.aliceAccountId.id.value,
                "filter": {
                  "inMailbox": "025b0580-6422-11ef-a702-5d10e1ebf1c3"
                },
                "sort": [
                  {
                    "isAscending": false,
                    "property": "receivedAt"
                  }
                ]
              },
              "c0"
            ],
            [
              "Email/set",
              {
                "accountId": AccountFixtures.aliceAccountId.id.value,
                "#destroy": {
                  "resultOf": "c0",
                  "name": "Email/query",
                  "path": "/ids/*"
                }
              },
              "c1"
            ]
          ],
          "using": [
            "urn:ietf:params:jmap:core",
            "urn:ietf:params:jmap:mail"
          ],
        },
          headers: {
            "accept": "application/json;jmapVersion=rfc-8621",
            "content-length": 589,
          }
        );

        final result = await threadApi.deleteEmailsBaseOnQuery(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
        );

        expect(result.isSuccess, isTrue);
        expect(result.deletedCount, equals(2));
      });

      test('should return true when some emails are not found but others deleted successfully', () async {
        final emailIds = ['email1', 'email2', 'email3'];
        
        dioAdapter.onPost(
          '',
          (server) => server.reply(
            200,
            {
              "sessionState": sessionState.value,
              "methodResponses": [
                [
                  "Email/query",
                  {
                    "accountId": AccountFixtures.aliceAccountId.id.value,
                    "ids": emailIds,
                    "queryState": queryState.value,
                    "canCalculateChanges": true,
                    "position": 0,
                  },
                  "c0"
                ],
                [
                  "Email/set",
                  {
                    "accountId": AccountFixtures.aliceAccountId.id.value,
                    "destroyed": ['email1', 'email3'],
                    "notDestroyed": {
                      "email2": {
                        "type": "notFound",
                        "description": "email not found"
                      }
                    }
                  },
                  "c1"
                ]
              ]
            },
          ),
          data: {
            "methodCalls": [
              [
                "Email/query",
                {
                  "accountId": AccountFixtures.aliceAccountId.id.value,
                  "filter": {
                    "inMailbox": "025b0580-6422-11ef-a702-5d10e1ebf1c3"
                  }
                },
                "c0"
              ],
              [
                "Email/set",
                {
                  "accountId": AccountFixtures.aliceAccountId.id.value,
                  "#destroy": {
                    "resultOf": "c0",
                    "name": "Email/query",
                    "path": "/ids/*"
                  }
                },
                "c1"
              ]
            ],
            "using": [
              "urn:ietf:params:jmap:mail",
              "urn:ietf:params:jmap:core"
            ],
          },
          headers: {
            "accept": "application/json;jmapVersion=rfc-8621",
            "content-length": 679,
          }
        );

        final result = await threadApi.deleteEmailsBaseOnQuery(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          filter: EmailFilterCondition(
            inMailbox: MailboxId(Id('025b0580-6422-11ef-a702-5d10e1ebf1c3')), 
          )
        );

        expect(result.isSuccess, isTrue);
        expect(result.deletedCount, equals(3));
      });

      test('should return false when some emails fail to delete for reasons other than not found', () async {
        final emailIds = ['email1', 'email2', 'email3'];
        
        dioAdapter.onPost(
          '',
          (server) => server.reply(
            200,
            {
              "sessionState": sessionState.value,
              "methodResponses": [
                [
                  "Email/query",
                  {
                    "accountId": AccountFixtures.aliceAccountId.id.value,
                    "ids": emailIds,
                    "queryState": queryState.value,
                    "canCalculateChanges": true,
                    "position": 0,
                  },
                  "c0"
                ],
                [
                  "Email/set",
                  {
                    "accountId": AccountFixtures.aliceAccountId.id.value,
                    "destroyed": ['email1'],
                    "notDestroyed": {
                      "email2": {
                        "type": "forbidden",
                        "description": "no permission to delete"
                      },
                      "email3": {
                        "type": "notFound",
                        "description": "email not found"
                      }
                    }
                  },
                  "c1"
                ]
              ]
            },
          ),
          data: {
            "methodCalls": [
              [
                "Email/query",
                {
                  "accountId": AccountFixtures.aliceAccountId.id.value,
                  "filter": {
                    "inMailbox": "025b0580-6422-11ef-a702-5d10e1ebf1c3"
                  },
                },
                "c0"
              ],
              [
                "Email/set",
                {
                  "accountId": AccountFixtures.aliceAccountId.id.value,
                  "#destroy": {
                    "resultOf": "c0",
                    "name": "Email/query",
                    "path": "/ids/*"
                  }
                },
                "c1"
              ]
            ],
            "using": [
              "urn:ietf:params:jmap:mail",
              "urn:ietf:params:jmap:core",
            ],
          },
          headers: {
            "accept": "application/json;jmapVersion=rfc-8621",
            "content-length": 679,
          }
        );

        final result = await threadApi.deleteEmailsBaseOnQuery(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          filter: EmailFilterCondition(
            inMailbox: MailboxId(Id('025b0580-6422-11ef-a702-5d10e1ebf1c3')), 
          )
        );

        expect(result.isSuccess, isFalse);
        expect(result.deletedCount, equals(2));
      });
    });
  });
}
