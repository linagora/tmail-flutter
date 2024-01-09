
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:get/get.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/response/oidc_discovery_response.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/extensions/authentication_token_extension.dart';
import 'package:tmail_ui_user/features/login/data/extensions/token_oidc_extension.dart';
import 'package:tmail_ui_user/features/login/data/extensions/token_response_extension.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/oidc_configuration_extensions.dart';

class AuthenticationClientMobile implements AuthenticationClientBase {

  final FlutterAppAuth _appAuth;

  AuthenticationClientMobile(this._appAuth);

  @override
  Future<TokenOIDC> getTokenOIDC(OIDCConfiguration oidcConfiguration) async {
    final authorizationTokenResponse = await _appAuth.authorizeAndExchangeCode(
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
  Future<bool> logoutOidc(
    TokenId tokenId,
    OIDCConfiguration config,
    OIDCDiscoveryResponse oidcDiscoveryResponse
  ) async {
    final authorizationServiceConfiguration = oidcDiscoveryResponse.authorizationEndpoint == null || oidcDiscoveryResponse.tokenEndpoint == null
        ? null
        : AuthorizationServiceConfiguration(
            authorizationEndpoint: oidcDiscoveryResponse.authorizationEndpoint!,
            tokenEndpoint: oidcDiscoveryResponse.tokenEndpoint!,
            endSessionEndpoint: oidcDiscoveryResponse.endSessionEndpoint);
            
    final endSession = await _appAuth.endSession(
      EndSessionRequest(
        idTokenHint: tokenId.uuid,
        postLogoutRedirectUrl: config.logoutRedirectUrl,
        discoveryUrl: config.discoveryUrl,
        serviceConfiguration: authorizationServiceConfiguration
      )
    );
    return endSession?.state?.isNotEmpty == true;
  }

  @override
  Future<TokenOIDC> refreshingTokensOIDC(OIDCConfiguration oidcConfiguration, String refreshToken) async {
    final tokenResponse = await _appAuth.token(
      TokenRequest(
        oidcConfiguration.clientId,
        oidcConfiguration.redirectUrl,
        discoveryUrl: oidcConfiguration.discoveryUrl,
        refreshToken: refreshToken,
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
  Future<void> authenticateOidcOnBrowser(OIDCConfiguration oidcConfiguration) {
    throw UnimplementedError();
  }

  @override
  Future<String> getAuthResponseUrlBrowser() {
    throw UnimplementedError();
  }
}

AuthenticationClientBase getAuthenticationClientImplementation({String? tag}) =>
    AuthenticationClientMobile(Get.find<FlutterAppAuth>(tag: tag));