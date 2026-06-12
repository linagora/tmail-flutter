import 'package:core/domain/exceptions/app_base_exception.dart';
import 'package:core/utils/app_logger.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/caching/clients/token_oidc_cache_client.dart';
import 'package:tmail_ui_user/features/caching/interaction/cache_manager_interaction.dart';
import 'package:tmail_ui_user/features/login/data/extensions/token_oidc_cache_extension.dart';
import 'package:tmail_ui_user/features/login/data/extensions/token_oidc_extension.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';

class TokenOidcCacheManager extends CacheManagerInteraction {
  final TokenOidcCacheClient _tokenOidcCacheClient;

  TokenOidcCacheManager(this._tokenOidcCacheClient);

  Future<TokenOIDC> getTokenOidc(String tokenIdHash) async {
    log('TokenOidcCacheManager::getTokenOidc(): tokenIdHash: $tokenIdHash');
    try {
      final tokenCache = await _tokenOidcCacheClient.getItem(tokenIdHash);
      log('TokenOidcCacheManager::getTokenOidc(): tokenCache: $tokenCache');
      if (tokenCache == null) {
        throw NotFoundStoredTokenException();
      }
      return tokenCache.toTokenOidc();
    } on AppBaseException {
      rethrow;
    } catch (e, stackTrace) {
      // AES-CBC decryption failed (e.g. non-block-aligned bytes from a partial
      // write or cross-isolate race). Clear the corrupted box so the next read
      // starts clean and triggers normal re-authentication instead of looping.
      logError(
        'TokenOidcCacheManager::getTokenOidc(): '
        'token_box_corrupted=true | error_type=${e.runtimeType} | clearing box',
        exception: e,
        stackTrace: stackTrace,
      );
      await _safelyClearBox();
      throw NotFoundStoredTokenException();
    }
  }

  Future<void> persistOneTokenOidc(TokenOIDC tokenOIDC) async {
    await _persistAtKey(tokenOIDC.tokenIdHash, tokenOIDC);
  }

  Future<void> persistOneTokenOidcAt(String key, TokenOIDC tokenOIDC) async {
    await _persistAtKey(key, tokenOIDC);
  }

  Future<void> _persistAtKey(String key, TokenOIDC tokenOIDC) async {
    log('TokenOidcCacheManager::_persistAtKey(): keyHash: $key');
    // Crash-safe persist: write the new token FIRST, then prune stale entries,
    // so the box is never empty if the process is killed mid-write.
    await _tokenOidcCacheClient.insertItem(key, tokenOIDC.toTokenOidcCache());
    try {
      await _removeStaleTokens(keepKey: key);
      log('TokenOidcCacheManager::_persistAtKey(): done');
    } on AppBaseException {
      rethrow;
    } catch (e, stackTrace) {
      // _removeStaleTokens calls getMapItems() → toMap(), which iterates ALL entries
      // and decrypts each one. If the box contains a corrupted entry (e.g. from a
      // cross-isolate partial write), toMap() throws before prune completes.
      // Recover by clearing and re-inserting only the new valid token.
      logError(
        'TokenOidcCacheManager::_persistAtKey(): '
        'box_corrupted=true | error_type=${e.runtimeType} | clearing and re-inserting token',
        exception: e,
        stackTrace: stackTrace,
      );
      await _safelyClearBox();
      await _tokenOidcCacheClient.insertItem(key, tokenOIDC.toTokenOidcCache());
    }
  }

/// Removes every token except [keepKey] so the box keeps exactly one entry
  Future<void> _removeStaleTokens({required String keepKey}) async {
    final allItems = await _tokenOidcCacheClient.getMapItems();
    final staleKeys = allItems.keys.where((key) => key != keepKey).toList();
    if (staleKeys.isNotEmpty) {
      log('TokenOidcCacheManager::_removeStaleTokens(): removing ${staleKeys.length} stale token(s)');
      await _tokenOidcCacheClient.deleteMultipleItem(staleKeys);
    }
  }

  Future<void> clear() async {
    await _tokenOidcCacheClient.clearAllData();
  }

  Future<void> _safelyClearBox() async {
    try {
      await _tokenOidcCacheClient.clearAllData();
    } catch (e) {
      logWarning('TokenOidcCacheManager::_safelyClearBox(): clear failed, deleting box from disk | $e');
      try {
        await _tokenOidcCacheClient.deleteBox();
      } catch (e2) {
        logWarning('TokenOidcCacheManager::_safelyClearBox(): deleteBox also failed | $e2');
      }
    }
  }

  @override
  Future<void> migrateHiveToIsolatedHive() async {
    try {
      final legacyMapItems = await _tokenOidcCacheClient.getMapItems(
        isolated: false,
      );
      log('$runtimeType::migrateHiveToIsolatedHive(): Length of legacyMapItems: ${legacyMapItems.length}');
      await _tokenOidcCacheClient.insertMultipleItem(legacyMapItems);
      log('$runtimeType::migrateHiveToIsolatedHive(): ✅ Migrate Hive box "${_tokenOidcCacheClient.tableName}" → IsolatedHive DONE');
    } catch (e) {
      logWarning('$runtimeType::migrateHiveToIsolatedHive(): ❌ Migrate Hive box "${_tokenOidcCacheClient.tableName}" → IsolatedHive FAILED, Error: $e');
    }
  }
}