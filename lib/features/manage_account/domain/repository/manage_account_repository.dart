import 'dart:ui';

import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/identities_response.dart';

abstract class ManageAccountRepository {
  Future<IdentitiesResponse> getAllIdentities(AccountId accountId, {Properties? properties});

  Future<Identity> createNewIdentity(AccountId accountId, CreateNewIdentityRequest identityRequest);

  Future<bool> deleteIdentity(AccountId accountId, IdentityId identityId);

  Future<bool> editIdentity(AccountId accountId, EditIdentityRequest editIdentityRequest);

  Future<void> persistLanguage(Locale localeCurrent);

  Future<List<TMailRule>> getAllTMailRule(AccountId accountId);
}