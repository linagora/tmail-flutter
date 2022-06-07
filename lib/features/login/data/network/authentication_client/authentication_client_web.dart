
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:flutter_appauth_platform_interface/flutter_appauth_platform_interface.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';

import '../../utils/library_platform/app_auth_plugin/app_auth_plugin.dart';

class AuthenticationClientWeb implements AuthenticationClientBase {

  final AppAuthWebPlugin _appAuthWeb;

  AuthenticationClientWeb(this._appAuthWeb);

  @override
  Future<TokenOIDC> getTokenOIDC(String clientId, String redirectUrl,
      String discoveryUrl, List<String> scopes) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> logoutOidc(TokenId tokenId, OIDCConfiguration config) {
    throw UnimplementedError();
  }

  @override
  Future<TokenOIDC> refreshingTokensOIDC(String clientId, String redirectUrl,
      String discoveryUrl, List<String> scopes, String refreshToken) {
    throw UnimplementedError();
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
}

AuthenticationClientBase getAuthenticationClientImplementation() =>
    AuthenticationClientWeb(Get.find<AppAuthWebPlugin>());