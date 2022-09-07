
import 'package:flutter/foundation.dart';
import 'package:tmail_ui_user/features/caching/account_cache_client.dart';
import 'package:tmail_ui_user/features/caching/authentication_info_cache_client.dart';
import 'package:tmail_ui_user/features/caching/email_cache_client.dart';
import 'package:tmail_ui_user/features/caching/encryption_key_cache_client.dart';
import 'package:tmail_ui_user/features/caching/mailbox_cache_client.dart';
import 'package:tmail_ui_user/features/caching/recent_search_cache_client.dart';
import 'package:tmail_ui_user/features/caching/state_cache_client.dart';
import 'package:tmail_ui_user/features/caching/token_oidc_cache_client.dart';

class CachingManager {

  final MailboxCacheClient _mailboxCacheClient;
  final StateCacheClient _stateCacheClient;
  final EmailCacheClient _emailCacheClient;
  final RecentSearchCacheClient _recentSearchCacheClient;
  final TokenOidcCacheClient _tokenOidcCacheClient;
  final AccountCacheClient _accountCacheClient;
  final EncryptionKeyCacheClient _encryptionKeyCacheClient;
  final AuthenticationInfoCacheClient _authenticationInfoCacheClient;

  CachingManager(
    this._mailboxCacheClient,
    this._stateCacheClient,
    this._emailCacheClient,
    this._recentSearchCacheClient,
    this._tokenOidcCacheClient,
    this._accountCacheClient,
    this._encryptionKeyCacheClient,
    this._authenticationInfoCacheClient,
  );

  Future<void> clearAll() async {
    if (kIsWeb) {
      await Future.wait([
        _stateCacheClient.clearAllData(),
        _mailboxCacheClient.clearAllData(),
        _emailCacheClient.clearAllData(),
        _recentSearchCacheClient.clearAllData(),
        _tokenOidcCacheClient.clearAllData(),
        _accountCacheClient.clearAllData(),
        _encryptionKeyCacheClient.clearAllData(),
        _authenticationInfoCacheClient.clearAllData(),
      ]);
    } else {
      await Future.wait([
        _stateCacheClient.deleteBox(),
        _mailboxCacheClient.deleteBox(),
        _emailCacheClient.deleteBox(),
        _recentSearchCacheClient.deleteBox(),
        _tokenOidcCacheClient.deleteBox(),
        _accountCacheClient.deleteBox(),
        _encryptionKeyCacheClient.deleteBox(),
        _authenticationInfoCacheClient.deleteBox(),
      ]);
    }
  }
}