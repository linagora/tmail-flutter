import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:tmail_ui_user/features/login/data/model/request/account_request.dart';
import 'package:tmail_ui_user/features/login/data/model/response/user_profile_response.dart';

class LoginAPI {
  final DioClient _dioClient;

  LoginAPI(this._dioClient);

  Future<UserProfileResponse> authenticationUser(Uri baseUrl, AccountRequest accountRequest) async {
    final basicAuth = 'Basic ' + base64Encode(utf8.encode('${accountRequest.userName.userName}:${accountRequest.password.value}'));
    final resultJson = await _dioClient.post(
      Endpoint.authentication.generateAuthenticationUrl(baseUrl),
      options: Options(headers: _buildHeaderRequestParam(basicAuth)),
      data: accountRequest.toJson());
    return UserProfileResponse.fromJson(resultJson);
  }

  Map<String, dynamic> _buildHeaderRequestParam(String authorizationHeader) {
    final headerParam = _dioClient.getHeaders();
    headerParam[HttpHeaders.authorizationHeader] = authorizationHeader;
    return headerParam;
  }
}