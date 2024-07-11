
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/request/oidc_request.dart';
import 'package:model/oidc/response/oidc_discovery_response.dart';
import 'package:model/oidc/response/oidc_response.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';

abstract class AuthenticationOIDCRepository {
  Future<OIDCResponse> checkOIDCIsAvailable(OIDCRequest oidcRequest);

  Future<OIDCDiscoveryResponse> discoverOIDC(OIDCConfiguration oidcConfiguration);

  Future<TokenOIDC> getTokenOIDC(OIDCConfiguration oidcConfiguration);

  Future<TokenOIDC> refreshingTokensOIDC(OIDCConfiguration oidcConfiguration, String refreshToken);

  Future<bool> logout(TokenId tokenId, OIDCConfiguration config, OIDCDiscoveryResponse oidcDiscoveryResponse);

  Future<void> authenticateOidcOnBrowser(OIDCConfiguration oidcConfiguration);

  Future<String> getAuthResponseUrlBrowser();
}