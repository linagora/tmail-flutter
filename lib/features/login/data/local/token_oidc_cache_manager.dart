import 'dart:isolate';

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
    log('$runtimeType-in isolate: ${Isolate.current.hashCode}::getTokenOidc(): tokenIdHash: $tokenIdHash');
    final tokenCache = await _tokenOidcCacheClient.getItem(tokenIdHash);
    log('$runtimeType-in isolate: ${Isolate.current.hashCode}::getTokenOidc(): tokenCache: $tokenCache');
    if (tokenCache == null) {
      throw NotFoundStoredTokenException();
    } else {
      return tokenCache.toTokenOidc();
    }
  }

  Future<void> persistOneTokenOidc(TokenOIDC tokenOIDC) async {
    log('$runtimeType-in isolate: ${Isolate.current.hashCode}::persistOneTokenOidc(): $tokenOIDC');
    await deleteTokenOidc();
    log('$runtimeType-in isolate: ${Isolate.current.hashCode}::persistOneTokenOidc(): key: ${tokenOIDC.tokenId.uuid}');
    log('$runtimeType-in isolate: ${Isolate.current.hashCode}::persistOneTokenOidc(): key\'s hash: ${tokenOIDC.tokenIdHash}');
    log('$runtimeType-in isolate: ${Isolate.current.hashCode}::persistOneTokenOidc(): token: ${tokenOIDC.token}');
    await _tokenOidcCacheClient.insertItem(tokenOIDC.tokenIdHash, tokenOIDC.toTokenOidcCache());
    log('$runtimeType-in isolate: ${Isolate.current.hashCode}::persistOneTokenOidc(): done');
  }

  Future<void> deleteTokenOidc() async {
    log('$runtimeType-in isolate: ${Isolate.current.hashCode}::deleteTokenOidc:');
    await _tokenOidcCacheClient.clearAllData();
    log('$runtimeType-in isolate: ${Isolate.current.hashCode}::deleteTokenOidc: DONE');
  }
}