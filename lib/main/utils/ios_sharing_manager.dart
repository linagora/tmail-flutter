
import 'dart:convert';

import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/extensions/mailbox_extension.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/local/authentication_info_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/oidc_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_http_client.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/mailbox_cache_manager.dart';
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
  final MailboxCacheManager _mailboxCacheManager;

  IOSSharingManager(
    this._keychainSharingManager,
    this._stateCacheManager,
    this._tokenOidcCacheManager, 
    this._authenticationInfoCacheManager,
    this._oidcConfigurationCacheManager,
    this._oidcHttpClient,
    this._mailboxCacheManager,
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

  Future<void> saveKeyChainSharingSession(PersonalAccount personalAccount) async {
    log('IOSSharingManager::saveKeyChainSharingSession: START');
    try {
      if (!_validateToSaveKeychain(personalAccount)) {
        logError('IOSSharingManager::saveKeyChainSharingSession: AccountId | Username | ApiUrl is NULL');
        return Future.value(null);
      }

      TokenOIDC? tokenOIDC;
      String? credentialInfo;

      if (personalAccount.authenticationType == AuthenticationType.oidc) {
        tokenOIDC = await _getTokenOidc(tokeHashId: personalAccount.id);
      } else {
        credentialInfo = await _getCredentialAuthentication();
      }

      final emailDeliveryState = await _getEmailDeliveryState(
        accountId: personalAccount.accountId!,
        userName: personalAccount.userName!
      );

      final emailState = await _getEmailState(
        accountId: personalAccount.accountId!,
        userName: personalAccount.userName!
      );

      final tokenRecords = await _getTokenEndpointScopesAndIsTWP();

      final mailboxIdsBlockNotification = await _getMailboxIdsBlockNotification(
        accountId: personalAccount.accountId!,
        userName: personalAccount.userName!);

      final keychainSharingSession = KeychainSharingSession(
        accountId: personalAccount.accountId!,
        userName: personalAccount.userName!,
        authenticationType: personalAccount.authenticationType,
        apiUrl: personalAccount.apiUrl!,
        emailState: emailState,
        emailDeliveryState: emailDeliveryState,
        tokenOIDC: tokenOIDC,
        basicAuth: credentialInfo,
        tokenEndpoint: tokenRecords?.tokenEndpoint,
        oidcScopes: tokenRecords?.scopes,
        mailboxIdsBlockNotification: mailboxIdsBlockNotification,
        isTWP: tokenRecords?.isTWP ?? false,
      );

      await _keychainSharingManager.save(keychainSharingSession);

      log('IOSSharingManager::_saveKeyChainSharingSession: COMPLETED');
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
      return await _tokenOidcCacheManager.getTokenOidc(tokeHashId);
    } catch (e) {
      logError('IOSSharingManager::_getTokenOidc:Exception: $e');
      return null;
    }
  }

  Future<String?> _getCredentialAuthentication() async {
    try {
      final credentialInfo = await _authenticationInfoCacheManager.getAuthenticationInfoStored();
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
      return await getEmailDeliveryStateFromKeychain(accountId);
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

  Future<({String? tokenEndpoint, List<String>? scopes, bool isTWP})?> _getTokenEndpointScopesAndIsTWP() async {
    try {
      final oidcConfig = await _oidcConfigurationCacheManager.getOidcConfiguration();
      final oidcDiscoveryResponse = await _oidcHttpClient.discoverOIDC(oidcConfig);
      return (
        tokenEndpoint: oidcDiscoveryResponse.tokenEndpoint,
        scopes: oidcConfig.scopes,
        isTWP: oidcConfig.isTWP,
      );
    } catch (e) {
      logError('IOSSharingManager::_getTokenEndpointAndScopes:Exception: $e');
      return null;
    }
  }

  Future updateEmailStateInKeyChain(AccountId accountId, String newEmailState) async {
    final keychainSharingStored = await getKeychainSharingSession(accountId);
    if (keychainSharingStored == null) {
      return;
    }
    final newKeychain = keychainSharingStored.updating(emailState: newEmailState);
    await _keychainSharingManager.save(newKeychain);
  }

  Future<bool> isExistMailboxIdsBlockNotificationInKeyChain(AccountId accountId) async {
    try {
      final keychainSharingStored = await getKeychainSharingSession(accountId);
      return keychainSharingStored?.mailboxIdsBlockNotification?.isNotEmpty == true;
    } catch (e) {
      logError('IOSSharingManager::getMailboxIdsBlockNotificationInKeyChain:Exception = $e');
      return false;
    }
  }

  Future<void> updateMailboxIdsBlockNotificationInKeyChain({
    required AccountId accountId,
    required List<MailboxId> mailboxIds
  }) async {
    try {
      final keychainSharingStored = await getKeychainSharingSession(accountId);
      if (keychainSharingStored == null) {
        return;
      }
      final newKeychain = keychainSharingStored.updating(mailboxIdsBlockNotification: mailboxIds);
      await _keychainSharingManager.save(newKeychain);
    } catch (e) {
      logError('IOSSharingManager::updateMailboxIdsBlockNotificationInKeyChain: Exception = $e');
    }
  }

  Future<List<MailboxId>?> _getMailboxIdsBlockNotification({
    required AccountId accountId,
    required UserName userName,
  }) async {
    try {
      final mailboxesCache = await _mailboxCacheManager.getAllMailbox(accountId, userName);
      final listMailboxIdBlockNotification = mailboxesCache
        .where((mailbox) => mailbox.pushNotificationDeactivated && mailbox.id != null)
        .map((mailbox) => mailbox.id!)
        .toList();
      log('IOSSharingManager::_getMailboxIdsBlockNotification(): CACHE_MAILBOX_LIST = $listMailboxIdBlockNotification');
      return listMailboxIdBlockNotification;
    } catch (e) {
      logError('IOSSharingManager::_getMailboxIdsBlockNotification:Exception: $e');
      return null;
    }
  }
}