import 'package:model/oidc/token_oidc.dart';

abstract class TokenCacheManager {
  Future<TokenOIDC> getTokenOidc(String tokenIdHash);

  Future<void> persistOneTokenOidc(TokenOIDC tokenOIDC);

  Future<void> deleteTokenOidc();
}
