import 'dart:ui';

import 'package:forward/forward/tmail_forward.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/manage_account_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/data/network/manage_account_api.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/add_recipients_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/delete_email_rule_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/delete_recipient_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_local_copy_in_forwarding_request.dart';

class ManageAccountDataSourceImpl extends ManageAccountDataSource {

  final ManageAccountAPI manageAccountAPI;
  final LanguageCacheManager _languageCacheManager;

  ManageAccountDataSourceImpl(this.manageAccountAPI, this._languageCacheManager);

  @override
  Future<void> persistLanguage(Locale localeCurrent) {
    return Future.sync(() async {
      return await _languageCacheManager.persistLanguage(localeCurrent);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<List<TMailRule>> getAllTMailRule(AccountId accountId) {
    return Future.sync(() async {
      return await manageAccountAPI.getListTMailRule(accountId);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<List<TMailRule>> deleteTMailRule(AccountId accountId, DeleteEmailRuleRequest deleteEmailRuleRequest) {

    deleteEmailRuleRequest.currentEmailRules.remove(deleteEmailRuleRequest.emailRuleDelete);

    return Future.sync(() async {
      return await manageAccountAPI.updateListTMailRule(accountId, deleteEmailRuleRequest.currentEmailRules);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<List<TMailRule>> createNewEmailRuleFilter(AccountId accountId, CreateNewEmailRuleFilterRequest ruleFilterRequest) {
    return Future.sync(() async {
      return await manageAccountAPI.updateListTMailRule(accountId, ruleFilterRequest.newListTMailRules);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<List<TMailRule>> editEmailRuleFilter(AccountId accountId, EditEmailRuleFilterRequest ruleFilterRequest) {
    return Future.sync(() async {
      return await manageAccountAPI.updateListTMailRule(accountId, ruleFilterRequest.listTMailRulesUpdated);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<TMailForward> getForward(AccountId accountId) {
    return Future.sync(() async {
      return await manageAccountAPI.getForward(accountId);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<TMailForward> deleteRecipientInForwarding(AccountId accountId, DeleteRecipientInForwardingRequest deleteRequest) {
    return Future.sync(() async {
      return await manageAccountAPI.updateForward(accountId, deleteRequest.newTMailForward);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<TMailForward> addRecipientsInForwarding(AccountId accountId, AddRecipientInForwardingRequest addRequest) {
    return Future.sync(() async {
      return await manageAccountAPI.updateForward(accountId, addRequest.newTMailForward);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<TMailForward> editLocalCopyInForwarding(AccountId accountId, EditLocalCopyInForwardingRequest editRequest) {
    return Future.sync(() async {
      return await manageAccountAPI.updateForward(accountId, editRequest.newTMailForward);
    }).catchError((error) {
      throw error;
    });
  }
}