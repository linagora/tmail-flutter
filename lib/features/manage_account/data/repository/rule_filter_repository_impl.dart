
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/rule_filter_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/delete_email_rule_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/rule_filter_repository.dart';

class RuleFilterRepositoryImpl extends RuleFilterRepository {

  final RuleFilterDataSource dataSource;

  RuleFilterRepositoryImpl(this.dataSource);

  @override
  Future<List<TMailRule>> getAllTMailRule(AccountId accountId) {
    return dataSource.getAllTMailRule(accountId);
  }

  @override
  Future<List<TMailRule>> deleteTMailRule(AccountId accountId, DeleteEmailRuleRequest deleteEmailRuleRequest) {
    return dataSource.deleteTMailRule(accountId, deleteEmailRuleRequest);
  }

  @override
  Future<List<TMailRule>> createNewEmailRuleFilter(AccountId accountId, CreateNewEmailRuleFilterRequest ruleFilterRequest) {
    return dataSource.createNewEmailRuleFilter(accountId, ruleFilterRequest);
  }

  @override
  Future<List<TMailRule>> editEmailRuleFilter(AccountId accountId, EditEmailRuleFilterRequest ruleFilterRequest) {
    return dataSource.editEmailRuleFilter(accountId, ruleFilterRequest);
  }
}