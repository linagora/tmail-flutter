import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:core/core.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token.dart';

class AuthorizationIsolateInterceptors extends QueuedInterceptorsWrapper {

  AuthenticationType _authenticationType = AuthenticationType.none;
  OIDCConfiguration? _configOIDC;
  Token? _token;
  String? _authorization;

  void setBasicAuthorization(String? userName, String? password) {
    _authorization = base64Encode(utf8.encode('$userName:$password'));
    _authenticationType = AuthenticationType.basic;
  }

  void setTokenAndAuthorityOidc({Token? newToken, OIDCConfiguration? newConfig}) {
    _token = newToken;
    _configOIDC = newConfig;
    _authenticationType = AuthenticationType.oidc;
    log('AuthorizationIsolateInterceptors::setToken(): newToken: $newToken');
    log('AuthorizationIsolateInterceptors::setToken(): tokenId: ${newToken?.tokenIdHash}');
    log('AuthorizationIsolateInterceptors::setToken(): EXPIRE_DATE: ${newToken?.expiredTime?.toIso8601String()}');
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

  String _getAuthorizationAsBasicHeader(String? authorization) => 'Basic $authorization';

  String _getTokenAsBearerHeader(String token) => 'Bearer $token';

  void clear() {
    _authorization = null;
    _token = null;
    _configOIDC = null;
    _authenticationType = AuthenticationType.none;
  }
}
