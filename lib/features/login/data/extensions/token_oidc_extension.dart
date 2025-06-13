import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/caching/model/isar/token_oidc_collection.dart';
import 'package:tmail_ui_user/features/login/data/model/token_oidc_cache.dart';

extension TokenOidcExtension on TokenOIDC {
  TokenOidcCache toTokenOidcCache() {
    return TokenOidcCache(token, tokenId.uuid, refreshToken, expiredTime: expiredTime);
  }

  TokenOidcCollection toTokenOidcCollection() {
    return TokenOidcCollection(
      token: token,
      tokenId: tokenId.uuid,
      refreshToken: refreshToken,
      expiredTime: expiredTime,
    );
  }
}
