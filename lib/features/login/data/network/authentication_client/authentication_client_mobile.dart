
import 'package:core/utils/app_logger.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:get/get.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/response/oidc_discovery_response.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/extensions/authentication_token_extension.dart';
import 'package:tmail_ui_user/features/login/data/extensions/token_response_extension.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/config/oidc_constant.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/oidc_configuration_extensions.dart';

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
  Future<bool> logoutOidc(TokenId tokenId, OIDCConfiguration config, OIDCDiscoveryResponse oidcRescovery) async {
    final authorizationServiceConfiguration = oidcRescovery.authorizationEndpoint == null || oidcRescovery.tokenEndpoint == null
        ? null
        : AuthorizationServiceConfiguration(
            authorizationEndpoint: oidcRescovery.authorizationEndpoint!,
            tokenEndpoint: oidcRescovery.tokenEndpoint!,
            endSessionEndpoint: oidcRescovery.endSessionEndpoint);
            
    final endSession = await _appAuth.endSession(EndSessionRequest(
        idTokenHint: tokenId.uuid,
        postLogoutRedirectUrl: config.logoutRedirectUrl,
        discoveryUrl: config.discoveryUrl,
        serviceConfiguration: authorizationServiceConfiguration
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
      String discoveryUrl, List<String> scopes) {
    return Future.value(null);
  }

  @override
  Future<String> getAuthenticationInfo() {
    return Future.value('');
  }

  @override
  Future<TokenOIDC> signInTwakeWorkplace(OIDCConfiguration oidcConfiguration) async {
    final uri = await FlutterWebAuth2.authenticate(
      url: oidcConfiguration.singInUrl,
      callbackUrlScheme: OIDCConstant.twakeWorkplaceUrlScheme,
      options: const FlutterWebAuth2Options(
        intentFlags: ephemeralIntentFlags,
      ),
    );
    log('AuthenticationClientMobile::signInTwakeWorkplace():Uri = $uri');
    return TokenOIDC.fromUri(uri);
  }

  @override
  Future<TokenOIDC> signUpTwakeWorkplace(OIDCConfiguration oidcConfiguration) async {
    final uri = await FlutterWebAuth2.authenticate(
      url: oidcConfiguration.signUpUrl,
      callbackUrlScheme: OIDCConstant.twakeWorkplaceUrlScheme,
      options: const FlutterWebAuth2Options(
        intentFlags: ephemeralIntentFlags,
      ),
    );
    log('AuthenticationClientMobile::signUpTwakeWorkplace():Uri = $uri');
    return TokenOIDC.fromUri(uri);
  }
}

AuthenticationClientBase getAuthenticationClientImplementation({String? tag}) =>
    AuthenticationClientMobile(Get.find<FlutterAppAuth>(tag: tag));