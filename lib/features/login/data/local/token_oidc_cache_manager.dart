import 'package:core/utils/app_logger.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
    log('TokenOidcCacheManager::persistOneTokenOidc(): $tokenOIDC');
    FirebaseAnalytics.instance.logEvent(name: 'TokenOidcCacheMgr_persistOneTokenOidc', parameters: {
      'tokenIdHash': tokenOIDC.tokenIdHash,
      'expiredTime': tokenOIDC.expiredTime.toString(),
      'key': tokenOIDC.tokenId.uuid,
    });
    await _tokenOidcCacheClient.clearAllData();
    log('TokenOidcCacheManager::persistOneTokenOidc(): key: ${tokenOIDC.tokenId.uuid}');
    log('TokenOidcCacheManager::persistOneTokenOidc(): key\'s hash: ${tokenOIDC.tokenIdHash}');
    log('TokenOidcCacheManager::persistOneTokenOidc(): token: ${tokenOIDC.token}');
    FirebaseAnalytics.instance.logEvent(name: 'TokenOidcCacheMgr_persistOneTokenOidc', parameters: {
      'event': 'after clearAllData',
      'tokenIdHash': tokenOIDC.tokenIdHash,
      'expiredTime': tokenOIDC.expiredTime.toString(),
      'key': tokenOIDC.tokenId.uuid,
    });
    await _tokenOidcCacheClient.insertItem(tokenOIDC.tokenIdHash, tokenOIDC.toTokenOidcCache());
    FirebaseAnalytics.instance.logEvent(name: 'TokenOidcCacheMgr_persistOneTokenOidc', parameters: {
      'event': 'after insertItem',
      'tokenIdHash': tokenOIDC.tokenIdHash,
      'expiredTime': tokenOIDC.expiredTime.toString(),
      'key': tokenOIDC.tokenId.uuid,
    });
  }

  Future<void> deleteTokenOidc() async {
    await _tokenOidcCacheClient.clearAllData();
  }
}