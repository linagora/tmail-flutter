import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';

abstract class RuleFilterDataSource {
  Future<List<TMailRule>> getListTMailRule(AccountId accountId);

  Future<void> updateListTMailRule(
    List<TMailRule> listTMailRuleKeep,
    List<TMailRule> listTMailRuleUpdate,
    AccountId accountId,
  );
}
