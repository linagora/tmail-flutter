
import 'dart:convert';

import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/local/authentication_info_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
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

  IOSSharingManager(
    this._keychainSharingManager,
    this._stateCacheManager,
    this._tokenOidcCacheManager, 
    this._authenticationInfoCacheManager
  );

  bool _validateToSaveKeychain(PersonalAccount personalAccount) {
    return personalAccount.accountId != null &&
      personalAccount.userName != null &&
      personalAccount.apiUrl != null;
  }

  Future<String?> getEmailDeliveryStateFromKeychain(AccountId accountId) async {
    try {
      if (await _keychainSharingManager.isSessionExist(accountId)) {
        final keychainSharingStored = await _keychainSharingManager.getSharingSession(accountId);
        return keychainSharingStored?.emailState;
      }
      return null;
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

      final keychainSharingSession = KeychainSharingSession(
        accountId: personalAccount.accountId!,
        userName: personalAccount.userName!,
        authenticationType: personalAccount.authenticationType,
        apiUrl: personalAccount.apiUrl!,
        emailState: emailDeliveryState,
        tokenOIDC: authenticationInfo.value1,
        basicAuth: authenticationInfo.value2
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
      String? emailDeliveryState = await getEmailDeliveryStateFromKeychain(accountId);
      if (emailDeliveryState == null || emailDeliveryState.isEmpty) {
        final emailState = await _stateCacheManager.getState(
          accountId,
          userName,
          StateType.email
        );
        emailDeliveryState = emailState?.value;
      }
      return emailDeliveryState;
    } catch (e) {
      logError('IOSSharingManager::_getEmailDeliveryState:Exception: $e');
      return null;
    }
  }

  Future updateEmailDeliveryStateInKeyChain(AccountId accountId, String newEmailDeliveryState) async {
    final keychainSharingSession = await getKeychainSharingSession(accountId);
    log('IOSSharingManager::updateEmailDeliveryStateInKeyChain:keychainSharingSession: $keychainSharingSession');
    if (keychainSharingSession == null) {
      return;
    }
    final newKeychain = keychainSharingSession.updating(emailDeliveryState: newEmailDeliveryState);
    await _keychainSharingManager.save(newKeychain);
  }
}