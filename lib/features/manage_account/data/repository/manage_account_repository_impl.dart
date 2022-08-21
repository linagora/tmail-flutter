import 'dart:ui';

import 'package:forward/forward/tmail_forward.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/manage_account_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/add_recipients_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/delete_email_rule_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/delete_recipient_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_local_copy_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/identities_response.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';

class ManageAccountRepositoryImpl extends ManageAccountRepository {

  final ManageAccountDataSource dataSource;

  ManageAccountRepositoryImpl(this.dataSource);

  @override
  Future<IdentitiesResponse> getAllIdentities(AccountId accountId, {Properties? properties}) {
    return dataSource.getAllIdentities(accountId, properties: properties);
  }

  @override
  Future<Identity> createNewIdentity(AccountId accountId, CreateNewIdentityRequest identityRequest) {
    return dataSource.createNewIdentity(accountId, identityRequest);
  }

  @override
  Future<bool> deleteIdentity(AccountId accountId, IdentityId identityId) {
    return dataSource.deleteIdentity(accountId, identityId);
  }

  @override
  Future<bool> editIdentity(AccountId accountId, EditIdentityRequest editIdentityRequest) {
    return dataSource.editIdentity(accountId, editIdentityRequest);
  }

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
  Future<List<VacationResponse>> getAllVacationResponse(AccountId accountId) {
    return dataSource.getAllVacationResponse(accountId);
  }

  @override
  Future<List<VacationResponse>> updateVacation(AccountId accountId, VacationResponse vacationResponse) {
    return dataSource.updateVacation(accountId, vacationResponse);
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