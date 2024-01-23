import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dio/dio.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/password.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/oidc_configuration_extensions.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

class AuthorizationInterceptors extends QueuedInterceptorsWrapper {

  final Dio _dio;
  final AuthenticationClientBase _authenticationClient;
  final TokenOidcCacheManager _tokenOidcCacheManager;
  final AccountCacheManager _accountCacheManager;
  final IOSSharingManager _iosSharingManager;

  AuthenticationType _authenticationType = AuthenticationType.none;
  OIDCConfiguration? _configOIDC;
  TokenOIDC? _token;
  String? _authorization;

  AuthorizationInterceptors(
    this._dio,
    this._authenticationClient,
    this._tokenOidcCacheManager,
    this._accountCacheManager,
    this._iosSharingManager,
  );

  void setBasicAuthorization(UserName userName, Password password) {
    _authorization = base64Encode(utf8.encode('${userName.value}:${password.value}'));
    _authenticationType = AuthenticationType.basic;
  }

  void setTokenAndAuthorityOidc({TokenOIDC? newToken, OIDCConfiguration? newConfig}) {
    _token = newToken;
    _configOIDC = newConfig;
    _authenticationType = AuthenticationType.oidc;
  }

  void _updateNewToken(TokenOIDC newToken) {
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

      if (validateToRefreshToken(err)) {
        log('AuthorizationInterceptors::onError:>> _validateToRefreshToken');

        if (PlatformInfo.isIOS) {
          await _handleRefreshTokenOnIOSPlatform();
        } else {
          await _handleRefreshTokenOnOtherPlatform();
        }

        if (extraInRequest.containsKey(FileUploader.uploadAttachmentExtraKey)) {
          final uploadExtra = extraInRequest[FileUploader.uploadAttachmentExtraKey];

          requestOptions.headers[HttpHeaders.authorizationHeader] = _getTokenAsBearerHeader(_token!.token);
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
          requestOptions.headers[HttpHeaders.authorizationHeader] = _getTokenAsBearerHeader(_token!.token);

          final response = await _dio.fetch(requestOptions);
          return handler.resolve(response);
        }
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

  bool validateToRefreshToken(DioError dioError) {
    if (dioError.response?.statusCode == 401 &&
        _isAuthenticationOidcValid() &&
        _isTokenNotEmpty() &&
        _isRefreshTokenNotEmpty() &&
        _isTokenExpired()
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

  Future<PersonalAccount> _updateCurrentAccount({required TokenOIDC tokenOIDC}) async {
    final currentAccount = await _accountCacheManager.getCurrentAccount();

    await _accountCacheManager.deleteCurrentAccount(currentAccount.id);

    await _tokenOidcCacheManager.persistOneTokenOidc(tokenOIDC);

    final personalAccount = PersonalAccount(
      tokenOIDC.tokenIdHash,
      AuthenticationType.oidc,
      isSelected: true,
      accountId: currentAccount.accountId,
      apiUrl: currentAccount.apiUrl,
      userName: currentAccount.userName
    );
    await _accountCacheManager.setCurrentAccount(personalAccount);

    return personalAccount;
  }

  Future<TokenOIDC?> _getTokenInKeychain(TokenOIDC currentTokenOidc) async {
    final currentAccount = await _accountCacheManager.getCurrentAccount();
    log('AuthorizationInterceptors::_getTokenInKeychain:currentAccount: $currentAccount');
    if (currentAccount.accountId == null) {
      return null;
    }

    final keychainSharingSession = await _iosSharingManager.getKeychainSharingSession(currentAccount.accountId!);
    log('AuthorizationInterceptors::_getTokenInKeychain:keychainSharingSession: $keychainSharingSession');
    if (keychainSharingSession == null) {
      return null;
    }

    if (keychainSharingSession.tokenOIDC != null &&
        currentTokenOidc.token != keychainSharingSession.tokenOIDC!.token) {
      return keychainSharingSession.tokenOIDC!;
    }

    return null;
  }

  Future<TokenOIDC> invokeRefreshTokenFromServer() async {
    final newToken = await _authenticationClient.refreshingTokensOIDC(
      _configOIDC!.clientId,
      _configOIDC!.redirectUrl,
      _configOIDC!.discoveryUrl,
      _configOIDC!.scopes,
      _token!.refreshToken
    );
    log('AuthorizationInterceptors::_invokeRefreshTokenFromServer:newToken: $newToken');
    return newToken;
  }

  Future _handleRefreshTokenOnIOSPlatform() async {
    final keychainToken = await _getTokenInKeychain(_token!);

    if (keychainToken == null) {
      final newToken = await invokeRefreshTokenFromServer();

      _updateNewToken(newToken);

      final newAccount = await _updateCurrentAccount(tokenOIDC: newToken);

      await _iosSharingManager.saveKeyChainSharingSession(newAccount);
    } else {
      _updateNewToken(keychainToken);

      await _updateCurrentAccount(tokenOIDC: keychainToken);
    }
  }

  Future _handleRefreshTokenOnOtherPlatform() async {
    final newToken = await invokeRefreshTokenFromServer();

    _updateNewToken(newToken);

    await _updateCurrentAccount(tokenOIDC: newToken);
  }

  void clear() {
    _authorization = null;
    _token = null;
    _configOIDC = null;
    _authenticationType = AuthenticationType.none;
  }
}