import 'package:model/model.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_oidc_datasource.dart';
import 'package:tmail_ui_user/features/login/data/local/oidc_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_http_client.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class AuthenticationOIDCDataSourceImpl extends AuthenticationOIDCDataSource {

  final OIDCHttpClient _oidcHttpClient;
  final AuthenticationClientBase _authenticationClient;
  final TokenOidcCacheManager _tokenOidcCacheManager;
  final OidcConfigurationCacheManager _oidcConfigurationCacheManager;
  final ExceptionThrower _exceptionThrower;
  final ExceptionThrower _cacheExceptionThrower;

  AuthenticationOIDCDataSourceImpl(
    this._oidcHttpClient,
    this._authenticationClient,
    this._tokenOidcCacheManager,
    this._oidcConfigurationCacheManager,
    this._exceptionThrower,
    this._cacheExceptionThrower
  );

  @override
  Future<OIDCResponse> checkOIDCIsAvailable(OIDCRequest oidcRequest) {
    return Future.sync(() async {
      return await _oidcHttpClient.checkOIDCIsAvailable(oidcRequest);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<OIDCConfiguration> getOIDCConfiguration(OIDCResponse oidcResponse) {
    return Future.sync(() async {
      return await _oidcHttpClient.getOIDCConfiguration(oidcResponse);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<OIDCDiscoveryResponse> discoverOIDC(OIDCConfiguration oidcConfiguration) {
    return Future.sync(() async {
      return await _oidcHttpClient.discoverOIDC(oidcConfiguration);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<TokenOIDC> getTokenOIDC(String clientId, String redirectUrl, String discoveryUrl, List<String> scopes) {
    return Future.sync(() async {
      return await _authenticationClient.getTokenOIDC(clientId, redirectUrl, discoveryUrl, scopes);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<TokenOIDC> getStoredTokenOIDC(String tokenIdHash) {
    return Future.sync(() async {
      return await _tokenOidcCacheManager.getTokenOidc(tokenIdHash);
    }).catchError(_cacheExceptionThrower.throwException);
  }

  @override
  Future<void> persistTokenOIDC(TokenOIDC tokenOidc) {
    return Future.sync(() async {
      return await _tokenOidcCacheManager.persistOneTokenOidc(tokenOidc);
    }).catchError(_cacheExceptionThrower.throwException);
  }

  @override
  Future<OIDCConfiguration> getStoredOidcConfiguration() {
    return Future.sync(() async {
      return await _oidcConfigurationCacheManager.getOidcConfiguration();
    }).catchError(_cacheExceptionThrower.throwException);
  }

  @override
  Future<void> persistOidcConfiguration(OIDCConfiguration oidcConfiguration) {
    return Future.sync(() async {
      return await _oidcConfigurationCacheManager.persistOidcConfiguration(oidcConfiguration);
    }).catchError(_cacheExceptionThrower.throwException);
  }

  @override
  Future<TokenOIDC> refreshingTokensOIDC(
    String clientId,
    String redirectUrl,
    String discoveryUrl,
    List<String> scopes,
    String refreshToken
  ) {
    return Future.sync(() async {
      return await _authenticationClient.refreshingTokensOIDC(
        clientId,
        redirectUrl,
        discoveryUrl,
        scopes,
        refreshToken);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<bool> logout(TokenId tokenId, OIDCConfiguration config, OIDCDiscoveryResponse oidcRescovery) {
    return Future.sync(() async {
       return await _authenticationClient.logoutOidc(tokenId, config, oidcRescovery);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> deleteOidcConfiguration() {
    return Future.sync(() async {
      return await _oidcConfigurationCacheManager.deleteOidcConfiguration();
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> authenticateOidcOnBrowser(
    String clientId,
    String redirectUrl,
    String discoveryUrl,
    List<String> scopes
  ) {
    return Future.sync(() async {
      return await _authenticationClient.authenticateOidcOnBrowser(
        clientId,
        redirectUrl,
        discoveryUrl,
        scopes);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<String> getAuthenticationInfo() {
    return Future.sync(() async {
      return await _authenticationClient.getAuthenticationInfo();
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> deleteTokenOIDC() {
    return Future.sync(() async {
      return await _tokenOidcCacheManager.deleteTokenOidc();
    }).catchError(_exceptionThrower.throwException);
  }
}