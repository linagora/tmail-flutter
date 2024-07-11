
import 'package:flutter_appauth_platform_interface/flutter_appauth_platform_interface.dart';
import 'package:get/get.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/response/oidc_discovery_response.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/extensions/authentication_token_extension.dart';
import 'package:tmail_ui_user/features/login/data/extensions/token_oidc_extension.dart';
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
  Future<TokenOIDC> getTokenOIDC(OIDCConfiguration oidcConfiguration) async {
    final authorizationTokenResponse = await _appAuthWeb.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        oidcConfiguration.clientId,
        oidcConfiguration.redirectUrl,
        discoveryUrl: oidcConfiguration.discoveryUrl,
        scopes: oidcConfiguration.scopes,
        preferEphemeralSession: true
      )
    );

    if (authorizationTokenResponse != null) {
      final tokenOIDC = authorizationTokenResponse.toTokenOIDC(authority: oidcConfiguration.authority);
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
  Future<TokenOIDC> refreshingTokensOIDC(OIDCConfiguration oidcConfiguration, String refreshToken) async {
    final tokenResponse = await _appAuthWeb.token(
      TokenRequest(
        oidcConfiguration.clientId,
        oidcConfiguration.redirectUrl,
        discoveryUrl: oidcConfiguration.discoveryUrl,
        refreshToken: refreshToken,
        grantType: OIDCConstant.refreshTokenGrantType,
        scopes: oidcConfiguration.scopes
      )
    );

    if (tokenResponse != null) {
      final tokenOIDC = tokenResponse.toTokenOIDC(
        authority: oidcConfiguration.authority,
        maybeAvailableRefreshToken: refreshToken
      );
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
  Future<void> authenticateOidcOnBrowser(OIDCConfiguration oidcConfiguration) async {
    await _appAuthWeb.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        oidcConfiguration.clientId,
        oidcConfiguration.redirectUrl,
        discoveryUrl: oidcConfiguration.discoveryUrl,
        scopes: oidcConfiguration.scopes
      )
    );
  }

  @override
  Future<String> getAuthResponseUrlBrowser() async {
    final authUrl = html.window.sessionStorage[OIDCConstant.authResponseKey];
    if (authUrl?.isNotEmpty == true) {
      return authUrl!;
    } else {
      throw NotFoundAuthResponseUrlBrowser();
    }
  }
}

AuthenticationClientBase getAuthenticationClientImplementation({String? tag}) =>
    AuthenticationClientWeb(Get.find<AppAuthWebPlugin>(tag: tag));