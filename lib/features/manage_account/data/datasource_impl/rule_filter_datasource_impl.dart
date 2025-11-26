
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/rule_filter_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/network/rule_filter_api.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/delete_email_rule_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_email_rule_filter_request.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class RuleFilterDataSourceImpl extends RuleFilterDataSource {

  final RuleFilterAPI _ruleFilterAPI;
  final ExceptionThrower _exceptionThrower;

  RuleFilterDataSourceImpl(
    this._ruleFilterAPI,
    this._exceptionThrower
  );

  @override
  Future<List<TMailRule>> getAllTMailRule(AccountId accountId) {
    return Future.sync(() async {
      return await _ruleFilterAPI.getListTMailRule(accountId);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<List<TMailRule>> deleteTMailRule(AccountId accountId, DeleteEmailRuleRequest deleteEmailRuleRequest) {

    deleteEmailRuleRequest.currentEmailRules.remove(deleteEmailRuleRequest.emailRuleDelete);

    return Future.sync(() async {
      return await _ruleFilterAPI.updateListTMailRule(accountId, deleteEmailRuleRequest.currentEmailRules);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<List<TMailRule>> createNewEmailRuleFilter(AccountId accountId, CreateNewEmailRuleFilterRequest ruleFilterRequest) {
    return Future.sync(() async {
      return await _ruleFilterAPI.updateListTMailRule(accountId, ruleFilterRequest.newListTMailRules);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<List<TMailRule>> editEmailRuleFilter(AccountId accountId, EditEmailRuleFilterRequest ruleFilterRequest) {
    return Future.sync(() async {
      return await _ruleFilterAPI.updateListTMailRule(accountId, ruleFilterRequest.listTMailRulesUpdated);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }
}