
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
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_interaction_mixin.dart';
import 'package:tmail_ui_user/features/login/data/utils/library_platform/app_auth_plugin/app_auth_plugin.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';

class AuthenticationClientWeb with AuthenticationClientInteractionMixin 
    implements AuthenticationClientBase {

  final AppAuthWebPlugin _appAuthWeb;

  AuthenticationClientWeb(this._appAuthWeb);

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
    final authorizationTokenResponse = await _appAuthWeb.authorizeAndExchangeCode(
      authorizationTokenRequest,
    );
    log('$runtimeType::getTokenOIDC():Token: ${authorizationTokenResponse.accessToken}');
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
    final endSession = await _appAuthWeb.endSession(endSessionRequest);
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
      final tokenResponse = await _appAuthWeb.token(tokenRequest);
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
  Future<void> authenticateOidcOnBrowser(
    String clientId,
    String redirectUrl,
    String discoveryUrl,
    List<String> scopes,
  ) async {
    await _appAuthWeb.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        clientId,
        redirectUrl,
        discoveryUrl: discoveryUrl,
        scopes: scopes,
      ),
    );
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