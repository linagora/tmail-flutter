
import 'package:model/model.dart';

abstract class AuthenticationOIDCRepository {
  Future<OIDCResponse> checkOIDCIsAvailable(OIDCRequest oidcRequest);

  Future<OIDCConfiguration> getOIDCConfiguration(OIDCResponse oidcResponse);

  Future<OIDCDiscoveryResponse> discoverOIDC(OIDCConfiguration oidcConfiguration);

  Future<TokenOIDC> getTokenOIDC(String clientId, String redirectUrl, String discoveryUrl, List<String> scopes);

  Future<void> persistTokenOIDC(TokenOIDC tokenOidc);

  Future<void> deleteTokenOIDC();

  Future<TokenOIDC> getStoredTokenOIDC(String tokenIdHash);

  Future<void> persistOidcConfiguration(OIDCConfiguration oidcConfiguration);

  Future<void> deleteOidcConfiguration();

  Future<OIDCConfiguration> getStoredOidcConfiguration();

  Future<TokenOIDC> refreshingTokensOIDC(
      String clientId,
      String redirectUrl,
      String discoveryUrl,
      List<String> scopes,
      String refreshToken);

  Future<bool> logout(TokenId tokenId, OIDCConfiguration config, OIDCDiscoveryResponse oidcRescovery);

  Future<void> authenticateOidcOnBrowser(
      String clientId,
      String redirectUrl,
      String discoveryUrl,
      List<String> scopes);

  Future<String> getAuthenticationInfo();
}