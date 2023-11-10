import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/password.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/oidc_configuration_extensions.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';

class AuthorizationInterceptors extends QueuedInterceptorsWrapper {

  static const int _maxRetryCount = 3;
  static const String _retryKey = 'Retry';

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

  void setBasicAuthorization(UserName userName, Password password) {
    _authorization = base64Encode(utf8.encode('${userName.value}:${password.value}'));
    _authenticationType = AuthenticationType.basic;
  }

  void setTokenAndAuthorityOidc({Token? newToken, OIDCConfiguration? newConfig}) {
    _token = newToken;
    _configOIDC = newConfig;
    _authenticationType = AuthenticationType.oidc;
  }

  void _updateNewToken(Token newToken) {
    _token = newToken;
  }

  OIDCConfiguration? get oidcConfig => _configOIDC;

  AuthenticationType get authenticationType => _authenticationType;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('AuthorizationInterceptors::onRequest():url: ${options.uri} | data: ${options.data} | header: ${options.headers}');
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
    logError('AuthorizationInterceptors::onError(): $err');
    try {
      final requestOptions = err.requestOptions;
      final extraInRequest = requestOptions.extra;
      var retries = extraInRequest[_retryKey] ?? 0;

      if (_validateToRefreshToken(err)) {
        log('AuthorizationInterceptors::onError:>> _validateToRefreshToken');
        final newToken = await _authenticationClient.refreshingTokensOIDC(
          _configOIDC!.clientId,
          _configOIDC!.redirectUrl,
          _configOIDC!.discoveryUrl,
          _configOIDC!.scopes,
          _token!.refreshToken
        );

        final currentAccount = await _accountCacheManager.getCurrentAccount();

        await _accountCacheManager.deleteCurrentAccount(currentAccount.id);

        await Future.wait([
          _tokenOidcCacheManager.persistOneTokenOidc(newToken),
          _accountCacheManager.setCurrentAccount(
            PersonalAccount(
              newToken.tokenIdHash,
              AuthenticationType.oidc,
              isSelected: true,
              accountId: currentAccount.accountId,
              apiUrl: currentAccount.apiUrl,
              userName: currentAccount.userName
            )
          )
        ]);
        _updateNewToken(newToken.toToken());

        if (extraInRequest.containsKey(FileUploader.uploadAttachmentExtraKey)) {
          final uploadExtra = extraInRequest[FileUploader.uploadAttachmentExtraKey];

          requestOptions.headers[HttpHeaders.authorizationHeader] = _getTokenAsBearerHeader(newToken.token);
          requestOptions.headers[HttpHeaders.contentTypeHeader] = uploadExtra[FileUploader.typeExtraKey];
          requestOptions.headers[HttpHeaders.contentLengthHeader] = uploadExtra[FileUploader.sizeExtraKey];

          final newOptions = Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
          );

          final response = await _dio.request(
            requestOptions.path,
            data: _getDataUploadRequest(uploadExtra),
            queryParameters: requestOptions.queryParameters,
            options: newOptions,
          );

          return handler.resolve(response);
        } else {
          requestOptions.headers[HttpHeaders.authorizationHeader] = _getTokenAsBearerHeader(newToken.token);

          final response = await _dio.fetch(requestOptions);
          return handler.resolve(response);
        }
      } else if (_validateToRetry(err, retries)) {
        log('AuthorizationInterceptors::onError:>> _validateToRetry | retries: $retries');
        retries++;

        requestOptions.headers[HttpHeaders.authorizationHeader] = _getTokenAsBearerHeader(_token!.token);
        requestOptions.extra = {_retryKey: retries};

        final response = await _dio.fetch(requestOptions);
        return handler.resolve(response);
      } else {
        super.onError(err, handler);
      }
    } catch (e) {
      logError('AuthorizationInterceptors::onError:Exception: $e');
      super.onError(err.copyWith(error: e), handler);
    }
  }

  Stream<List<int>>? _getDataUploadRequest(dynamic mapUploadExtra) {
    final currentPlatform = mapUploadExtra[FileUploader.platformExtraKey];
    if (currentPlatform == 'web') {
      return BodyBytesStream.fromBytes(mapUploadExtra[FileUploader.bytesExtraKey]);
    } else {
      return File(mapUploadExtra[FileUploader.filePathExtraKey]).openRead();
    }
  }

  bool _isTokenExpired() => _token?.isExpired == true;

  bool _isAuthenticationOidcValid() => _authenticationType == AuthenticationType.oidc && _configOIDC != null;

  bool _isTokenNotEmpty() => _token?.token.isNotEmpty == true;

  bool _isRefreshTokenNotEmpty() => _token?.refreshToken.isNotEmpty == true;

  bool _validateToRefreshToken(DioError dioError) {
    if (dioError.response?.statusCode == 401 &&
        _isAuthenticationOidcValid() &&
        _isRefreshTokenNotEmpty() &&
        _isTokenExpired()
    ) {
      return true;
    }
    return false;
  }

  bool _validateToRetry(DioError dioError, int retryCount) {
    if (dioError.type == DioErrorType.badResponse &&
        dioError.response?.statusCode == 401 &&
        _isTokenNotEmpty() &&
        retryCount < _maxRetryCount
    ) {
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