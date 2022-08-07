import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:rule_filter/get/get_rule_filter_method.dart';
import 'package:rule_filter/get/get_rule_filter_response.dart';
import 'package:rule_filter/rule_action.dart';
import 'package:rule_filter/rule_append_in.dart';
import 'package:rule_filter/rule_condition.dart';
import 'package:rule_filter/rule_filter.dart';
import 'package:rule_filter/rule_filter_id.dart';
import 'package:rule_filter/tmail_rule.dart';

void main() {
  group('test to json get rule filter method', () {
    final expectRuleFilter1 = RuleFilter(
      id: RuleFilterIdSingleton.ruleFilterIdSingleton,
      rules: [
        TMailRule(
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
    );

    test('get rule_filter method and response parsing', () async {
      final baseOption = BaseOptions(method: 'POST');
      final dio = Dio(baseOption)..options.baseUrl = 'http://domain.com';
      final dioAdapter = DioAdapter(dio: dio);
      dioAdapter.onPost(
          '/jmap',
          (server) => server.reply(200, {
                "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
                "methodResponses": [
                  [
                    "Filter/get",
                    {
                      "accountId":
                          "29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6",
                      "state": "0",
                      "list": [
                        {
                          "id": "singleton",
                          "rules": [
                            {
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
                      ],
                      "notFound": []
                    },
                    "c0"
                  ]
                ]
              }),
          data: {
            "using": ["com:linagora:params:jmap:filter"],
            "methodCalls": [
              [
                "Filter/get",
                {
                  "accountId":
                      "29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6",
                  "ids": ["singleton"]
                },
                "c0"
              ]
            ]
          },
          headers: {
            "accept": "application/json;jmapVersion=rfc-8621",
            "content-type": "application/json; charset=utf-8",
            "content-length": 182
          });

      final httpClient = HttpClient(dio);
      final processingInvocation = ProcessingInvocation();
      final requestBuilder =
          JmapRequestBuilder(httpClient, processingInvocation);
      final accountId = AccountId(Id(
          '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6'));

      final getRuleFilterMethod = GetRuleFilterMethod(accountId)
        ..addIds({RuleFilterIdSingleton.ruleFilterIdSingleton.id});
      final getRuleFilterInvocation =
          requestBuilder.invocation(getRuleFilterMethod);
      final response = await (requestBuilder
            ..usings(getRuleFilterMethod.requiredCapabilities))
          .build()
          .execute();

      final resultList = response.parse<GetRuleFilterResponse>(
          getRuleFilterInvocation.methodCallId,
          GetRuleFilterResponse.deserialize);

      expect(resultList?.list.length, equals(1));
      expect(resultList?.list, containsAll({expectRuleFilter1}));
    });
  });
}
