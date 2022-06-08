import 'dart:convert';
import 'dart:io';

import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:model/account/account.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/extensions/oidc_configuration_extensions.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';

class AuthorizationInterceptors extends InterceptorsWrapper {

  final Dio _dio;
  final AuthenticationClientBase _authenticationClient;
  final TokenOidcCacheManager _tokenOidcCacheManager;
  final AccountCacheManager _accountCacheManager;

  AuthenticationType _authenticationType = AuthenticationType.none;
  OIDCConfiguration? _configOIDC;
  Token? _token;
  String? _authorization;

  AuthorizationInterceptors(
    this._dio,
    this._authenticationClient,
    this._tokenOidcCacheManager,
    this._accountCacheManager
  );

  void setBasicAuthorization(String? userName, String? password) {
    _authorization = base64Encode(utf8.encode('$userName:$password'));
    _authenticationType = AuthenticationType.basic;
  }

  void setTokenAndAuthorityOidc({Token? newToken, OIDCConfiguration? newConfig}) {
    _token = newToken;
    _configOIDC = newConfig;
    _authenticationType = AuthenticationType.oidc;
    log('AuthorizationInterceptors::setToken(): newToken: $newToken');
    log('AuthorizationInterceptors::setToken(): tokenId: ${newToken?.tokenIdHash}');
    log('AuthorizationInterceptors::setToken(): EXPIRE_DATE: ${newToken?.expiredTime?.toIso8601String()}');
  }

  void _updateNewToken(Token newToken) {
    _token = newToken;
  }

  OIDCConfiguration? get oidcConfig => _configOIDC;

  AuthenticationType get authenticationType => _authenticationType;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    switch(_authenticationType) {
      case AuthenticationType.basic:
        if (_authorization != null) {
          options.headers[HttpHeaders.authorizationHeader] = _getAuthorizationAsBasicHeader(_authorization);
        }
        break;
      case AuthenticationType.oidc:
        if (_token != null && _token?.isTokenValid() == true) {
          options.headers[HttpHeaders.authorizationHeader] = _getTokenAsBearerHeader(_token!.token);
        }
        break;
      case AuthenticationType.none:
        break;
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    log('AuthorizationInterceptors::onError(): $err');
    if ((_isTokenExpired() || err.response?.statusCode == 401) &&
        _isAuthenticationOidcValid()) {
      try {
        final newToken = await _authenticationClient.refreshingTokensOIDC(
            _configOIDC!.clientId,
            _configOIDC!.redirectUrl,
            _configOIDC!.discoveryUrl,
            _configOIDC!.scopes,
            _token!.refreshToken);

        await Future.wait([
          _tokenOidcCacheManager.persistOneTokenOidc(newToken),
          _accountCacheManager.deleteSelectedAccount(_token!.tokenIdHash),
          _accountCacheManager.setSelectedAccount(Account(
              newToken.tokenIdHash,
              AuthenticationType.oidc,
              isSelected: true)),
        ]);

        log('AuthorizationInterceptors::onError(): refreshToken: $newToken');
        log('AuthorizationInterceptors::setToken(): refreshTokenId: ${newToken.tokenIdHash}');

        _updateNewToken(newToken.toToken());

        requestOptions.headers[HttpHeaders.authorizationHeader] =
            _getTokenAsBearerHeader(newToken.token);

        final response = await _dio.fetch(requestOptions);
        return handler.resolve(response);
      } catch(e) {
        log('AuthorizationInterceptors::onError(): $e');
        super.onError(err, handler);
      }
    } else {
      super.onError(err, handler);
    }
  }

  bool _isTokenExpired() {
    if (_token?.isExpired == true) {
      log('AuthorizationInterceptors::_isTokenExpired(): TOKE_EXPIRED');
      return true;
    }
    return false;
  }

  bool _isAuthenticationOidcValid() {
    if (_authenticationType == AuthenticationType.oidc &&
        _configOIDC != null &&
        _token != null) {
      log('AuthorizationInterceptors::_isAuthenticationOidcValid()');
      return true;
    }
    return false;
  }

  String _getAuthorizationAsBasicHeader(String? authorization) => 'Basic $authorization';

  String _getTokenAsBearerHeader(String token) => 'Bearer $token';

  void clear() {
    _authorization = null;
    _token = null;
    _configOIDC = null;
    _authenticationType = AuthenticationType.none;
  }
}
