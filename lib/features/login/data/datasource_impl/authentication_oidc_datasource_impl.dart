import 'package:model/model.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_oidc_datasource.dart';
import 'package:tmail_ui_user/features/login/data/local/oidc_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_http_client.dart';

class AuthenticationOIDCDataSourceImpl extends AuthenticationOIDCDataSource {

  final OIDCHttpClient _oidcHttpClient;
  final AuthenticationClientBase _authenticationClient;
  final TokenOidcCacheManager _tokenOidcCacheManager;
  final OidcConfigurationCacheManager _oidcConfigurationCacheManager;

  AuthenticationOIDCDataSourceImpl(
    this._oidcHttpClient,
    this._authenticationClient,
    this._tokenOidcCacheManager,
    this._oidcConfigurationCacheManager);

  @override
  Future<OIDCResponse> checkOIDCIsAvailable(OIDCRequest oidcRequest) {
    return Future.sync(() async {
      final oidcResponse = await _oidcHttpClient.checkOIDCIsAvailable(oidcRequest);
      return oidcResponse!;
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<OIDCConfiguration> getOIDCConfiguration(OIDCResponse oidcResponse) {
    return Future.sync(() async {
      return await _oidcHttpClient.getOIDCConfiguration(oidcResponse);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<TokenOIDC> getTokenOIDC(String clientId, String redirectUrl, String discoveryUrl, List<String> scopes) {
    return Future.sync(() async {
      return await _authenticationClient.getTokenOIDC(clientId, redirectUrl, discoveryUrl, scopes);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<TokenOIDC> getStoredTokenOIDC(String tokenIdHash) {
    return _tokenOidcCacheManager.getTokenOidc(tokenIdHash);
  }

  @override
  Future<void> persistTokenOIDC(TokenOIDC tokenOidc) {
    return _tokenOidcCacheManager.persistOneTokenOidc(tokenOidc);
  }

  @override
  Future<OIDCConfiguration> getStoredOidcConfiguration() {
    return _oidcConfigurationCacheManager.getOidcConfiguration();
  }

  @override
  Future<void> persistAuthorityOidc(String authority) {
    return _oidcConfigurationCacheManager.persistAuthorityOidc(authority);
  }

  @override
  Future<TokenOIDC> refreshingTokensOIDC(String clientId, String redirectUrl,
      String discoveryUrl, List<String> scopes, String refreshToken) {
    return _authenticationClient.refreshingTokensOIDC(
        clientId, redirectUrl, discoveryUrl, scopes, refreshToken);
  }

  @override
  Future<bool> logout(TokenId tokenId, OIDCConfiguration config) {
    return Future.sync(() async {
       return await _authenticationClient.logoutOidc(tokenId, config);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> deleteAuthorityOidc() {
    return _oidcConfigurationCacheManager.deleteAuthorityOidc();
  }

  @override
  Future<void> authenticateOidcOnBrowser(String clientId, String redirectUrl,
      String discoveryUrl, List<String> scopes) {
    return _authenticationClient.authenticateOidcOnBrowser(
        clientId,
        redirectUrl,
        discoveryUrl,
        scopes);
  }

  @override
  Future<String?> getAuthenticationInfo() {
    return _authenticationClient.getAuthenticationInfo();
  }
}