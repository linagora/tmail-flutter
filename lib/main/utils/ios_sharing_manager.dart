import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/features/login/data/extensions/basic_auth_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/state_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';
import 'package:tmail_ui_user/features/push_notification/data/extensions/keychain_sharing_session_extension.dart';
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_sharing_manager.dart';
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_sharing_session.dart';

class IOSSharingManager {
  final KeychainSharingManager _keychainSharingManager;
  final StateCacheManager _stateCacheManager;

  IOSSharingManager(
    this._keychainSharingManager,
    this._stateCacheManager,
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

      final emailDeliveryState = await _getEmailDeliveryState(
        accountId: personalAccount.accountId!,
        userName: personalAccount.userName!
      );

      final emailState = await _getEmailState(
        accountId: personalAccount.accountId!,
        userName: personalAccount.userName!
      );

      final keychainSharingSession = KeychainSharingSession(
        accountId: personalAccount.accountId!,
        userName: personalAccount.userName!,
        authenticationType: personalAccount.authenticationType,
        apiUrl: personalAccount.apiUrl!,
        emailState: emailState,
        emailDeliveryState: emailDeliveryState,
        tokenOIDC: personalAccount.tokenOidc,
        basicAuth: personalAccount.basicAuth?.authenticationHeader
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