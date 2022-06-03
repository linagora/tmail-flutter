
import 'package:model/model.dart';

abstract class AuthenticationOIDCDataSource {
  Future<OIDCResponse> checkOIDCIsAvailable(OIDCRequest oidcRequest);

  Future<OIDCConfiguration> getOIDCConfiguration(Uri baseUri, OIDCResponse oidcResponse);

  Future<TokenOIDC> getTokenOIDC(String clientId, String redirectUrl, String discoveryUrl, List<String> scopes);

  Future<void> persistTokenOIDC(TokenOIDC tokenOidc);

  Future<TokenOIDC> getStoredTokenOIDC(String tokenIdHash);

  Future<void> persistAuthorityOidc(String authority);

  Future<OIDCConfiguration> getStoredOidcConfiguration();

  Future<TokenOIDC> refreshingTokensOIDC(
      String clientId,
      String redirectUrl,
      String discoveryUrl,
      List<String> scopes,
      String refreshToken);

  Future<bool> logout(TokenId tokenId, OIDCConfiguration config);
}