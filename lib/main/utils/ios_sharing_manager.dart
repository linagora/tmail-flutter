
import 'dart:convert';

import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/local/authentication_info_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/oidc_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_http_client.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/state_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';
import 'package:tmail_ui_user/features/push_notification/data/extensions/keychain_sharing_session_extension.dart';
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_sharing_manager.dart';
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_sharing_session.dart';

class IOSSharingManager {
  final KeychainSharingManager _keychainSharingManager;
  final StateCacheManager _stateCacheManager;
  final TokenOidcCacheManager _tokenOidcCacheManager;
  final AuthenticationInfoCacheManager _authenticationInfoCacheManager;
  final OidcConfigurationCacheManager _oidcConfigurationCacheManager;
  final OIDCHttpClient _oidcHttpClient;

  IOSSharingManager(
    this._keychainSharingManager,
    this._stateCacheManager,
    this._tokenOidcCacheManager, 
    this._authenticationInfoCacheManager,
    this._oidcConfigurationCacheManager,
    this._oidcHttpClient,
  );

  bool _validateToSaveKeychain(PersonalAccount personalAccount) {
    return personalAccount.accountId != null &&
      personalAccount.userName != null &&
      personalAccount.apiUrl != null;
  }

  Future<String?> getEmailDeliveryStateFromKeychain(AccountId accountId) async {
    try {
      final keychainSharingStored = await getKeychainSharingSession(accountId);
      return keychainSharingStored?.emailDeliveryState;
    } catch (e) {
      logError('IOSSharingManager::_getEmailDeliveryStateFromKeychain: Exception: $e');
      return null;
    }
  }

  Future saveKeyChainSharingSession(PersonalAccount personalAccount) async {
    try {
      if (!_validateToSaveKeychain(personalAccount)) {
        logError('IOSSharingManager::saveKeyChainSharingSession: account is null');
        return Future.value(null);
      }

      Tuple2<TokenOIDC?, String?> authenticationInfo = await Future.wait(
        [
          _getTokenOidc(tokeHashId: personalAccount.id),
          _getCredentialAuthentication()
        ],
        eagerError: true
      ).then((listValue) => Tuple2(listValue[0] as TokenOIDC?, listValue[1] as String?));

      final emailDeliveryState = await _getEmailDeliveryState(
        accountId: personalAccount.accountId!,
        userName: personalAccount.userName!
      );

      final emailState = await _getEmailState(
        accountId: personalAccount.accountId!,
        userName: personalAccount.userName!
      );

      final tokenRecords = await _getTokenEndpointAndScopes();

      final keychainSharingSession = KeychainSharingSession(
        accountId: personalAccount.accountId!,
        userName: personalAccount.userName!,
        authenticationType: personalAccount.authenticationType,
        apiUrl: personalAccount.apiUrl!,
        emailState: emailState,
        emailDeliveryState: emailDeliveryState,
        tokenOIDC: authenticationInfo.value1,
        basicAuth: authenticationInfo.value2,
        tokenEndpoint: tokenRecords?.tokenEndpoint,
        oidcScopes: tokenRecords?.scopes,
      );
      log('IOSSharingManager::_saveKeyChainSharingSession: $keychainSharingSession');
      await _keychainSharingManager.save(keychainSharingSession);
    } catch (e) {
      logError('IOSSharingManager::_saveKeyChainSharingSession: Exception: $e');
    }
  }

  Future<KeychainSharingSession?> getKeychainSharingSession(AccountId accountId) async {
    try {
      if (await _keychainSharingManager.isSessionExist(accountId)) {
        final keychainSharingStored = await _keychainSharingManager.getSharingSession(accountId);
        return keychainSharingStored;
      }
      return null;
    } catch (e) {
      logError('IOSSharingManager::getKeychainSharingSession: Exception: $e');
      return null;
    }
  }

  Future<TokenOIDC?> _getTokenOidc({required String tokeHashId}) async {
    try {
      final tokenOidc = await _tokenOidcCacheManager.getTokenOidc(tokeHashId);
      log('IOSSharingManager::_getTokenOidc:tokenOidc: $tokenOidc');
      return tokenOidc;
    } catch (e) {
      logError('IOSSharingManager::_getTokenOidc:Exception: $e');
      return null;
    }
  }

  Future<String?> _getCredentialAuthentication() async {
    try {
      final credentialInfo = await _authenticationInfoCacheManager.getAuthenticationInfoStored();
      log('IOSSharingManager::_getCredentialAuthentication:credentialInfo: $credentialInfo');
      return base64Encode(utf8.encode('${credentialInfo.username}:${credentialInfo.password}'));
    } catch (e) {
      logError('IOSSharingManager::_getCredentialAuthentication:Exception: $e');
      return null;
    }
  }

  Future<String?> _getEmailDeliveryState({
    required AccountId accountId,
    required UserName userName
  }) async {
    try {
      final emailDeliveryState = await getEmailDeliveryStateFromKeychain(accountId);
      log('IOSSharingManager::_getEmailState:emailDeliveryState: $emailDeliveryState');
      return emailDeliveryState;
    } catch (e) {
      logError('IOSSharingManager::_getEmailDeliveryState:Exception: $e');
      return null;
    }
  }

  Future<String?> _getEmailState({
    required AccountId accountId,
    required UserName userName
  }) async {
    try {
      final emailState = await _stateCacheManager.getState(
        accountId,
        userName,
        StateType.email
      );
      log('IOSSharingManager::_getEmailState:emailState: $emailState');
      return emailState?.value;
    } catch (e) {
      logError('IOSSharingManager::_getEmailState:Exception: $e');
      return null;
    }
  }

  Future<({String? tokenEndpoint, List<String>? scopes})?> _getTokenEndpointAndScopes() async {
    try {
      final oidcConfig = await _oidcConfigurationCacheManager.getOidcConfiguration();
      final oidcDiscoveryResponse = await _oidcHttpClient.discoverOIDC(oidcConfig);
      log('IOSSharingManager::_getTokenEndpointAndScopes:oidcDiscoveryResponse = $oidcDiscoveryResponse | oidcConfig = $oidcConfig');
      return (
        tokenEndpoint: oidcDiscoveryResponse.tokenEndpoint,
        scopes: oidcConfig.scopes
      );
    } catch (e) {
      logError('IOSSharingManager::_getTokenEndpointAndScopes:Exception: $e');
      return null;
    }
  }

  Future updateEmailStateInKeyChain(AccountId accountId, String newEmailState) async {
    final keychainSharingStored = await getKeychainSharingSession(accountId);
    log('IOSSharingManager::updateEmailStateInKeyChain:keychainSharingStored: $keychainSharingStored | newEmailState: $newEmailState');
    if (keychainSharingStored == null) {
      return;
    }
    final newKeychain = keychainSharingStored.updating(emailState: newEmailState);
    await _keychainSharingManager.save(newKeychain);
  }
}