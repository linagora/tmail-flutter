import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/request/oidc_request.dart';
import 'package:model/oidc/response/oidc_discovery_response.dart';
import 'package:model/oidc/response/oidc_response.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_oidc_datasource.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';

class AuthenticationOIDCRepositoryImpl extends AuthenticationOIDCRepository {
  final AuthenticationOIDCDataSource _oidcDataSource;

  AuthenticationOIDCRepositoryImpl(this._oidcDataSource);

  @override
  Future<OIDCResponse> checkOIDCIsAvailable(OIDCRequest oidcRequest) {
    return _oidcDataSource.checkOIDCIsAvailable(oidcRequest);
  }

  @override
  Future<OIDCConfiguration> getOIDCConfiguration(OIDCResponse oidcResponse) {
    return _oidcDataSource.getOIDCConfiguration(oidcResponse);
  }

  @override
  Future<OIDCDiscoveryResponse> discoverOIDC(OIDCConfiguration oidcConfiguration) {
    return _oidcDataSource.discoverOIDC(oidcConfiguration);
  }

  @override
  Future<TokenOIDC> getTokenOIDC(String clientId, String redirectUrl, String discoveryUrl, List<String> scopes) {
    return _oidcDataSource.getTokenOIDC(clientId, redirectUrl, discoveryUrl, scopes);
  }

  @override
  Future<TokenOIDC> getStoredTokenOIDC(String tokenIdHash) {
    return _oidcDataSource.getStoredTokenOIDC(tokenIdHash);
  }

  @override
  Future<void> persistTokenOIDC(TokenOIDC tokenOidc) {
    return _oidcDataSource.persistTokenOIDC(tokenOidc);
  }

  @override
  Future<OIDCConfiguration> getStoredOidcConfiguration() {
    return _oidcDataSource.getStoredOidcConfiguration();
  }

  @override
  Future<void> persistOidcConfiguration(OIDCConfiguration oidcConfiguration) {
    return _oidcDataSource.persistOidcConfiguration(oidcConfiguration);
  }

  @override
  Future<TokenOIDC> refreshingTokensOIDC(
      String clientId,
      String redirectUrl,
      String discoveryUrl,
      List<String> scopes,
      String refreshToken
  ) {
    return _oidcDataSource.refreshingTokensOIDC(
        clientId,
        redirectUrl,
        discoveryUrl,
        scopes,
        refreshToken);
  }

  @override
  Future<bool> logout(TokenId tokenId, OIDCConfiguration config, OIDCDiscoveryResponse oidcRescovery) {
    return _oidcDataSource.logout(tokenId, config, oidcRescovery);
  }

  @override
  Future<void> deleteOidcConfiguration() {
    return _oidcDataSource.deleteOidcConfiguration();
  }

  @override
  Future<void> authenticateOidcOnBrowser(String clientId,
      String redirectUrl, String discoveryUrl, List<String> scopes) {
    return _oidcDataSource.authenticateOidcOnBrowser(clientId, redirectUrl, discoveryUrl, scopes);
  }

  @override
  Future<String> getAuthenticationInfo() {
    return _oidcDataSource.getAuthenticationInfo();
  }

  @override
  Future<void> deleteTokenOIDC() {
    return _oidcDataSource.deleteTokenOIDC();
  }
}