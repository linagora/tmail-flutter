import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:rule_filter/rule_filter/get/get_rule_filter_method.dart';
import 'package:rule_filter/rule_filter/get/get_rule_filter_response.dart';
import 'package:rule_filter/rule_filter/rule_filter_id.dart';
import 'package:rule_filter/rule_filter/set/set_rule_filter_method.dart';
import 'package:rule_filter/rule_filter/set/set_rule_filter_response.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';

class RuleFilterAPI {
  final HttpClient _httpClient;

  RuleFilterAPI(this._httpClient);

  Future<List<TMailRule>> getListTMailRule(AccountId accountId) async {
    final processingInvocation = ProcessingInvocation();
    final requestBuilder =
        JmapRequestBuilder(_httpClient, processingInvocation);

    final getRuleFilterMethod = GetRuleFilterMethod(
      accountId,
    );

    final getRuleFilterInvocation =
        requestBuilder.invocation(getRuleFilterMethod);
    final response = await (requestBuilder
          ..usings(getRuleFilterMethod.requiredCapabilities))
        .build()
        .execute();

    final result = response.parse<GetRuleFilterResponse>(
        getRuleFilterInvocation.methodCallId,
        GetRuleFilterResponse.deserialize);

    if (result?.list.isEmpty == true) {
      return <TMailRule>[];
    }

    return result?.list.first.rules ?? <TMailRule>[];
  }

  Future<SetRuleFilterResponse?> updateListTMailRule(
      List<TMailRule> listTMailRule, AccountId accountId) async {
    final processingInvocation = ProcessingInvocation();
    final requestBuilder =
        JmapRequestBuilder(_httpClient, processingInvocation);

    final setRuleFilterMethod = SetRuleFilterMethod(accountId)
      ..addUpdateRuleFilter(
        {Id(RuleFilterIdType.singleton.value): listTMailRule},
      );

    final setRuleFilterInvocation =
        requestBuilder.invocation(setRuleFilterMethod);
    final response = await (requestBuilder
          ..usings(setRuleFilterMethod.requiredCapabilities))
        .build()
        .execute();

    final result = response.parse<SetRuleFilterResponse>(
        setRuleFilterInvocation.methodCallId,
        SetRuleFilterResponse.deserialize);

    return result;
  }
}
