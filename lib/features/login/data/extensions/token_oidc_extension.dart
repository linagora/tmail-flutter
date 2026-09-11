import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/model/token_oidc_cache.dart';

extension TokenOidcExtension on TokenOIDC {
  TokenOidcCache toTokenOidcCache() {
    return TokenOidcCache(token, tokenId.uuid, refreshToken, expiredTime: expiredTime);
  }

  // OIDC Core 12.2: a refresh response may omit id_token; keep the one we have.
  TokenOIDC withIdTokenFallback(TokenId? currentIdToken) {
    if (tokenId.uuid.isNotEmpty || currentIdToken == null || currentIdToken.uuid.isEmpty) {
      return this;
    }
    return TokenOIDC(token, currentIdToken, refreshToken, expiredTime: expiredTime);
  }
}