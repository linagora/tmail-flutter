import 'dart:ui';

import 'package:forward/forward/tmail_forward.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/manage_account_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/add_recipients_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/delete_email_rule_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/delete_recipient_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_local_copy_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';

class ManageAccountRepositoryImpl extends ManageAccountRepository {

  final ManageAccountDataSource dataSource;

  ManageAccountRepositoryImpl(this.dataSource);

  @override
  Future<void> persistLanguage(Locale localeCurrent) {
    return dataSource.persistLanguage(localeCurrent);
  }

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

  @override
  Future<TMailForward> getForward(AccountId accountId) {
    return dataSource.getForward(accountId);
  }

  @override
  Future<TMailForward> deleteRecipientInForwarding(AccountId accountId, DeleteRecipientInForwardingRequest deleteRequest) {
    return dataSource.deleteRecipientInForwarding(accountId, deleteRequest);
  }

  @override
  Future<TMailForward> addRecipientsInForwarding(AccountId accountId, AddRecipientInForwardingRequest addRequest) {
    return dataSource.addRecipientsInForwarding(accountId, addRequest);
  }

  @override
  Future<TMailForward> editLocalCopyInForwarding(AccountId accountId, EditLocalCopyInForwardingRequest editRequest) {
    return dataSource.editLocalCopyInForwarding(accountId, editRequest);
  }
}