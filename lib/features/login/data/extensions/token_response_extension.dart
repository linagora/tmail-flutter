
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:model/model.dart';

extension TokenResponseExtension on TokenResponse {

  TokenOIDC toTokenOIDC({String? maybeAvailableRefreshToken}) {
    return TokenOIDC(
      accessToken ?? '',
      TokenId(idToken ?? ''),
      refreshToken ?? maybeAvailableRefreshToken ?? '',
      expiredTime: accessTokenExpirationDateTime ?? DateTime.now());
  }
}