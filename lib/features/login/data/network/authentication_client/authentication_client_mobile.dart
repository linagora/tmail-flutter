
import 'package:core/utils/app_logger.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:get/get.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/extensions/authentication_token_extension.dart';
import 'package:tmail_ui_user/features/login/data/extensions/token_response_extension.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';

class AuthenticationClientMobile implements AuthenticationClientBase {

  final FlutterAppAuth _appAuth;

  AuthenticationClientMobile(this._appAuth);

  @override
  Future<TokenOIDC> getTokenOIDC(String clientId, String redirectUrl,
      String discoveryUrl, List<String> scopes) async {
    final authorizationTokenResponse = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUrl,
          discoveryUrl: discoveryUrl,
          scopes: scopes,
          preferEphemeralSession: true));

    log('AuthenticationClientMobile::getTokenOIDC(): token: ${authorizationTokenResponse?.accessToken}');

    if (authorizationTokenResponse != null) {
      final tokenOIDC = authorizationTokenResponse.toTokenOIDC();
      if (tokenOIDC.isTokenValid()) {
        return tokenOIDC;
      } else {
        throw AccessTokenInvalidException();
      }
    } else {
      throw NotFoundAccessTokenException();
    }
  }

  @override
  Future<bool> logoutOidc(TokenId tokenId, OIDCConfiguration config) async {
    final endSession = await _appAuth.endSession(EndSessionRequest(
        idTokenHint: tokenId.uuid,
        postLogoutRedirectUrl: config.redirectUrl,
        discoveryUrl: config.discoveryUrl
    ));
    log('AuthenticationClientMobile::logoutOidc(): ${endSession?.state}');
    return endSession?.state?.isNotEmpty == true;
  }

  @override
  Future<TokenOIDC> refreshingTokensOIDC(String clientId, String redirectUrl,
      String discoveryUrl, List<String> scopes, String refreshToken) async {
    final tokenResponse = await _appAuth.token(TokenRequest(
        clientId,
        redirectUrl,
        discoveryUrl: discoveryUrl,
        refreshToken: refreshToken,
        scopes: scopes));

    log('AuthenticationClientMobile::refreshingTokensOIDC(): refreshToken: ${tokenResponse?.accessToken}');

    if (tokenResponse != null) {
      final tokenOIDC = tokenResponse.toTokenOIDC();
      if (tokenOIDC.isTokenValid()) {
        return tokenOIDC;
      } else {
        throw AccessTokenInvalidException();
      }
    } else {
      throw NotFoundAccessTokenException();
    }
  }

  @override
  Future<void> authenticateOidcOnBrowser(String clientId, String redirectUrl,
      String discoveryUrl, List<String> scopes) {
    return Future.value(null);
  }
}

AuthenticationClientBase getAuthenticationClientImplementation() =>
    AuthenticationClientMobile(Get.find<FlutterAppAuth>());