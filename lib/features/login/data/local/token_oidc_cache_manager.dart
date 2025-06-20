import 'package:core/utils/app_logger.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/caching/clients/token_oidc_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/extensions/token_oidc_cache_extension.dart';
import 'package:tmail_ui_user/features/login/data/extensions/token_oidc_extension.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';

class TokenOidcCacheManager {
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
    log('TokenOidcCacheManager::persistOneTokenOidc(): $tokenOIDC');
    await _tokenOidcCacheClient.clearAllData();
    log('TokenOidcCacheManager::persistOneTokenOidc(): key: ${tokenOIDC.tokenId.uuid}');
    log('TokenOidcCacheManager::persistOneTokenOidc(): key\'s hash: ${tokenOIDC.tokenIdHash}');
    log('TokenOidcCacheManager::persistOneTokenOidc(): token: ${tokenOIDC.token}');
    await _tokenOidcCacheClient.insertItem(tokenOIDC.tokenIdHash, tokenOIDC.toTokenOidcCache());
    log('TokenOidcCacheManager::persistOneTokenOidc(): done');
  }

  Future<void> deleteTokenOidc() async {
    await _tokenOidcCacheClient.clearAllData();
  }
}