import 'dart:ui';

import 'package:forward/forward/tmail_forward.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/delete_email_rule_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/identities_response.dart';

abstract class ManageAccountDataSource {
  Future<IdentitiesResponse> getAllIdentities(AccountId accountId, {Properties? properties});

  Future<Identity> createNewIdentity(AccountId accountId, CreateNewIdentityRequest identityRequest);

  Future<bool> deleteIdentity(AccountId accountId, IdentityId identityId);

  Future<bool> editIdentity(AccountId accountId, EditIdentityRequest editIdentityRequest);

  Future<void> persistLanguage(Locale localeCurrent);

  Future<List<TMailRule>> getAllTMailRule(AccountId accountId);

  Future<List<TMailRule>> deleteTMailRule(AccountId accountId, DeleteEmailRuleRequest deleteEmailRuleRequest);

  Future<List<TMailRule>> createNewEmailRuleFilter(AccountId accountId, CreateNewEmailRuleFilterRequest ruleFilterRequest);

  Future<List<TMailRule>> editEmailRuleFilter(AccountId accountId, EditEmailRuleFilterRequest ruleFilterRequest);

  Future<TMailForward> getForward(AccountId accountId);

  Future<List<VacationResponse>> getAllVacationResponse(AccountId accountId);
}