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
    final tokenCache = await _tokenOidcCacheClient.getItem(tokenIdHash);
    log('TokenOidcCacheManager::getTokenOidc(): tokenCache: $tokenCache');
    if (tokenCache == null) {
      throw NotFoundStoredTokenException();
    } else {
      return tokenCache.toTokenOidc();
    }
  }

  Future<void> persistOneTokenOidc(TokenOIDC tokenOIDC) async {
    log('TokenOidcCacheManager::persistOneTokenOidc(): TOKEN_ID_HASH = ${tokenOIDC.tokenIdHash}');
    log('TokenOidcCacheManager::persistOneTokenOidc(): EXPIRED_TIME = ${tokenOIDC.expiredTime}');
    await _tokenOidcCacheClient.clearAllData();
    await _tokenOidcCacheClient.insertItem(
      tokenOIDC.tokenIdHash,
      tokenOIDC.toTokenOidcCache());
    log('TokenOidcCacheManager::persistOneTokenOidc: SUCCESS');
  }

  Future<void> deleteTokenOidc() async {
    log('TokenOidcCacheManager::deleteTokenOidc:');
    await _tokenOidcCacheClient.clearAllData();
  }

  Future<void> closeTokenOIDCHiveCacheBox() => _tokenOidcCacheClient.closeBox();
}