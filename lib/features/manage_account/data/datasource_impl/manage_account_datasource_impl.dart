import 'dart:ui';

import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/manage_account_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/data/network/manage_account_api.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/identities_response.dart';

class ManageAccountDataSourceImpl extends ManageAccountDataSource {

  final ManageAccountAPI manageAccountAPI;
  final LanguageCacheManager _languageCacheManager;

  ManageAccountDataSourceImpl(this.manageAccountAPI, this._languageCacheManager);

  @override
  Future<IdentitiesResponse> getAllIdentities(AccountId accountId, {Properties? properties}) {
    return Future.sync(() async {
      return await manageAccountAPI.getAllIdentities(accountId, properties: properties);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<Identity> createNewIdentity(AccountId accountId, CreateNewIdentityRequest identityRequest) {
    return Future.sync(() async {
      return await manageAccountAPI.createNewIdentity(accountId, identityRequest);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<bool> deleteIdentity(AccountId accountId, IdentityId identityId) {
    return Future.sync(() async {
      return await manageAccountAPI.deleteIdentity(accountId, identityId);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<bool> editIdentity(AccountId accountId, EditIdentityRequest editIdentityRequest) {
    return Future.sync(() async {
      return await manageAccountAPI.editIdentity(accountId, editIdentityRequest);
    }).catchError((error) {
      throw error;
    });
  }

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
}