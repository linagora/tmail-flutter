
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:model/model.dart';

extension TokenResponseExtension on TokenResponse {

  TokenOIDC toTokenOIDC() {
    return TokenOIDC(
      accessToken ?? '',
      TokenId(idToken ?? ''),
      refreshToken ?? '',
      expiredTime: accessTokenExpirationDateTime ?? DateTime.now());
  }
}