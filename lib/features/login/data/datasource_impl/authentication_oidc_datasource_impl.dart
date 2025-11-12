import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/request/oidc_request.dart';
import 'package:model/oidc/response/oidc_discovery_response.dart';
import 'package:model/oidc/response/oidc_response.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/caching/utils/session_storage_manager.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_oidc_datasource.dart';
import 'package:tmail_ui_user/features/login/data/local/oidc_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/config/oidc_constant.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_http_client.dart';
import 'package:tmail_ui_user/features/login/domain/model/login_constants.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class AuthenticationOIDCDataSourceImpl extends AuthenticationOIDCDataSource {

  final OIDCHttpClient _oidcHttpClient;
  final AuthenticationClientBase _authenticationClient;
  final TokenOidcCacheManager _tokenOidcCacheManager;
  final OidcConfigurationCacheManager _oidcConfigurationCacheManager;
  final SessionStorageManager _sessionStorageManager;
  final ExceptionThrower _exceptionThrower;
  final ExceptionThrower _cacheExceptionThrower;

  AuthenticationOIDCDataSourceImpl(
    this._oidcHttpClient,
    this._authenticationClient,
    this._tokenOidcCacheManager,
    this._oidcConfigurationCacheManager,
    this._sessionStorageManager,
    this._exceptionThrower,
    this._cacheExceptionThrower
  );

  @override
  Future<OIDCResponse> checkOIDCIsAvailable(OIDCRequest oidcRequest) {
    return Future.sync(() async {
      return await _oidcHttpClient.checkOIDCIsAvailable(oidcRequest);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<OIDCConfiguration> getOIDCConfiguration(OIDCResponse oidcResponse) {
    return Future.sync(() async {
      return await _oidcHttpClient.getOIDCConfiguration(oidcResponse);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<OIDCDiscoveryResponse> discoverOIDC(OIDCConfiguration oidcConfiguration) {
    return Future.sync(() async {
      return await _oidcHttpClient.discoverOIDC(oidcConfiguration);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<TokenOIDC> getTokenOIDC(String clientId, String redirectUrl, String discoveryUrl, List<String> scopes, {String? loginHint}) {
    return Future.sync(() async {
      return await _authenticationClient.getTokenOIDC(clientId, redirectUrl, discoveryUrl, scopes, loginHint: loginHint);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<TokenOIDC> getStoredTokenOIDC(String tokenIdHash) {
    return Future.sync(() async {
      return await _tokenOidcCacheManager.getTokenOidc(tokenIdHash);
    }).catchError((error, stackTrace) async {
      await _cacheExceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<void> persistTokenOIDC(TokenOIDC tokenOidc) {
    return Future.sync(() async {
      return await _tokenOidcCacheManager.persistOneTokenOidc(tokenOidc);
    }).catchError((error, stackTrace) async {
      await _cacheExceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<OIDCConfiguration> getStoredOidcConfiguration() {
    return Future.sync(() async {
      return await _oidcConfigurationCacheManager.getOidcConfiguration();
    }).catchError((error, stackTrace) async {
      await _cacheExceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<void> persistOidcConfiguration(OIDCConfiguration oidcConfiguration) {
    return Future.sync(() async {
      return await _oidcConfigurationCacheManager.persistOidcConfiguration(oidcConfiguration);
    }).catchError((error, stackTrace) async {
      await _cacheExceptionThrower.throwException(error, stackTrace);
      throw error;
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
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<bool> logout(TokenId tokenId, OIDCConfiguration config, OIDCDiscoveryResponse oidcRescovery) {
    return Future.sync(() async {
       return await _authenticationClient.logoutOidc(tokenId, config, oidcRescovery);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<void> deleteOidcConfiguration() {
    return Future.sync(() async {
      return await _oidcConfigurationCacheManager.deleteOidcConfiguration();
    }).catchError((error, stackTrace) async {
      await _cacheExceptionThrower.throwException(error, stackTrace);
      throw error;
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
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<String> getAuthenticationInfo() {
    return Future.sync(() {
      return _sessionStorageManager.get(
        OIDCConstant.authResponseKey,
      );
    }).catchError((error, stackTrace) async {
      await _cacheExceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<void> deleteTokenOIDC() {
    return Future.sync(() async {
      return await _tokenOidcCacheManager.deleteTokenOidc();
    }).catchError((error, stackTrace) async {
      await _cacheExceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<void> removeAuthDestinationUrl() {
    return Future.sync(() {
      return _sessionStorageManager.remove(
        LoginConstants.AUTH_DESTINATION_KEY,
      );
    }).catchError((error, stackTrace) async {
      await _cacheExceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }
}