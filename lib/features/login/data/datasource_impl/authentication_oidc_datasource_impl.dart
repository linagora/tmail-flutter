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

  AuthenticationOIDCDataSourceImpl(
    this._oidcHttpClient,
    this._authenticationClient,
    this._tokenOidcCacheManager,
    this._oidcConfigurationCacheManager,
    this._exceptionThrower
  );

  @override
  Future<OIDCResponse> checkOIDCIsAvailable(OIDCRequest oidcRequest) {
    return Future.sync(() async {
      final oidcResponse = await _oidcHttpClient.checkOIDCIsAvailable(oidcRequest);
      return oidcResponse!;
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<OIDCConfiguration> getOIDCConfiguration(OIDCResponse oidcResponse) {
    return Future.sync(() async {
      return await _oidcHttpClient.getOIDCConfiguration(oidcResponse);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<TokenOIDC> getTokenOIDC(String clientId, String redirectUrl, String discoveryUrl, List<String> scopes) {
    return Future.sync(() async {
      return await _authenticationClient.getTokenOIDC(clientId, redirectUrl, discoveryUrl, scopes);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<TokenOIDC> getStoredTokenOIDC(String tokenIdHash) {
    return Future.sync(() async {
      return await _tokenOidcCacheManager.getTokenOidc(tokenIdHash);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<void> persistTokenOIDC(TokenOIDC tokenOidc) {
    return Future.sync(() async {
      return await _tokenOidcCacheManager.persistOneTokenOidc(tokenOidc);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<OIDCConfiguration> getStoredOidcConfiguration() {
    return Future.sync(() async {
      return await _oidcConfigurationCacheManager.getOidcConfiguration();
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<void> persistAuthorityOidc(String authority) {
    return Future.sync(() async {
      return await _oidcConfigurationCacheManager.persistAuthorityOidc(authority);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
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
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<bool> logout(TokenId tokenId, OIDCConfiguration config) {
    return Future.sync(() async {
       return await _authenticationClient.logoutOidc(tokenId, config);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<void> deleteAuthorityOidc() {
    return Future.sync(() async {
      return await _oidcConfigurationCacheManager.deleteAuthorityOidc();
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
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
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<String?> getAuthenticationInfo() {
    return Future.sync(() async {
      return await _authenticationClient.getAuthenticationInfo();
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<void> deleteTokenOIDC() {
    return Future.sync(() async {
      return await _tokenOidcCacheManager.deleteTokenOidc();
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }
}