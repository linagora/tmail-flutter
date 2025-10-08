
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
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_interaction_mixin.dart';
import 'package:tmail_ui_user/features/login/data/network/config/oidc_constant.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/oidc_configuration_extensions.dart';

class AuthenticationClientMobile with AuthenticationClientInteractionMixin
    implements AuthenticationClientBase  {

  final FlutterAppAuth _appAuth;

  AuthenticationClientMobile(this._appAuth);

  @override
  Future<TokenOIDC> getTokenOIDC(
    String clientId,
    String redirectUrl,
    String discoveryUrl,
    List<String> scopes, {
    String? loginHint,
  }) async {
    final authorizationTokenRequest = getAuthorizationTokenRequest(
      clientId,
      redirectUrl,
      discoveryUrl,
      scopes,
      loginHint: loginHint,
    );
    final authorizationTokenResponse = await _appAuth.authorizeAndExchangeCode(
      authorizationTokenRequest,
    );
    log('$runtimeType::getTokenOIDC(): token: ${authorizationTokenResponse.accessToken}');
    final tokenOIDC = authorizationTokenResponse.toTokenOIDC();
    if (tokenOIDC.isTokenValid()) {
      return tokenOIDC;
    } else {
      throw AccessTokenInvalidException();
    }
  }

  @override
  Future<bool> logoutOidc(
    TokenId tokenId,
    OIDCConfiguration config,
    OIDCDiscoveryResponse discoveryResponse,
  ) async {
    final endSessionRequest = getEndSessionRequest(
      tokenId,
      config,
      discoveryResponse,
    );
    final endSession = await _appAuth.endSession(endSessionRequest);
    log('$runtimeType::logoutOidc(): ${endSession.state}');
    return endSession.state?.isNotEmpty == true;
  }

  @override
  Future<TokenOIDC> refreshingTokensOIDC(
    String clientId,
    String redirectUrl,
    String discoveryUrl,
    List<String> scopes,
    String refreshToken,
  ) async {
    try {
      final tokenRequest = getRefreshTokenRequest(
        clientId,
        redirectUrl,
        discoveryUrl,
        refreshToken,
        scopes,
      );
      final tokenResponse = await _appAuth.token(tokenRequest);
      log('$runtimeType::refreshingTokensOIDC():Token: ${tokenResponse.accessToken}');
      final tokenOIDC = tokenResponse.toTokenOIDC(
        maybeAvailableRefreshToken: refreshToken,
      );
      if (tokenOIDC.isTokenValid()) {
        return tokenOIDC;
      } else {
        throw AccessTokenInvalidException();
      }
    } catch (e) {
      logError('$runtimeType::refreshingTokensOIDC(): $e');
      throw handleException(e);
    }
  }

  @override
  Future<void> authenticateOidcOnBrowser(String clientId, String redirectUrl,
      String discoveryUrl, List<String> scopes) {
    return Future.value(null);
  }

  @override
  Future<TokenOIDC> signInTwakeWorkplace(OIDCConfiguration oidcConfiguration) async {
    final uri = await FlutterWebAuth2.authenticate(
      url: oidcConfiguration.signInTWPUrl,
      callbackUrlScheme: OIDCConstant.twakeWorkplaceUrlScheme,
      options: const FlutterWebAuth2Options(
        intentFlags: ephemeralIntentFlags,
      ),
    );
    log('$runtimeType::signInTwakeWorkplace():Uri = $uri');
    return TokenOIDC.fromUri(uri);
  }

  @override
  Future<TokenOIDC> signUpTwakeWorkplace(OIDCConfiguration oidcConfiguration) async {
    final uri = await FlutterWebAuth2.authenticate(
      url: oidcConfiguration.signUpTWPUrl,
      callbackUrlScheme: OIDCConstant.twakeWorkplaceUrlScheme,
      options: const FlutterWebAuth2Options(
        intentFlags: ephemeralIntentFlags,
      ),
    );
    log('$runtimeType::signUpTwakeWorkplace():Uri = $uri');
    return TokenOIDC.fromUri(uri);
  }
}

AuthenticationClientBase getAuthenticationClientImplementation({String? tag}) =>
    AuthenticationClientMobile(Get.find<FlutterAppAuth>(tag: tag));