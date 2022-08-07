import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:rule_filter/data/datasource/rule_filter_datasource.dart';
import 'package:rule_filter/data/network/rule_filter_api.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';

class RuleFilterDataSourceImpl extends RuleFilterDataSource {
  final RuleFilterAPI _ruleFilterAPI;

  RuleFilterDataSourceImpl(this._ruleFilterAPI);

  @override
  Future<List<TMailRule>> getListTMailRule(AccountId accountId) {
    return Future.sync(() async {
      final listTMailRules = await _ruleFilterAPI.getListTMailRule(accountId);
      return listTMailRules;
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> updateListTMailRule(
    List<TMailRule> listTMailRuleKeep,
    List<TMailRule> listTMailRuleUpdate,
    AccountId accountId,
  ) {
    final List<TMailRule> listTMailRule = List.empty(growable: true);
    listTMailRule.addAll(listTMailRuleUpdate);
    for (var itemTMailRuleKeep in listTMailRuleKeep) {
      if (listTMailRuleUpdate
          .where((itemTMailRuleUpdate) =>
              itemTMailRuleKeep == itemTMailRuleUpdate)
          .isNotEmpty) {
        listTMailRuleKeep.remove(itemTMailRuleKeep);
      }
    }
    listTMailRule.addAll(listTMailRuleKeep);

    return Future.sync(() async {
      await _ruleFilterAPI.updateListTMailRule(listTMailRule, accountId);
    }).catchError((error) {
      throw error;
    });
  }
}
