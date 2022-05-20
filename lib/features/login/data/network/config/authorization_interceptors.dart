import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:model/model.dart';

class AuthorizationInterceptors extends InterceptorsWrapper {
  String? _authorization;
  Token? _token;

  void changeAuthorization(String? userName, String? password) {
    _authorization = base64Encode(utf8.encode('$userName:$password'));
  }

  void setToken(Token? newToken) {
    _token = newToken;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_authorization != null) {
      options.headers[HttpHeaders.authorizationHeader] = _getAuthorizationAsBasicHeader(_authorization);
    } else if (_token != null && _token?.isTokenValid() == true) {
      options.headers[HttpHeaders.authorizationHeader] = _getTokenAsBearerHeader(_token!.token);
    }
    super.onRequest(options, handler);
  }

  String _getAuthorizationAsBasicHeader(String? authorization) => 'Basic $authorization';

  String _getTokenAsBearerHeader(String token) => 'Bearer $token';
}
