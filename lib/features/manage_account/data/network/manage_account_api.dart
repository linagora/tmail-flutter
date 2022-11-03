import 'dart:async';

import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:rule_filter/rule_filter/get/get_rule_filter_method.dart';
import 'package:rule_filter/rule_filter/get/get_rule_filter_response.dart';
import 'package:rule_filter/rule_filter/rule_filter_id.dart';
import 'package:rule_filter/rule_filter/set/set_rule_filter_method.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/manage_account/data/extensions/list_tmail_rule_extensions.dart';

class ManageAccountAPI {

  final HttpClient _httpClient;

  ManageAccountAPI(this._httpClient);

  Future<List<TMailRule>> getListTMailRule(AccountId accountId) async {
    final processingInvocation = ProcessingInvocation();
    final requestBuilder = JmapRequestBuilder(_httpClient, processingInvocation);

    final getRuleFilterMethod = GetRuleFilterMethod(
        accountId,
    )..addIds({RuleFilterIdSingleton.ruleFilterIdSingleton.id});

    final getRuleFilterInvocation = requestBuilder.invocation(getRuleFilterMethod);
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

  Future<List<TMailRule>> updateListTMailRule(AccountId accountId, List<TMailRule> listTMailRule) async {

    final newListTMailRuleWithIds = listTMailRule.withIds;

    final processingInvocation = ProcessingInvocation();
    final requestBuilder = JmapRequestBuilder(_httpClient, processingInvocation);

    final setRuleFilterMethod = SetRuleFilterMethod(accountId)
      ..addUpdateRuleFilter({Id(RuleFilterIdType.singleton.value): newListTMailRuleWithIds});

    requestBuilder.invocation(setRuleFilterMethod);

    final getListTMailRuleUpdated = GetRuleFilterMethod(accountId)
      ..addIds({RuleFilterIdSingleton.ruleFilterIdSingleton.id});

    final getListTMailRuleUpdatedInvocation = requestBuilder.invocation(getListTMailRuleUpdated);

    final response = await (requestBuilder
        ..usings(getListTMailRuleUpdated.requiredCapabilities))
      .build()
      .execute();


    final result = response.parse<GetRuleFilterResponse>(
        getListTMailRuleUpdatedInvocation.methodCallId,
        GetRuleFilterResponse.deserialize);

    if (result?.list.isEmpty == true) {
      return <TMailRule>[];
    }

    return result?.list.first.rules ?? <TMailRule>[];
  }
}