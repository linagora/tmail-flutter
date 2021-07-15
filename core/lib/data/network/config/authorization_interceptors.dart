import 'dart:convert';

import 'package:dio/dio.dart';

class AuthorizationInterceptors extends InterceptorsWrapper {
  String? _authorization;

  void changeAuthorization(String? userName, String? password) {
    _authorization = base64Encode(utf8.encode('$userName:$password'));
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_authorization != null) {
      options.headers['Authorization'] = 'Basic $_authorization';
    }
    super.onRequest(options, handler);
  }
}
