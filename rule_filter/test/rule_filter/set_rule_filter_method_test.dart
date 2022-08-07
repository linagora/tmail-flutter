import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:rule_filter/rule_filter/rule_action.dart';
import 'package:rule_filter/rule_filter/rule_append_in.dart';
import 'package:rule_filter/rule_filter/rule_condition.dart';
import 'package:rule_filter/rule_filter/rule_filter_id.dart';
import 'package:rule_filter/rule_filter/rule_id.dart';
import 'package:rule_filter/rule_filter/set/set_rule_filter_method.dart';
import 'package:rule_filter/rule_filter/set/set_rule_filter_response.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';

void main() {
  group('test to json set identity method', () {
    final expectedUpdated = TMailRule(
      id: RuleId(id: Id('1')),
      name: 'My first rule',
      condition: RuleCondition(
        value: 'question',
        comparator: Comparator.contains,
        field: Field.subject,
      ),
      action: RuleAction(
        appendIn: RuleAppendIn(
          mailboxIds: [
            MailboxId(Id('42')),
          ],
        ),
      ),
    );

    test('set rule_filter method and response parsing', () async {
      final baseOption = BaseOptions(method: 'POST');
      final dio = Dio(baseOption)..options.baseUrl = 'http://domain.com';
      final dioAdapter = DioAdapter(dio: dio);
      dioAdapter.onPost(
          '/jmap',
          (server) => server.reply(200, {
                "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
                "methodResponses": [
                  [
                    "Filter/set",
                    {
                      "accountId":
                          "29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6",
                      "oldState": "-1",
                      "newState": "0",
                      "updated": {
                        "singleton": {
                          "id": "1",
                          "name": "My first rule",
                          "condition": {
                            "field": "subject",
                            "comparator": "contains",
                            "value": "question"
                          },
                          "action": {
                            "appendIn": {
                              "mailboxIds": ["42"]
                            }
                          }
                        }
                      }
                    },
                    "c0"
                  ],
                ]
              }),
          data: {
            "using": ["com:linagora:params:jmap:filter"],
            "methodCalls": [
              [
                "Filter/set",
                {
                  "accountId":
                      "29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6",
                  "update": {
                    "singleton": [
                      {
                        "id": "1",
                        "name": "My first rule",
                        "condition": {
                          "field": "subject",
                          "comparator": "contains",
                          "value": "question"
                        },
                        "action": {
                          "appendIn": {
                            "mailboxIds": ["42"]
                          }
                        }
                      }
                    ]
                  }
                },
                "c0"
              ],
            ]
          },
          headers: {
            "accept": "application/json;jmapVersion=rfc-8621",
            "content-type": "application/json; charset=utf-8",
            "content-length": 340
          });

      final setRuleFilterMethod = SetRuleFilterMethod(AccountId(Id(
          '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')))
        ..addUpdateRuleFilter({
          Id(RuleFilterIdType.singleton.value): [
            TMailRule(
              id: RuleId(id: Id('1')),
              name: 'My first rule',
              condition: RuleCondition(
                value: 'question',
                comparator: Comparator.contains,
                field: Field.subject,
              ),
              action: RuleAction(
                appendIn: RuleAppendIn(
                  mailboxIds: [
                    MailboxId(Id('42')),
                  ],
                ),
              ),
            )
          ],
        });

      final httpClient = HttpClient(dio);
      final requestBuilder =
          JmapRequestBuilder(httpClient, ProcessingInvocation());
      final setRuleFilterInvocation =
          requestBuilder.invocation(setRuleFilterMethod);
      final response = await (requestBuilder
            ..usings(setRuleFilterMethod.requiredCapabilities))
          .build()
          .execute();

      final setRuleFilterResponse = response.parse<SetRuleFilterResponse>(
          setRuleFilterInvocation.methodCallId,
          SetRuleFilterResponse.deserialize);
      expect(setRuleFilterResponse!.updated?.values,
          contains(expectedUpdated));
    });
  });
}
