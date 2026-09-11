
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:model/model.dart';

extension TokenResponseExtension on TokenResponse {

  // A refresh response may omit refresh_token, and OIDC Core 12.2 lets it omit
  // id_token too; keep whichever the current token already holds.
  TokenOIDC toTokenOIDC({required TokenOIDC currentToken}) {
    return TokenOIDC(
      accessToken ?? '',
      TokenId(_orCurrent(idToken, currentToken.tokenId.uuid)),
      _orCurrent(refreshToken, currentToken.refreshToken),
      expiredTime: accessTokenExpirationDateTime ?? DateTime.now());
  }

  // The plugin returns '' rather than null when a field is absent.
  String _orCurrent(String? value, String current) =>
      value?.isNotEmpty == true ? value! : current;
}
