
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:model/model.dart';

extension TokenResponseExtension on TokenResponse {

  // A refresh response may omit refresh_token, and OIDC Core 12.2 lets it omit
  // id_token too; keep whichever the current token already holds.
  TokenOIDC toTokenOIDC({required TokenOIDC currentToken}) {
    return TokenOIDC(
      accessToken ?? '',
      TokenId(_idTokenOrCurrent(currentToken.tokenId.uuid)),
      refreshToken ?? currentToken.refreshToken,
      expiredTime: accessTokenExpirationDateTime ?? DateTime.now());
  }

  // flutter_appauth_web stringifies the absent field, so it arrives as "null";
  // mobile sends '' or null for the same thing.
  String _idTokenOrCurrent(String current) =>
      (idToken?.isNotEmpty == true && idToken != 'null') ? idToken! : current;
}
