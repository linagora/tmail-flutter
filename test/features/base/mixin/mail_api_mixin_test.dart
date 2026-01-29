import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/method/response/set_response.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:model/error_type_handler/set_method_error_handler_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/handle_error_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/mail_api_mixin.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';

import '../../../fixtures/account_fixtures.dart';
import '../../../fixtures/session_fixtures.dart';

class TestMailApiMixin with HandleSetErrorMixin, MailAPIMixin {
  @override
  void handleSetErrors({
    SetMethodErrors? notDestroyedError,
    SetMethodErrors? notUpdatedError,
    SetMethodErrors? notCreatedError,
    Set<SetMethodErrorHandler>? notDestroyedHandlers,
    Set<SetMethodErrorHandler>? notUpdatedHandlers,
    Set<SetMethodErrorHandler>? notCreatedHandlers,
    SetMethodErrorHandler? unCatchErrorHandler,
  }) {}

  @override
  Map<Id, SetError> handleSetResponse(List<SetResponse?> listSetResponse) {
    throw UnimplementedError();
  }

  @override
  parseErrorForSetResponse(SetResponse? response, Id requestId) {
    throw UnimplementedError();
  }
}

void main() {
  final baseOption = BaseOptions(method: 'POST');
  final dio = Dio(baseOption)..options.baseUrl = 'http://domain.com/jmap';
  final dioAdapter = DioAdapter(dio: dio);
  final httpClient = HttpClient(dio);
  final testMailApiMixin = TestMailApiMixin();

  final sessionState = State('some-session-state');
  final state = State('some-state');
  final filter = EmailFilterCondition(text: 'some-text');
  final queryState = State('some-query-state');
  group('mail api mixin test:', () {
    group('fetchAllEmail:', () {
      Map<String, dynamic> generateRequest({
        required Filter filter,
        int? position,
      }) =>
          {
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
                  if (position != null) "position": position,
                  "filter": filter.toJson(),
                },
                "c0"
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
                "c1"
              ]
            ]
          };

      Map<String, dynamic> generateResponse({
        required List<Email> foundEmails,
        required List<EmailId> notFoundEmailIds,
      }) =>
          {
            "sessionState": sessionState.value,
            "methodResponses": [
              [
                "Email/query",
                {
                  "accountId": AccountFixtures.aliceAccountId.id.value,
                  "ids": foundEmails.map((email) => email.id?.id.value).toList()
                    ..addAll(
                        notFoundEmailIds.map((emailId) => emailId.id.value)),
                  "queryState": queryState.value,
                  "canCalculateChanges": true,
                  "position": 0,
                },
                "c0"
              ],
              [
                "Email/get",
                {
                  "accountId": AccountFixtures.aliceAccountId.id.value,
                  "state": state.value,
                  "list": foundEmails.map((email) => email.toJson()).toList(),
                  "notFound": notFoundEmailIds
                      .map((emailId) => emailId.id.value)
                      .toList(),
                },
                "c1"
              ]
            ]
          };

      test(
        'should not add position to request '
        'when position is null',
        () async {
          // arrange
          final email = Email(
            id: EmailId(Id('someEmailId')),
          );
          dioAdapter.onPost(
            '',
            (server) => server.reply(
              200,
              generateResponse(
                foundEmails: [email],
                notFoundEmailIds: [],
              ),
            ),
            data: generateRequest(filter: filter),
          );

          // act
          final result = await testMailApiMixin.fetchAllEmail(
            session: SessionFixtures.aliceSession,
            accountId: AccountFixtures.aliceAccountId,
            httpClient: httpClient,
            filter: filter,
          );

          // assert
          expect(
            result,
            equals(
              EmailsResponse(
                emailList: [email],
                state: state,
                notFoundEmailIds: [],
              ),
            ),
          );
        },
      );

      test(
        'should not add position to request '
        'when position is 0',
        () async {
          // arrange
          final email = Email(
            id: EmailId(Id('someEmailId')),
          );
          dioAdapter.onPost(
            '',
            (server) => server.reply(
              200,
              generateResponse(
                foundEmails: [email],
                notFoundEmailIds: [],
              ),
            ),
            data: generateRequest(filter: filter),
          );
          dioAdapter.onPost(
            '',
            (server) => server.reply(
              403,
              generateResponse(
                foundEmails: [email],
                notFoundEmailIds: [],
              ),
            ),
            data: generateRequest(filter: filter, position: 0),
          );

          // act
          final result = await testMailApiMixin.fetchAllEmail(
            session: SessionFixtures.aliceSession,
            accountId: AccountFixtures.aliceAccountId,
            httpClient: httpClient,
            filter: filter,
            position: 0,
          );

          // assert
          expect(
            result,
            equals(
              EmailsResponse(
                emailList: [email],
                state: state,
                notFoundEmailIds: [],
              ),
            ),
          );
        },
      );

      test(
        'should add position to request '
        'when position > 0',
        () async {
          // arrange
          final email = Email(
            id: EmailId(Id('someEmailId')),
          );
          dioAdapter.onPost(
            '',
            (server) => server.reply(
              200,
              generateResponse(
                foundEmails: [email],
                notFoundEmailIds: [],
              ),
            ),
            data: generateRequest(filter: filter, position: 1),
          );

          // act
          final result = await testMailApiMixin.fetchAllEmail(
            session: SessionFixtures.aliceSession,
            accountId: AccountFixtures.aliceAccountId,
            httpClient: httpClient,
            filter: filter,
            position: 1,
          );

          // assert
          expect(
            result,
            equals(
              EmailsResponse(
                emailList: [email],
                state: state,
                notFoundEmailIds: [],
              ),
            ),
          );
        },
      );
    });
  });
}
