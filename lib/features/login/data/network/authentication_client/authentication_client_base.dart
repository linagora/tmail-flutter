
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/response/oidc_discovery_response.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_mobile.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_web.dart';

abstract class AuthenticationClientBase {
  Future<void> authenticateOidcOnBrowser(OIDCConfiguration oidcConfiguration);

  Future<String> getAuthResponseUrlBrowser();

  Future<TokenOIDC> getTokenOIDC(OIDCConfiguration oidcConfiguration);

  Future<TokenOIDC> refreshingTokensOIDC(OIDCConfiguration oidcConfiguration, String refreshToken);

  Future<bool> logoutOidc(TokenId tokenId, OIDCConfiguration config, OIDCDiscoveryResponse oidcDiscoveryResponse);

  factory AuthenticationClientBase({String? tag}) => getAuthenticationClientImplementation(tag: tag);
}