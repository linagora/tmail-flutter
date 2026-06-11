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
    final tokenCache = await _tokenOidcCacheClient.getItem(tokenIdHash);
    log('TokenOidcCacheManager::getTokenOidc(): tokenCache: $tokenCache');
    if (tokenCache == null) {
      throw NotFoundStoredTokenException();
    } else {
      return tokenCache.toTokenOidc();
    }
  }

  Future<void> persistOneTokenOidc(TokenOIDC tokenOIDC) async {
    // Crash-safe persist: write the new token FIRST, then prune stale entries.
    log('TokenOidcCacheManager::persistOneTokenOidc(): keyHash: ${tokenOIDC.tokenIdHash}');
    await _tokenOidcCacheClient.insertItem(tokenOIDC.tokenIdHash, tokenOIDC.toTokenOidcCache());
    await _removeStaleTokens(keepKey: tokenOIDC.tokenIdHash);
    log('TokenOidcCacheManager::persistOneTokenOidc(): done');
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