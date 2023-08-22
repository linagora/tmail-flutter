import 'dart:convert';
import 'dart:io';

import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/oidc_configuration_extensions.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';

class AuthorizationInterceptors extends QueuedInterceptorsWrapper {

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
    log('AuthorizationInterceptors::setToken(): newToken: $newToken | configOIDC: $_configOIDC');
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
    log('AuthorizationInterceptors::onError():dioType: ${err.type} | statusCode: ${err.response?.statusCode} | message: ${err.message} | statusMessage: ${err.response?.statusMessage}');
    try {
      if (_validateToRefreshToken(err)) {
        log('AuthorizationInterceptors::onError:RefreshTokenCalled:configOIDC: $_configOIDC | refreshTokenCurrent: ${_token?.refreshToken}');
        final newToken = await _authenticationClient.refreshingTokensOIDC(
          _configOIDC!.clientId,
          _configOIDC!.redirectUrl,
          _configOIDC!.discoveryUrl,
          _configOIDC!.scopes,
          _token!.refreshToken
        );

        final accountCurrent = await _accountCacheManager.getSelectedAccount();

        await _accountCacheManager.deleteSelectedAccount(_token!.tokenIdHash);

        await Future.wait([
          _tokenOidcCacheManager.persistOneTokenOidc(newToken),
          _accountCacheManager.setSelectedAccount(
            PersonalAccount(
              newToken.tokenIdHash,
              AuthenticationType.oidc,
              isSelected: true,
              accountId: accountCurrent.accountId,
              apiUrl: accountCurrent.apiUrl,
              userName: accountCurrent.userName
            )
          )
        ]);
        log('AuthorizationInterceptors::onError():NewToken: $newToken');
        _updateNewToken(newToken.toToken());

        final requestOptions = err.requestOptions;
        requestOptions.headers[HttpHeaders.authorizationHeader] = _getTokenAsBearerHeader(newToken.token);

        final response = await _dio.fetch(requestOptions);
        return handler.resolve(response);
      } else {
        super.onError(err, handler);
      }
    } catch (e) {
      log('AuthorizationInterceptors::onError():Exception: $e');
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

  bool _isRefreshTokenNotEmpty() => _token != null && _token!.refreshToken.isNotEmpty;

  bool _validateToRefreshToken(DioError dioError) {
    if (_isTokenExpired() &&
        (dioError.response == null || dioError.response?.statusCode == 401) &&
        _isRefreshTokenNotEmpty() &&
        _isAuthenticationOidcValid()) {
      return true;
    }
    return false;
  }

  String _getAuthorizationAsBasicHeader(String? authorization) => 'Basic $authorization';

  String _getTokenAsBearerHeader(String token) => 'Bearer $token';

  bool get isAppRunning {
    switch(_authenticationType) {
      case AuthenticationType.basic:
        return _authorization != null;
      case AuthenticationType.oidc:
        return _configOIDC != null && _token != null;
      case AuthenticationType.none:
        return false;
    }
  }

  void clear() {
    _authorization = null;
    _token = null;
    _configOIDC = null;
    _authenticationType = AuthenticationType.none;
  }
}
