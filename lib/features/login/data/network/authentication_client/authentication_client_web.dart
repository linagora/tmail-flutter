
import 'package:core/utils/app_logger.dart';
import 'package:flutter_appauth_platform_interface/flutter_appauth_platform_interface.dart';
import 'package:get/get.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/response/oidc_discovery_response.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/extensions/authentication_token_extension.dart';
import 'package:tmail_ui_user/features/login/data/extensions/token_response_extension.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/config/oidc_constant.dart';
import 'package:tmail_ui_user/features/login/data/utils/library_platform/app_auth_plugin/app_auth_plugin.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/oidc_configuration_extensions.dart';
import 'package:universal_html/html.dart' as html;

class AuthenticationClientWeb implements AuthenticationClientBase {

  final AppAuthWebPlugin _appAuthWeb;

  AuthenticationClientWeb(this._appAuthWeb);

  @override
  Future<TokenOIDC> getTokenOIDC(String clientId, String redirectUrl,
      String discoveryUrl, List<String> scopes) async {
    final authorizationTokenResponse = await _appAuthWeb.authorizeAndExchangeCode(AuthorizationTokenRequest(
        clientId,
        redirectUrl,
        discoveryUrl: discoveryUrl,
        scopes: scopes,
        preferEphemeralSession: true));

    log('AuthClientMobile::getTokenOIDC(): token: ${authorizationTokenResponse?.accessToken}');

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
  Future<bool> logoutOidc(TokenId tokenId, OIDCConfiguration config, OIDCDiscoveryResponse oidcRescovery) async {
    final authorizationServiceConfiguration = oidcRescovery.authorizationEndpoint == null || oidcRescovery.tokenEndpoint == null
      ? null
      : AuthorizationServiceConfiguration(
          authorizationEndpoint: oidcRescovery.authorizationEndpoint!,
          tokenEndpoint: oidcRescovery.tokenEndpoint!,
          endSessionEndpoint: oidcRescovery.endSessionEndpoint);
    final endSession = await _appAuthWeb.endSession(EndSessionRequest(
        idTokenHint: tokenId.uuid,
        postLogoutRedirectUrl: config.logoutRedirectUrl,
        discoveryUrl: config.discoveryUrl,
        serviceConfiguration: authorizationServiceConfiguration
    ));
    return endSession != null;
  }

  @override
  Future<TokenOIDC> refreshingTokensOIDC(String clientId, String redirectUrl,
      String discoveryUrl, List<String> scopes, String refreshToken) async {
    final tokenResponse = await _appAuthWeb.token(TokenRequest(
        clientId,
        redirectUrl,
        discoveryUrl: discoveryUrl,
        refreshToken: refreshToken,
        grantType: 'refresh_token',
        scopes: scopes));

    if (tokenResponse != null) {
      final tokenOIDC = tokenResponse.toTokenOIDC(maybeAvailableRefreshToken: refreshToken);
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
      String discoveryUrl, List<String> scopes) async {
    await _appAuthWeb.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
            clientId,
            redirectUrl,
            discoveryUrl: discoveryUrl,
            scopes: scopes));
  }

  @override
  Future<String> getAuthenticationInfo() async {
    final authUrl = html.window.sessionStorage[OIDCConstant.authResponseKey];
    log('AuthenticationClientWeb::getAuthenticationInfo(): authUrl: $authUrl');
    if (authUrl != null && authUrl.isNotEmpty) {
      return authUrl;
    } else {
      throw CanNotAuthenticationInfoOnWeb();
    }
  }

  @override
  Future<TokenOIDC> signUpTwakeWorkplace(OIDCConfiguration oidcConfiguration) {
    throw UnimplementedError();
  }

  @override
  Future<TokenOIDC> signInTwakeWorkplace(OIDCConfiguration oidcConfiguration) {
    throw UnimplementedError();
  }
}

AuthenticationClientBase getAuthenticationClientImplementation({String? tag}) =>
    AuthenticationClientWeb(Get.find<AppAuthWebPlugin>(tag: tag));