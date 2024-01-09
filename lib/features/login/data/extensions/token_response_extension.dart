
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';

extension TokenResponseExtension on TokenResponse {
  TokenOIDC toTokenOIDC({
    required String authority,
    String? maybeAvailableRefreshToken
  }) {
    return TokenOIDC(
      token: accessToken ?? '',
      tokenId: TokenId(idToken ?? ''),
      refreshToken: refreshToken ?? maybeAvailableRefreshToken ?? '',
      authority: authority,
      expiredTime: accessTokenExpirationDateTime ?? DateTime.now());
  }
}