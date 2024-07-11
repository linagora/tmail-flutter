
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';

extension AuthorizationTokenResponseExtension on AuthorizationTokenResponse {
  TokenOIDC toTokenOIDC({required String authority}) {
    return TokenOIDC(
      token: accessToken ?? '',
      tokenId: TokenId(idToken ?? ''),
      refreshToken: refreshToken ?? '',
      authority: authority,
      expiredTime: accessTokenExpirationDateTime ?? DateTime.now());
  }
}